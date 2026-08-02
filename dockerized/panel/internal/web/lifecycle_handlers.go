package web

import (
	"context"
	"net/http"
	"time"

	"gameserverpanel/internal/game"
	"gameserverpanel/internal/plugins"
)

type statusViewData struct {
	State   string
	PID     int
	Uptime  string
	ModList string
	LastErr string
	Logs    []string
}

func statusView(st game.Status) statusViewData {
	return statusViewData{
		State:   string(st.State),
		PID:     st.PID,
		Uptime:  st.Uptime,
		ModList: st.Detail,
		LastErr: st.LastErr,
		Logs:    st.Logs,
	}
}

func (s *Server) handleServerStart(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	ctx, cancel := context.WithTimeout(r.Context(), 30*time.Minute)
	defer cancel()
	mgr := s.mod.Manager()
	err := mgr.Start(ctx)
	if err == nil {
		s.Emit("status", mgr.Status())
		s.EmitPlugin(string(plugins.EventServerStart), nil)
	}
	if s.IsHTMX(r) {
		st := mgr.Status()
		if err != nil {
			st.LastErr = err.Error()
		}
		s.RenderPartial(w, "partials/status.html", statusView(st))
		return
	}
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func (s *Server) handleServerStop(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	mgr := s.mod.Manager()
	err := mgr.Stop(20 * time.Second)
	if err == nil {
		s.Emit("status", mgr.Status())
		s.EmitPlugin(string(plugins.EventServerStop), nil)
	}
	if s.IsHTMX(r) {
		st := mgr.Status()
		if err != nil {
			st.LastErr = err.Error()
		}
		s.RenderPartial(w, "partials/status.html", statusView(st))
		return
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func (s *Server) handleServerRestart(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	ctx, cancel := context.WithTimeout(r.Context(), 30*time.Minute)
	defer cancel()
	mgr := s.mod.Manager()
	err := mgr.Restart(ctx)
	if err == nil {
		s.Emit("status", mgr.Status())
		s.EmitPlugin(string(plugins.EventServerStart), map[string]string{"action": "restart"})
	}
	if s.IsHTMX(r) {
		st := mgr.Status()
		if err != nil {
			st.LastErr = err.Error()
		}
		s.RenderPartial(w, "partials/status.html", statusView(st))
		return
	}
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}
