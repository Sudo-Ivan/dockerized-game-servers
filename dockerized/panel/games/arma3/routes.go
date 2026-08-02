package arma3

import (
	"context"
	"encoding/json"
	"fmt"
	"html"
	"io"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"gameserverpanel/games/arma3/armastorage"
	"gameserverpanel/games/arma3/rcon"
	"gameserverpanel/internal/game"
	"gameserverpanel/internal/plugins"
	"gameserverpanel/internal/storage"
)

func registerRoutes(mux *http.ServeMux, host game.Host, mod *Module) {
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) { handleDashboard(host, mod, w, r) })
	mux.HandleFunc("/status", func(w http.ResponseWriter, r *http.Request) { handleStatus(host, mod, w, r) })
	mux.HandleFunc("/mods/sync", func(w http.ResponseWriter, r *http.Request) { handleModsSync(host, mod, w, r) })
	mux.HandleFunc("/mods/sync/status", func(w http.ResponseWriter, r *http.Request) { handleModsSyncStatus(host, mod, w, r) })
	mux.HandleFunc("/mods/steam-guard", func(w http.ResponseWriter, r *http.Request) { handleSteamGuard(host, mod, w, r) })
	mux.HandleFunc("/missions", func(w http.ResponseWriter, r *http.Request) { handleMissions(host, mod, w, r) })
	mux.HandleFunc("/missions/upload", func(w http.ResponseWriter, r *http.Request) { handleMissionUpload(host, mod, w, r) })
	mux.HandleFunc("/missions/rename", func(w http.ResponseWriter, r *http.Request) { handleMissionRename(host, mod, w, r) })
	mux.HandleFunc("/missions/delete", func(w http.ResponseWriter, r *http.Request) { handleMissionDelete(host, mod, w, r) })
	mux.HandleFunc("/missions/activate", func(w http.ResponseWriter, r *http.Request) { handleMissionActivate(host, mod, w, r) })
	mux.HandleFunc("/config", func(w http.ResponseWriter, r *http.Request) { handleConfig(host, mod, w, r) })
	mux.HandleFunc("/config/save", func(w http.ResponseWriter, r *http.Request) { handleConfigSave(host, mod, w, r) })
	mux.HandleFunc("/config/form", func(w http.ResponseWriter, r *http.Request) { handleConfigFormSave(host, mod, w, r) })
	mux.HandleFunc("/modlist", func(w http.ResponseWriter, r *http.Request) { handleModlist(host, mod, w, r) })
	mux.HandleFunc("/modlist/upload", func(w http.ResponseWriter, r *http.Request) { handleModlistUpload(host, mod, w, r) })
	mux.HandleFunc("/modlist/delete", func(w http.ResponseWriter, r *http.Request) { handleModlistDelete(host, mod, w, r) })
	mux.HandleFunc("/rcon", func(w http.ResponseWriter, r *http.Request) { handleRcon(host, mod, w, r) })
	mux.HandleFunc("/rcon/send", func(w http.ResponseWriter, r *http.Request) { handleRconSend(host, mod, w, r) })
	mux.HandleFunc("/rcon/players", func(w http.ResponseWriter, r *http.Request) { handleRconPlayers(host, mod, w, r) })
	mux.HandleFunc("/rcon/kick", func(w http.ResponseWriter, r *http.Request) { handleRconKick(host, mod, w, r) })
	mux.HandleFunc("/rcon/ban", func(w http.ResponseWriter, r *http.Request) { handleRconBan(host, mod, w, r) })
	mux.HandleFunc("/rcon/say", func(w http.ResponseWriter, r *http.Request) { handleRconSay(host, mod, w, r) })
	mux.HandleFunc("/rcon/mission", func(w http.ResponseWriter, r *http.Request) { handleRconMission(host, mod, w, r) })
	mux.HandleFunc("/logs", func(w http.ResponseWriter, r *http.Request) { handleLogs(host, mod, w, r) })
}

func writeSSESnapshot(host game.Host, mod *Module, w http.ResponseWriter, flush func()) {
	syncSnap := mod.mgr.SyncSnapshot()
	syncPayload, _ := json.Marshal(syncSnap)
	fmt.Fprintf(w, "event: sync\ndata: %s\n\n", syncPayload)

	logs, _ := tailLogs(mod, "process", "", 50)
	logPayload, _ := json.Marshal(logs)
	fmt.Fprintf(w, "event: logs\ndata: %s\n\n", logPayload)

	if mod.mgr.Running() {
		if resp, err := mod.rcon.Command("players"); err == nil {
			players := rcon.ParsePlayers(resp)
			playerPayload, _ := json.Marshal(players)
			fmt.Fprintf(w, "event: players\ndata: %s\n\n", playerPayload)
		}
	}
	flush()
}

