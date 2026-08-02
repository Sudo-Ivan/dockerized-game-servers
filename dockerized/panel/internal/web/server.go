package web

import (
	"context"
	"embed"
	"encoding/json"
	"fmt"
	"html/template"
	"io"
	"io/fs"
	"maps"
	"net/http"
	"time"

	"gameserverpanel/internal/auth"
	"gameserverpanel/internal/events"
	"gameserverpanel/internal/game"
	"gameserverpanel/internal/panelconfig"
	"gameserverpanel/internal/plugins"
	"gameserverpanel/internal/schedule"
)

//go:embed templates/*.html templates/partials/*.html
var coreTemplateFS embed.FS

//go:embed static/*
var staticFS embed.FS

type Server struct {
	panel     panelconfig.Config
	mod       game.Module
	auth      *auth.Manager
	limiter   *auth.LoginLimiter
	scheduler *schedule.Restarter
	plugins   *plugins.Registry
	events    *events.Broker
	tmpl      *template.Template
	static    http.Handler
	maxUpload int64
}

type PageData struct {
	Title       string
	PanelTitle  string
	AuthEnabled bool
	Nav         []game.NavItem
	Flash       string
	Error       string
}

func New(
	panel panelconfig.Config,
	mod game.Module,
	authMgr *auth.Manager,
	reg *plugins.Registry,
	broker *events.Broker,
	scheduler *schedule.Restarter,
) (*Server, error) {
	funcs := template.FuncMap{}
	maps.Copy(funcs, mod.TemplateFuncs())
	tmpl := template.New("panel").Funcs(funcs)
	if _, err := tmpl.ParseFS(coreTemplateFS, "templates/*.html", "templates/partials/*.html"); err != nil {
		return nil, err
	}
	if _, err := tmpl.ParseFS(mod.TemplateFS(), "*.html", "partials/*.html"); err != nil {
		return nil, err
	}
	staticSub, err := fs.Sub(staticFS, "static")
	if err != nil {
		return nil, err
	}
	limiter := auth.NewLoginLimiter(
		panel.LoginMaxAttempts,
		time.Duration(panel.LoginWindowSeconds)*time.Second,
		time.Duration(panel.LoginLockoutSeconds)*time.Second,
	)
	return &Server{
		panel:     panel,
		mod:       mod,
		auth:      authMgr,
		limiter:   limiter,
		scheduler: scheduler,
		plugins:   reg,
		events:    broker,
		tmpl:      tmpl,
		static:    http.FileServer(http.FS(staticSub)),
		maxUpload: panel.MaxUpload,
	}, nil
}

func (s *Server) Handler() http.Handler {
	mux := http.NewServeMux()
	mux.Handle("/static/", http.StripPrefix("/static/", s.static))
	mux.HandleFunc("/health", s.handleHealth)
	mux.HandleFunc("/login", s.handleLogin)
	mux.HandleFunc("/logout", s.handleLogout)

	protected := http.NewServeMux()
	protected.HandleFunc("/events", s.handleEvents)
	protected.HandleFunc("/server/start", s.handleServerStart)
	protected.HandleFunc("/server/stop", s.handleServerStop)
	protected.HandleFunc("/server/restart", s.handleServerRestart)
	protected.HandleFunc("/backup", s.handleBackup)
	protected.HandleFunc("/backup/download", s.handleBackupDownload)
	protected.HandleFunc("/backup/restore", s.handleBackupRestore)
	s.mod.RegisterRoutes(protected, s)

	mux.Handle("/", s.withIPAllowlist(s.requireAuth(protected)))
	return s.withSecurityHeaders(mux)
}

func (s *Server) PanelTitle() string      { return s.mod.Title() }
func (s *Server) AuthEnabled() bool       { return s.auth.Enabled() }
func (s *Server) GameModule() game.Module { return s.mod }
func (s *Server) MaxUpload() int64        { return s.maxUpload }

func (s *Server) BasePage(title string) PageData {
	return PageData{
		Title:       title,
		PanelTitle:  s.mod.Title(),
		AuthEnabled: s.auth.Enabled(),
		Nav:         s.mod.NavItems(),
	}
}

func (s *Server) Render(w http.ResponseWriter, name string, data any) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := s.tmpl.ExecuteTemplate(w, name, data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func (s *Server) RenderPartial(w http.ResponseWriter, name string, data any) {
	s.Render(w, name, data)
}

func (s *Server) IsHTMX(r *http.Request) bool {
	return r.Header.Get("HX-Request") == "true"
}

func (s *Server) Emit(topic string, payload any) {
	s.events.Publish(topic, payload)
}

func (s *Server) EmitPlugin(eventType string, data map[string]string) {
	if s.plugins == nil {
		return
	}
	s.plugins.Emit(context.Background(), plugins.Event{Type: plugins.EventType(eventType), Data: data})
}

func (s *Server) withIPAllowlist(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ip := auth.ClientIP(r)
		if !auth.IPAllowed(ip, s.panel.AllowedIPs) {
			http.Error(w, "forbidden", http.StatusForbidden)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func (s *Server) withSecurityHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("X-Frame-Options", "DENY")
		w.Header().Set("Referrer-Policy", "no-referrer")
		next.ServeHTTP(w, r)
	})
}

func (s *Server) requireAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if s.auth.Authenticated(r) {
			next.ServeHTTP(w, r)
			return
		}
		http.Redirect(w, r, "/login", http.StatusSeeOther)
	})
}

func (s *Server) handleEvents(w http.ResponseWriter, r *http.Request) {
	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "streaming unsupported", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")

	ch, cancel := s.events.Subscribe(32)
	defer cancel()

	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	flush := func() { flusher.Flush() }
	sendStatus := func() {
		st := s.mod.Manager().Status()
		payload, _ := json.Marshal(st)
		fmt.Fprintf(w, "event: status\ndata: %s\n\n", payload)
		flush()
	}

	sendStatus()
	s.mod.SSESnapshot(s, w, flush)

	for {
		select {
		case <-r.Context().Done():
			return
		case msg := <-ch:
			fmt.Fprintf(w, "event: message\ndata: %s\n\n", msg)
			flush()
		case <-ticker.C:
			sendStatus()
			s.mod.SSESnapshot(s, w, flush)
		}
	}
}

func readAllString(r io.Reader) string {
	b, _ := io.ReadAll(r)
	return string(b)
}
