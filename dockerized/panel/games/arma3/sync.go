package arma3

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"

	"gameserverpanel/internal/storage"
)

type SyncState string

const (
	SyncIdle       SyncState = "idle"
	SyncRunning    SyncState = "running"
	SyncDone       SyncState = "done"
	SyncFailed     SyncState = "failed"
	SyncNeedsGuard SyncState = "needs_guard"
)

type SyncProgress struct {
	State   SyncState
	Lines   []string
	ModList string
	Error   string
}

type syncTracker struct {
	mu      sync.RWMutex
	state   SyncState
	lines   []string
	modList string
	err     string
	guard   string
}

func newSyncTracker() *syncTracker {
	return &syncTracker{state: SyncIdle}
}

func (t *syncTracker) append(line string) {
	t.mu.Lock()
	defer t.mu.Unlock()
	t.lines = append(t.lines, line)
	if len(t.lines) > 500 {
		t.lines = t.lines[len(t.lines)-500:]
	}
}

func (t *syncTracker) snapshot() SyncProgress {
	t.mu.RLock()
	defer t.mu.RUnlock()
	lines := make([]string, len(t.lines))
	copy(lines, t.lines)
	return SyncProgress{
		State:   t.state,
		Lines:   lines,
		ModList: t.modList,
		Error:   t.err,
	}
}

func (t *syncTracker) setState(state SyncState) {
	t.mu.Lock()
	defer t.mu.Unlock()
	t.state = state
}

func (t *syncTracker) finish(modList, errMsg string, needsGuard bool) {
	t.mu.Lock()
	defer t.mu.Unlock()
	t.modList = modList
	t.err = errMsg
	if needsGuard {
		t.state = SyncNeedsGuard
		return
	}
	if errMsg != "" {
		t.state = SyncFailed
		return
	}
	t.state = SyncDone
}

func NeedsSteamGuard(output string) bool {
	lower := strings.ToLower(output)
	needles := []string{
		"steam guard",
		"two factor",
		"twofactor",
		"accountlogondeniedneedtwofactor",
		"invalidloginauthcode",
		"auth_code",
		"steAM_GUARD_CODE",
	}
	for _, n := range needles {
		if strings.Contains(lower, strings.ToLower(n)) {
			return true
		}
	}
	return false
}

func runWorkshopSync(ctx context.Context, cfg configLike, guardCode string, onLine func(string)) (string, error) {
	if _, err := os.Stat(cfg.ModlistPath()); err != nil {
		return buildModList(cfg, ""), nil
	}
	if strings.TrimSpace(cfg.SteamUser()) == "" || strings.EqualFold(cfg.SteamUser(), "anonymous") || strings.TrimSpace(cfg.SteamPass()) == "" {
		return "", fmt.Errorf("modlist requires STEAM_USERNAME and STEAM_PASSWORD")
	}
	if err := storage.WithinBase(cfg.AramaPath(), cfg.ModlistPath()); err != nil {
		return "", err
	}
	cmd := exec.CommandContext(ctx, "python3", "/home/arma3/sync_mods.py", cfg.ModlistPath()) // #nosec G204 -- modlist path validated under ARMA_DIR
	cmd.Env = append(os.Environ(),
		"STEAM_USERNAME="+cfg.SteamUser(),
		"STEAM_PASSWORD="+cfg.SteamPass(),
		"STEAM_GUARD_CODE="+guardCode,
		"ARMA_DIR="+cfg.AramaPath(),
	)
	out, err := cmd.CombinedOutput()
	text := strings.TrimSpace(string(out))
	if onLine != nil {
		for _, line := range strings.Split(text, "\n") {
			if line != "" {
				onLine(line)
			}
		}
	}
	if err != nil {
		if NeedsSteamGuard(text) {
			return "", &SteamGuardError{Output: text}
		}
		return "", fmt.Errorf("workshop sync failed: %s", text)
	}
	modList := linkWorkshopMods(cfg, strings.Fields(text), onLine)
	return buildModList(cfg, modList), nil
}

func linkWorkshopMods(cfg configLike, ids []string, onLine func(string)) string {
	modList := ""
	for _, id := range ids {
		src := filepath.Join(cfg.AramaPath(), "workshop", id)
		if _, err := os.Stat(src); err != nil {
			continue
		}
		link := filepath.Join(cfg.AramaPath(), "@"+id)
		_ = os.RemoveAll(link)
		_ = os.Symlink(src, link)
		if onLine != nil {
			onLine("linked @" + id)
		}
		if modList == "" {
			modList = "@" + id
		} else {
			modList += ";@" + id
		}
	}
	return modList
}

func buildModList(cfg configLike, workshop string) string {
	modList := workshop
	if cfg.CDLC() != "" {
		if modList == "" {
			modList = cfg.CDLC()
		} else {
			modList += ";" + cfg.CDLC()
		}
	}
	if cfg.ExtraMods() != "" {
		if modList == "" {
			modList = cfg.ExtraMods()
		} else {
			modList += ";" + cfg.ExtraMods()
		}
	}
	return modList
}

type SteamGuardError struct {
	Output string
}

func (e *SteamGuardError) Error() string {
	return "steam guard code required"
}

type configLike interface {
	AramaPath() string
	ModlistPath() string
	SteamUser() string
	SteamPass() string
	CDLC() string
	ExtraMods() string
}