type page struct {
	Title       string
	PanelTitle  string
	AuthEnabled bool
	Nav         []game.NavItem
	Flash       string
	Error       string
}

func basePage(host game.Host, title string) page {
	return page{
		Title:       title,
		PanelTitle:  host.PanelTitle(),
		AuthEnabled: host.AuthEnabled(),
		Nav:         host.GameModule().NavItems(),
	}
}

type statusView struct {
	State   string
	PID     int
	Uptime  string
	ModList string
	LastErr string
	Logs    []string
}

func statusFromMgr(mod *Module) statusView {
	st := mod.mgr.Snapshot()
	return statusView{
		State:   string(st.State),
		PID:     st.PID,
		Uptime:  st.Uptime,
		ModList: st.ModList,
		LastErr: st.LastErr,
		Logs:    st.Logs,
	}
}

func handleDashboard(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	host.Render(w, "dashboard.html", struct {
		page
		Status statusView
	}{page: basePage(host, "Dashboard"), Status: statusFromMgr(mod)})
}

func handleStatus(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	host.RenderPartial(w, "partials/status.html", statusFromMgr(mod))
}

func tailLogs(mod *Module, source, filter string, limit int) ([]armastorage.LogLine, error) {
	st := mod.mgr.Snapshot()
	return armastorage.TailLogs(mod.cfg.ProfilesDir, st.Logs, source, filter, limit)
}

func handleLogs(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	source := r.URL.Query().Get("source")
	filter := r.URL.Query().Get("filter")
	lines, err := tailLogs(mod, source, filter, 200)
	data := struct {
		page
		Lines  []armastorage.LogLine
		Source string
		Filter string
		Err    string
	}{page: basePage(host, "Logs"), Lines: lines, Source: source, Filter: filter}
	if err != nil {
		data.Err = err.Error()
	}
	if host.IsHTMX(r) || r.Header.Get("Accept") == "text/html" && r.URL.Query().Get("partial") == "1" {
		host.RenderPartial(w, "partials/log_lines.html", data)
		return
	}
	host.Render(w, "logs.html", data)
}

func handleMissions(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	cfgText, _ := storage.ReadFile(mod.cfg.ServerCfgFile)
	active := armastorage.ActiveMissionTemplate(cfgText)
	missions, err := armastorage.ListMissions(mod.cfg.MissionsDir, active)
	data := struct {
		page
		Missions []armastorage.Mission
		Active   string
		Err      string
	}{page: basePage(host, "Missions"), Missions: missions, Active: active}
	if err != nil {
		data.Err = err.Error()
	}
	host.Render(w, "missions.html", data)
}

func handleMissionUpload(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := parseBoundedMultipart(w, r, mod.cfg.Panel().MaxUpload); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	file, header, err := r.FormFile("mission")
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	defer file.Close()
	if err := armastorage.SaveMission(mod.cfg.MissionsDir, header.Filename, file); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	http.Redirect(w, r, "/missions", http.StatusSeeOther)
}

func handleMissionRename(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	if err := armastorage.RenameMission(mod.cfg.MissionsDir, r.FormValue("old_name"), r.FormValue("new_name")); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	http.Redirect(w, r, "/missions", http.StatusSeeOther)
}

func handleMissionDelete(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	if err := armastorage.RemoveMission(mod.cfg.MissionsDir, r.FormValue("name")); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	http.Redirect(w, r, "/missions", http.StatusSeeOther)
}

func handleMissionActivate(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	templateName := r.FormValue("template")
	cfgText, err := storage.ReadFile(mod.cfg.ServerCfgFile)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	updated := armastorage.SetActiveMissionTemplate(cfgText, templateName)
	if err := storage.WriteFile(mod.cfg.ServerCfgFile, updated); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if mod.mgr.Running() && templateName != "" {
		_, _ = mod.rcon.Command("mission " + templateName)
	}
	http.Redirect(w, r, "/missions", http.StatusSeeOther)
}

func handleModsSync(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Minute)
		defer cancel()
		mod.mgr.StartSync(ctx, mod.cfg.SteamGuardCode)
		host.Emit("sync", mod.mgr.SyncSnapshot())
	}()
	host.RenderPartial(w, "partials/sync_status.html", mod.mgr.SyncSnapshot())
}

