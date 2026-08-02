package panelconfig

import (
	"os"
	"strconv"
	"strings"
)

const DefaultPort = 9283

type Config struct {
	GameID      string
	Title       string
	Port        int
	ListenAddr  string
	CacheDir    string
	AutoStart   bool
	MaxUpload   int64
	PanelPass   string
	SessionSec  string
	AuthEnabled bool

	AllowedIPs          []string
	LoginMaxAttempts    int
	LoginWindowSeconds  int
	LoginLockoutSeconds int

	ScheduledRestart     string
	ScheduledRestartWarn []int
}

func Load() Config {
	port := envIntFirst([]string{"PANEL_PORT", "ARMA_PANEL_PORT"}, DefaultPort)
	cfg := Config{
		GameID:              envFirst([]string{"PANEL_GAME"}, "arma3"),
		Title:               envFirst([]string{"PANEL_TITLE"}, ""),
		Port:                port,
		ListenAddr:          envFirst([]string{"PANEL_ADDR", "ARMA_PANEL_ADDR"}, ":"+strconv.Itoa(port)),
		CacheDir:            envFirst([]string{"PANEL_CACHE_DIR", "ARMA_CACHE_DIR"}, "/home/arma3/cache"),
		AutoStart:           envBoolFirst([]string{"PANEL_AUTO_START", "ARMA_AUTO_START"}, true),
		PanelPass:           envFirst([]string{"PANEL_PASSWORD", "ARMA_PANEL_PASSWORD"}, ""),
		SessionSec:          envFirst([]string{"PANEL_SESSION_SECRET", "ARMA_PANEL_SESSION_SECRET"}, ""),
		LoginMaxAttempts:    envIntFirst([]string{"PANEL_LOGIN_MAX_ATTEMPTS", "ARMA_PANEL_LOGIN_MAX_ATTEMPTS"}, 5),
		LoginWindowSeconds:  envIntFirst([]string{"PANEL_LOGIN_WINDOW", "ARMA_PANEL_LOGIN_WINDOW"}, 900),
		LoginLockoutSeconds: envIntFirst([]string{"PANEL_LOGIN_LOCKOUT", "ARMA_PANEL_LOGIN_LOCKOUT"}, 900),
		ScheduledRestart:    strings.TrimSpace(envFirst([]string{"PANEL_SCHEDULED_RESTART", "ARMA_SCHEDULED_RESTART"}, "")),
	}
	cfg.MaxUpload = int64(envIntFirst([]string{"PANEL_MAX_UPLOAD", "ARMA_PANEL_MAX_UPLOAD"}, 512)) * 1024 * 1024
	cfg.ScheduledRestartWarn = parseIntList(envFirst([]string{"PANEL_SCHEDULED_RESTART_WARN", "ARMA_SCHEDULED_RESTART_WARN"}, "15,5,1"))
	if raw := envFirst([]string{"PANEL_ALLOWED_IPS", "ARMA_PANEL_ALLOWED_IPS"}, ""); raw != "" {
		for _, part := range strings.Split(raw, ",") {
			part = strings.TrimSpace(part)
			if part != "" {
				cfg.AllowedIPs = append(cfg.AllowedIPs, part)
			}
		}
	}
	cfg.AuthEnabled = cfg.PanelPass != ""
	return cfg
}

func parseIntList(raw string) []int {
	var out []int
	for _, part := range strings.Split(raw, ",") {
		part = strings.TrimSpace(part)
		if part == "" {
			continue
		}
		if n, err := strconv.Atoi(part); err == nil && n > 0 {
			out = append(out, n)
		}
	}
	return out
}

func envFirst(keys []string, fallback string) string {
	for _, key := range keys {
		if v := strings.TrimSpace(os.Getenv(key)); v != "" {
			return v
		}
	}
	return fallback
}

func envIntFirst(keys []string, fallback int) int {
	for _, key := range keys {
		v := strings.TrimSpace(os.Getenv(key))
		if v == "" {
			continue
		}
		n, err := strconv.Atoi(v)
		if err != nil {
			return fallback
		}
		return n
	}
	return fallback
}

func envBoolFirst(keys []string, fallback bool) bool {
	for _, key := range keys {
		v := strings.TrimSpace(strings.ToLower(os.Getenv(key)))
		if v == "" {
			continue
		}
		switch v {
		case "1", "true", "yes", "on":
			return true
		case "0", "false", "no", "off":
			return false
		default:
			return fallback
		}
	}
	return fallback
}
