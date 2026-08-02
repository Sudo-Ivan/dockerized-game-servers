package arma3

import (
	"bufio"
	"context"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"syscall"
	"time"

	"gameserverpanel/internal/game"
	"gameserverpanel/internal/storage"
)

type State string

const (
	StateStopped  State = "stopped"
	StateStarting State = "starting"
	StateRunning  State = "running"
	StateStopping State = "stopping"
)

type Manager struct {
	cfg Config

	mu      sync.RWMutex
	state   State
	cmd     *exec.Cmd
	cancel  context.CancelFunc
	logs    *ringLog
	syncJob *syncTracker
	started time.Time
	lastErr string
	modList string
	guard   string
}

func NewManager(cfg Config) *Manager {
	return &Manager{
		cfg:     cfg,
		state:   StateStopped,
		logs:    newRingLog(400),
		syncJob: newSyncTracker(),
	}
}

func (m *Manager) Config() Config {
	return m.cfg
}

func (m *Manager) Status() game.Status {
	st := m.Snapshot()
	return game.Status{
		State:   game.State(st.State),
		PID:     st.PID,
		Uptime:  st.Uptime,
		Detail:  st.ModList,
		LastErr: st.LastErr,
		Logs:    st.Logs,
	}
}

func (m *Manager) SetSteamGuardCode(code string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.guard = strings.TrimSpace(code)
	m.cfg.SteamGuardCode = m.guard
}

func (m *Manager) SyncSnapshot() SyncProgress {
	return m.syncJob.snapshot()
}

func (m *Manager) Snapshot() Status {
	m.mu.RLock()
	defer m.mu.RUnlock()
	pid := 0
	if m.cmd != nil && m.cmd.Process != nil {
		pid = m.cmd.Process.Pid
	}
	uptime := ""
	if m.state == StateRunning && !m.started.IsZero() {
		uptime = time.Since(m.started).Round(time.Second).String()
	}
	return Status{
		State:   m.state,
		PID:     pid,
		Uptime:  uptime,
		ModList: m.modList,
		LastErr: m.lastErr,
		Logs:    m.logs.Lines(),
	}
}

type Status struct {
	State   State
	PID     int
	Uptime  string
	ModList string
	LastErr string
	Logs    []string
}

func (m *Manager) Start(ctx context.Context) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.state == StateRunning || m.state == StateStarting {
		return errors.New("server already running")
	}
	m.state = StateStarting
	m.lastErr = ""

	modList, err := m.syncModsLocked(ctx, m.guard)
	if err != nil {
		m.state = StateStopped
		m.lastErr = err.Error()
		return err
	}
	m.modList = modList
	return m.startLocked(modList)
}

func (m *Manager) StartSync(ctx context.Context, guardCode string) {
	go m.runSync(ctx, guardCode, false)
}

func (m *Manager) runSync(ctx context.Context, guardCode string, updateRunningMods bool) {
	m.syncJob.setState(SyncRunning)
	m.syncJob.append("workshop sync started")
	modList, err := m.syncModsLocked(ctx, guardCode)
	if err != nil {
		var guardErr *SteamGuardError
		if errors.As(err, &guardErr) {
			m.syncJob.finish("", err.Error(), true)
			return
		}
		m.syncJob.finish("", err.Error(), false)
		return
	}
	m.mu.Lock()
	m.modList = modList
	m.mu.Unlock()
	m.syncJob.finish(modList, "", false)
	m.syncJob.append("workshop sync complete")
	if updateRunningMods {
		m.syncJob.append("restart server to load new mods")
	}
}

func (m *Manager) SyncMods(ctx context.Context, guardCode string) error {
	m.syncJob.setState(SyncRunning)
	modList, err := m.syncModsLocked(ctx, guardCode)
	if err != nil {
		var guardErr *SteamGuardError
		if errors.As(err, &guardErr) {
			m.syncJob.finish("", err.Error(), true)
			return err
		}
		m.syncJob.finish("", err.Error(), false)
		return err
	}
	m.mu.Lock()
	m.modList = modList
	m.mu.Unlock()
	m.syncJob.finish(modList, "", false)
	return nil
}