func handleModsSyncStatus(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	host.RenderPartial(w, "partials/sync_status.html", mod.mgr.SyncSnapshot())
}

func handleSteamGuard(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	code := r.FormValue("steam_guard_code")
	mod.mgr.SetSteamGuardCode(code)
	ctx, cancel := context.WithTimeout(r.Context(), 30*time.Minute)
	defer cancel()
	err := mod.mgr.SyncMods(ctx, code)
	snap := mod.mgr.SyncSnapshot()
	if err != nil {
		var guardErr *SteamGuardError
		if !errorsAsSteamGuard(err, &guardErr) {
			host.EmitPlugin(string(plugins.EventWorkshopSyncFail), map[string]string{"error": err.Error()})
		}
	} else {
		host.EmitPlugin(string(plugins.EventWorkshopSyncDone), map[string]string{"mods": snap.ModList})
	}
	if host.IsHTMX(r) {
		host.RenderPartial(w, "partials/sync_status.html", snap)
		return
	}
	http.Redirect(w, r, "/modlist", http.StatusSeeOther)
}

func errorsAsSteamGuard(err error, target **SteamGuardError) bool {
	if err == nil {
		return false
	}
	ge, ok := err.(*SteamGuardError)
	if !ok {
		return false
	}
	*target = ge
	return true
}

func handleConfig(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	text, err := storage.ReadFile(mod.cfg.ServerCfgFile)
	form := armastorage.ParseServerCfg(text)
	tab := r.URL.Query().Get("tab")
	if tab == "" {
		tab = "form"
	}
	data := struct {
		page
		ConfigText string
		Form       armastorage.ServerCfg
		Path       string
		Tab        string
		Err        string
	}{page: basePage(host, "Server Config"), ConfigText: text, Form: form, Path: mod.cfg.ServerCfgFile, Tab: tab}
	if err != nil {
		data.Err = err.Error()
	}
	host.Render(w, "config.html", data)
}

func handleConfigSave(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	content := r.FormValue("config")
	if err := storage.WriteFile(mod.cfg.ServerCfgFile, content); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if host.IsHTMX(r) {
		_, _ = w.Write([]byte(`<div class="flash ok">Config saved. Restart server to apply some changes.</div>`))
		return
	}
	http.Redirect(w, r, "/config?tab=advanced", http.StatusSeeOther)
}

func handleConfigFormSave(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	text, err := storage.ReadFile(mod.cfg.ServerCfgFile)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	form := armastorage.ServerCfg{
		Hostname:              r.FormValue("hostname"),
		Password:              r.FormValue("password"),
		PasswordAdmin:         r.FormValue("passwordAdmin"),
		ServerCommandPassword: r.FormValue("serverCommandPassword"),
		MOTD:                  r.FormValue("motd"),
		MOTDInterval:          parseFormInt(r, "motdInterval", 30),
		MaxPlayers:            parseFormInt(r, "maxPlayers", 32),
		KickDuplicate:         parseFormBool(r, "kickDuplicate"),
		VerifySignatures:      parseFormInt(r, "verifySignatures", 2),
		AllowedFilePatching:   parseFormInt(r, "allowedFilePatching", 0),
		DisconnectTimeout:     parseFormInt(r, "disconnectTimeout", 90),
		BattlEye:              parseFormBool(r, "battlEye"),
		Persistent:            parseFormBool(r, "persistent"),
		DisableVoN:            parseFormBool(r, "disableVoN"),
		VonCodec:              parseFormInt(r, "vonCodec", 1),
		Template:              r.FormValue("template"),
	}
	updated := armastorage.ApplyServerCfgForm(text, form)
	if err := storage.WriteFile(mod.cfg.ServerCfgFile, updated); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if host.IsHTMX(r) {
		_, _ = w.Write([]byte(`<div class="flash ok">Config saved from form.</div>`))
		return
	}
	http.Redirect(w, r, "/config?tab=form", http.StatusSeeOther)
}

func handleModlist(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	text, err := storage.ReadFile(mod.cfg.ModlistFile)
	exists := err == nil && strings.TrimSpace(text) != ""
	sync := mod.mgr.SyncSnapshot()
	data := struct {
		page
		Path   string
		Text   string
		Exists bool
		Sync   SyncProgress
		Err    string
	}{page: basePage(host, "Modlist"), Path: mod.cfg.ModlistFile, Text: text, Exists: exists, Sync: sync}
	if err != nil && !os.IsNotExist(err) {
		data.Err = err.Error()
	}
	host.Render(w, "modlist.html", data)
}

