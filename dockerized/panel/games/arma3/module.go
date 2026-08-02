package arma3

import (
	"embed"
	"html/template"
	"io"
	"io/fs"
	"net/http"
	"strings"

	"gameserverpanel/games/arma3/armastorage"
	"gameserverpanel/games/arma3/rcon"
	"gameserverpanel/internal/game"
	"gameserverpanel/internal/panelconfig"
	"gameserverpanel/internal/storage"
)

//go:embed web/templates/*.html web/templates/partials/*.html
var templateFS embed.FS

type Module struct {
	panel panelconfig.Config
	cfg   Config
	mgr   *Manager
	rcon  *rcon.Client
}

func NewModule(panel panelconfig.Config) *Module {
	cfg := LoadConfig(panel)
	return &Module{
		panel: panel,
		cfg:   cfg,
		mgr:   NewManager(cfg),
		rcon:  rcon.New(cfg.RconHost, cfg.RconPort, cfg.RconPassword),
	}
}

func init() {
	game.Register("arma3", func() game.Module {
		return NewModule(panelconfig.Load())
	})
}

func (m *Module) ID() string { return "arma3" }

func (m *Module) Title() string {
	if t := strings.TrimSpace(m.panel.Title); t != "" {
		return t
	}
	return "Arma 3"
}
func (m *Module) Config() Config            { return m.cfg }
func (m *Module) Manager() game.Manager     { return m.mgr }
func (m *Module) Announcer() game.Announcer { return m.rcon }
func (m *Module) AutoStart() bool           { return m.cfg.AutoStart }
func (m *Module) Runtime() *Manager         { return m.mgr }
func (m *Module) Rcon() *rcon.Client        { return m.rcon }

func (m *Module) EnsureDirs() error {
	for _, dir := range []string{m.cfg.ArmaDir, m.cfg.ConfigDir, m.cfg.ProfilesDir, m.cfg.CacheDir, m.cfg.MissionsDir, m.cfg.KeysDir} {
		if err := storage.EnsureDir(dir); err != nil {
			return err
		}
	}
	return nil
}

func (m *Module) Backup() game.Backup { return m }

func (m *Module) FilenamePrefix() string { return "arma3-backup" }

func (m *Module) WriteArchive(w io.Writer) error {
	return armastorage.CreateBackup(w, armastorage.BackupPaths{
		ConfigDir:   m.cfg.ConfigDir,
		MissionsDir: m.cfg.MissionsDir,
		ModlistFile: m.cfg.ModlistFile,
		ServerCfg:   m.cfg.ServerCfgFile,
	})
}

func (m *Module) RestoreArchive(r io.ReaderAt, size int64) error {
	return armastorage.RestoreBackup(r, size, armastorage.RestorePaths{
		ConfigDir:   m.cfg.ConfigDir,
		MissionsDir: m.cfg.MissionsDir,
		ModlistFile: m.cfg.ModlistFile,
	})
}

func (m *Module) TemplateFS() fs.FS {
	sub, _ := fs.Sub(templateFS, "web/templates")
	return sub
}

func (m *Module) TemplateFuncs() template.FuncMap {
	return template.FuncMap{
		"missionBase": func(name string) string {
			return strings.TrimSuffix(strings.TrimSuffix(name, ".PBO"), ".pbo")
		},
	}
}

func (m *Module) NavItems() []game.NavItem {
	return []game.NavItem{
		{Path: "/", Label: "Dashboard"},
		{Path: "/missions", Label: "Missions"},
		{Path: "/config", Label: "Config"},
		{Path: "/modlist", Label: "Modlist"},
		{Path: "/rcon", Label: "RCON"},
		{Path: "/logs", Label: "Logs"},
		{Path: "/backup", Label: "Backup"},
	}
}

func (m *Module) RegisterRoutes(mux *http.ServeMux, host game.Host) {
	registerRoutes(mux, host, m)
}

func (m *Module) SSESnapshot(host game.Host, w http.ResponseWriter, flush func()) {
	writeSSESnapshot(host, m, w, flush)
}