func (m *Manager) Stop(timeout time.Duration) error {
	m.mu.Lock()
	if m.state != StateRunning && m.state != StateStarting {
		m.mu.Unlock()
		return nil
	}
	m.state = StateStopping
	cmd := m.cmd
	cancel := m.cancel
	m.mu.Unlock()

	if cmd == nil || cmd.Process == nil {
		m.setStopped("")
		return nil
	}

	_ = syscall.Kill(-cmd.Process.Pid, syscall.SIGTERM)
	done := make(chan struct{})
	go func() {
		_, _ = cmd.Process.Wait()
		close(done)
	}()

	select {
	case <-done:
	case <-time.After(timeout):
		_ = syscall.Kill(-cmd.Process.Pid, syscall.SIGKILL)
		<-done
	}
	if cancel != nil {
		cancel()
	}
	m.setStopped("")
	return nil
}

func (m *Manager) Restart(ctx context.Context) error {
	if err := m.Stop(20 * time.Second); err != nil {
		return err
	}
	time.Sleep(2 * time.Second)
	return m.Start(ctx)
}

func (m *Manager) Running() bool {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.state == StateRunning
}

func (m *Manager) setStopped(errMsg string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.state = StateStopped
	m.cmd = nil
	m.cancel = nil
	if errMsg != "" {
		m.lastErr = errMsg
	}
}

func (m *Manager) wait(cmd *exec.Cmd) {
	err := cmd.Wait()
	msg := "server exited"
	if err != nil {
		msg = fmt.Sprintf("server exited: %v", err)
	}
	m.logs.Append(msg)
	m.setStopped(msg)
}

func (m *Manager) pipeLogs(stream string, r io.Reader) {
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		m.logs.Append(stream + ": " + scanner.Text())
	}
}

func (m *Manager) syncModsLocked(ctx context.Context, guardCode string) (string, error) {
	adapter := managerConfigAdapter{m}
	return runWorkshopSync(ctx, adapter, guardCode, m.syncJob.append)
}

func (m *Manager) startLocked(modList string) error {
	args := []string{
		"-config=" + m.cfg.ServerCfgFile,
		fmt.Sprintf("-port=%d", m.cfg.Port),
		"-name=server",
		"-profiles=" + m.cfg.ProfilesDir,
		"-mod=" + modList,
		"-world=" + m.cfg.World,
		"-noSound",
		"-filePatching",
	}

	binary := filepath.Join(m.cfg.ArmaDir, "arma3server_x64")
	if err := storage.WithinBase(m.cfg.ArmaDir, binary); err != nil {
		m.state = StateStopped
		m.lastErr = err.Error()
		return err
	}
	if _, err := os.Stat(binary); err != nil {
		m.state = StateStopped
		m.lastErr = "arma3server_x64 not found"
		return err
	}

	runCtx, cancel := context.WithCancel(context.Background())
	cmd := exec.CommandContext(runCtx, binary, args...) // #nosec G204 -- binary path validated under ARMA_DIR
	cmd.Dir = m.cfg.ArmaDir
	cmd.Env = os.Environ()
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		cancel()
		m.state = StateStopped
		return err
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		cancel()
		m.state = StateStopped
		return err
	}

	if err := cmd.Start(); err != nil {
		cancel()
		m.state = StateStopped
		m.lastErr = err.Error()
		return err
	}

	m.cmd = cmd
	m.cancel = cancel
	m.started = time.Now()
	m.state = StateRunning
	m.logs.Append(fmt.Sprintf("started pid %d mods=%q", cmd.Process.Pid, modList))

	go m.pipeLogs("stdout", stdout)
	go m.pipeLogs("stderr", stderr)
	go m.wait(cmd)
	return nil
}

type managerConfigAdapter struct{ m *Manager }

func (a managerConfigAdapter) AramaPath() string   { return a.m.cfg.ArmaDir }
func (a managerConfigAdapter) ModlistPath() string { return a.m.cfg.ModlistFile }
func (a managerConfigAdapter) SteamUser() string   { return a.m.cfg.SteamUsername }
func (a managerConfigAdapter) SteamPass() string   { return a.m.cfg.SteamPassword }
func (a managerConfigAdapter) CDLC() string        { return a.m.cfg.CDLC }
func (a managerConfigAdapter) ExtraMods() string   { return a.m.cfg.ExtraMods }

type ringLog struct {
	mu    sync.Mutex
	lines []string
	limit int
}

func newRingLog(limit int) *ringLog {
	return &ringLog{limit: limit}
}

func (r *ringLog) Append(line string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.lines = append(r.lines, line)
	if len(r.lines) > r.limit {
		r.lines = r.lines[len(r.lines)-r.limit:]
	}
}

func (r *ringLog) Lines() []string {
	r.mu.Lock()
	defer r.mu.Unlock()
	out := make([]string, len(r.lines))
	copy(out, r.lines)
	return out
}
