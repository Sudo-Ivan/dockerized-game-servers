package web

import (
	"context"
	"net/http"
	"strconv"
	"time"

	"gameserverpanel/internal/auth"
	"gameserverpanel/internal/plugins"
)

func (s *Server) handleLogin(w http.ResponseWriter, r *http.Request) {
	if !s.auth.Enabled() {
		http.Redirect(w, r, "/", http.StatusSeeOther)
		return
	}
	if r.Method == http.MethodGet {
		s.Render(w, "login.html", s.BasePage("Login"))
		return
	}
	ip := auth.ClientIP(r)
	now := time.Now()
	if ok, wait := s.limiter.Allowed(ip, now); !ok {
		data := s.BasePage("Login")
		data.Error = "Too many login attempts, try again in " + wait.Round(time.Second).String()
		s.Render(w, "login.html", data)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	if !s.auth.Login(r.FormValue("password")) {
		s.limiter.RecordFailure(ip, now)
		s.EmitPlugin(string(plugins.EventLoginFailed), map[string]string{"ip": ip})
		data := s.BasePage("Login")
		data.Error = "Invalid password"
		s.Render(w, "login.html", data)
		return
	}
	s.limiter.RecordSuccess(ip)
	if err := s.auth.SetCookie(w, r); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func (s *Server) handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	_, _ = w.Write([]byte("ok"))
}

func (s *Server) handleLogout(w http.ResponseWriter, r *http.Request) {
	s.auth.ClearCookie(w, r)
	http.Redirect(w, r, "/login", http.StatusSeeOther)
}

func parseFormInt(r *http.Request, key string, fallback int) int {
	v := r.FormValue(key)
	if v == "" {
		return fallback
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		return fallback
	}
	return n
}

func parseFormBool(r *http.Request, key string) bool {
	v := r.FormValue(key)
	return v == "1" || v == "on" || v == "true"
}

func (s *Server) emitPluginCtx(ctx context.Context, eventType plugins.EventType, data map[string]string) {
	if s.plugins == nil {
		return
	}
	s.plugins.Emit(ctx, plugins.Event{Type: eventType, Data: data})
}
