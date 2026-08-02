package game

import (
	"embed"
	"html/template"
	"io/fs"
	"net/http"
)

type NavItem struct {
	Path  string
	Label string
}

type Module interface {
	ID() string
	Title() string
	EnsureDirs() error
	Manager() Manager
	Announcer() Announcer
	AutoStart() bool
	Backup() Backup
	TemplateFS() fs.FS
	TemplateFuncs() template.FuncMap
	NavItems() []NavItem
	RegisterRoutes(mux *http.ServeMux, host Host)
	SSESnapshot(host Host, w http.ResponseWriter, flush func())
}

type Host interface {
	PanelTitle() string
	AuthEnabled() bool
	Render(w http.ResponseWriter, name string, data any)
	RenderPartial(w http.ResponseWriter, name string, data any)
	IsHTMX(r *http.Request) bool
	Emit(topic string, payload any)
	EmitPlugin(eventType string, data map[string]string)
	GameModule() Module
}

type TemplateBundle struct {
	FS    embed.FS
	Funcs template.FuncMap
}
