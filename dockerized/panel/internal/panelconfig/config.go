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
	port := envInt("PANEL_PORT", DefaultPort)
	cfg := Config{
		GameID:              env("PANEL_GAME", "arma3"),
		Title:               env("PANEL_TITLE", ""),
		Port:                port,
		ListenAddr:          env("PANEL_ADDR", ":"+strconv.Itoa(port)),
		CacheDir:            env("PANEL_CACHE_DIR", "/home/arma3/cache"),
		AutoStart:           envBool("PANEL_AUTO_START", true),
		PanelPass:           env("PANEL_PASSWORD", ""),
		SessionSec:          env("PANEL_SESSION_SECRET", ""),
		LoginMaxAttempts:    envInt("PANEL_LOGIN_MAX_ATTEMPTS", 5),
		LoginWindowSeconds:  envInt("PANEL_LOGIN_WINDOW", 900),
		LoginLockoutSeconds: envInt("PANEL_LOGIN_LOCKOUT", 900),
		ScheduledRestart:    strings.TrimSpace(env("PANEL_SCHEDULED_RESTART", "")),
	}
	cfg.MaxUpload = int64(envInt("PANEL_MAX_UPLOAD", 512)) * 1024 * 1024
	cfg.ScheduledRestartWarn = parseIntList(env("PANEL_SCHEDULED_RESTART_WARN", "15,5,1"))
	if raw := env("PANEL_ALLOWED_IPS", ""); raw != "" {
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

func env(key, fallback string) string {
	if v := strings.TrimSpace(os.Getenv(key)); v != "" {
		return v
	}
	return fallback
}

func envInt(key string, fallback int) int {
	v := strings.TrimSpace(os.Getenv(key))
	if v == "" {
		return fallback
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		return fallback
	}
	return n
}

func envBool(key string, fallback bool) bool {
	v := strings.TrimSpace(strings.ToLower(os.Getenv(key)))
	if v == "" {
		return fallback
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