func handleModlistUpload(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := parseBoundedMultipart(w, r, 8<<20); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	file, _, err := r.FormFile("modlist")
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	defer file.Close()
	if err := storage.WriteFile(mod.cfg.ModlistFile, readAll(file)); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/modlist", http.StatusSeeOther)
}

func handleModlistDelete(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := os.Remove(mod.cfg.ModlistFile); err != nil && !os.IsNotExist(err) {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/modlist", http.StatusSeeOther)
}

func handleRcon(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	players := []rcon.Player{}
	playerErr := ""
	missions := []string{}
	if mod.mgr.Running() {
		if resp, err := mod.rcon.Command("players"); err == nil {
			players = rcon.ParsePlayers(resp)
		} else {
			playerErr = err.Error()
		}
		if resp, err := mod.rcon.Command("missions"); err == nil {
			missions = rcon.ParseMissions(resp)
		}
	}
	host.Render(w, "rcon.html", struct {
		page
		Host     string
		Port     int
		Players  []rcon.Player
		Missions []string
		Error    string
	}{page: basePage(host, "RCON"), Host: mod.cfg.RconHost, Port: mod.cfg.RconPort, Players: players, Missions: missions, Error: playerErr})
}

func handleRconSend(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	cmd := strings.TrimSpace(r.FormValue("command"))
	if cmd == "" {
		http.Error(w, "empty command", http.StatusBadRequest)
		return
	}
	resp, err := mod.rcon.Command(cmd)
	data := struct {
		Command  string
		Response string
		Error    string
	}{Command: cmd, Response: resp}
	if err != nil {
		data.Error = err.Error()
	}
	if host.IsHTMX(r) {
		host.RenderPartial(w, "partials/rcon_result.html", data)
		return
	}
	host.Render(w, "rcon.html", struct {
		page
		Host     string
		Port     int
		Command  string
		Response string
		Error    string
	}{page: basePage(host, "RCON"), Host: mod.cfg.RconHost, Port: mod.cfg.RconPort, Command: cmd, Response: resp, Error: data.Error})
}

func handleRconPlayers(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	resp, err := mod.rcon.Command("players")
	data := struct {
		Players []rcon.Player
		Error   string
	}{}
	if err != nil {
		data.Error = err.Error()
	} else {
		data.Players = rcon.ParsePlayers(resp)
	}
	host.RenderPartial(w, "partials/players.html", data)
}

func handleRconKick(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	id := strings.TrimSpace(r.FormValue("player_id"))
	_, _ = mod.rcon.Command("kick " + id)
	handleRconPlayers(host, mod, w, r)
}

func handleRconBan(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	id := strings.TrimSpace(r.FormValue("player_id"))
	_, _ = mod.rcon.Command("ban " + id)
	handleRconPlayers(host, mod, w, r)
}

func handleRconSay(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	msg := strings.TrimSpace(r.FormValue("message"))
	if msg == "" {
		http.Error(w, "empty message", http.StatusBadRequest)
		return
	}
	_, err := mod.rcon.Command("say -1 " + msg)
	if host.IsHTMX(r) {
		if err != nil {
			writeFlashErr(w, err)
		} else {
			writeFlashOK(w, "Message sent")
		}
		return
	}
	http.Redirect(w, r, "/rcon", http.StatusSeeOther)
}

func handleRconMission(host game.Host, mod *Module, w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	name := strings.TrimSpace(r.FormValue("mission"))
	_, err := mod.rcon.Command("mission " + name)
	if host.IsHTMX(r) {
		if err != nil {
			writeFlashErr(w, err)
		} else {
			writeFlashOK(w, "Mission change requested")
		}
		return
	}
	http.Redirect(w, r, "/rcon", http.StatusSeeOther)
}

func writeFlashOK(w http.ResponseWriter, message string) {
	_, _ = w.Write([]byte(`<div class="flash ok">` + html.EscapeString(message) + `</div>`))
}

func writeFlashErr(w http.ResponseWriter, err error) {
	_, _ = w.Write([]byte(`<div class="flash err">` + html.EscapeString(err.Error()) + `</div>`))
}

func parseBoundedMultipart(w http.ResponseWriter, r *http.Request, limit int64) error {
	r.Body = http.MaxBytesReader(w, r.Body, limit)
	return r.ParseMultipartForm(limit) // #nosec G120
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

func readAll(r io.Reader) string {
	b, _ := io.ReadAll(r)
	return string(b)
}
