package arma3

import (
	"os"
	"strconv"
	"strings"

	"gameserverpanel/internal/panelconfig"
)

type Config struct {
	panel panelconfig.Config

	ArmaDir       string
	ConfigDir     string
	ProfilesDir   string
	CacheDir      string
	ModlistFile   string
	ServerCfgFile string
	MissionsDir   string
	KeysDir       string

	Port      int
	World     string
	AutoStart bool

	SteamUsername  string
	SteamPassword  string
	SteamGuardCode string
	ArmaAppID      string
	CDLC           string
	ExtraMods      string

	RconHost     string
	RconPort     int
	RconPassword string
}

func LoadConfig(panel panelconfig.Config) Config {
	cfg := Config{
		panel:          panel,
		ArmaDir:        env("ARMA_DIR", "/home/arma3/server"),
		ConfigDir:      env("ARMA_CONFIG_DIR", "/home/arma3/configs"),
		ProfilesDir:    env("ARMA_PROFILES_DIR", "/home/arma3/profiles"),
		CacheDir:       env("ARMA_CACHE_DIR", "/home/arma3/cache"),
		ModlistFile:    env("MODLIST_FILE", "/home/arma3/server/modlist.html"),
		Port:           envInt("ARMA_PORT", 2302),
		World:          env("ARMA_WORLD", "empty"),
		AutoStart:      panel.AutoStart,
		SteamUsername:  strings.TrimSpace(os.Getenv("STEAM_USERNAME")),
		SteamPassword:  os.Getenv("STEAM_PASSWORD"),
		SteamGuardCode: os.Getenv("STEAM_GUARD_CODE"),
		ArmaAppID:      env("ARMA_APP_ID", "233780"),
		CDLC:           os.Getenv("CDLC"),
		ExtraMods:      os.Getenv("EXTRA_MODS"),
		RconHost:       env("ARMA_RCON_HOST", "127.0.0.1"),
		RconPort:       envInt("ARMA_RCON_PORT", 0),
		RconPassword:   os.Getenv("ARMA_RCON_PASSWORD"),
	}
	cfg.ServerCfgFile = env("ARMA_SERVER_CFG", cfg.ConfigDir+"/server.cfg")
	cfg.MissionsDir = env("ARMA_MISSIONS_DIR", cfg.ArmaDir+"/mpmissions")
	cfg.KeysDir = cfg.ArmaDir + "/keys"
	if cfg.RconPort == 0 {
		cfg.RconPort = cfg.Port + 3
	}
	return cfg
}

func (c Config) Panel() panelconfig.Config { return c.panel }

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
