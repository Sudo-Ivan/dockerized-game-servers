package schedule

import (
	"context"
	"fmt"
	"log"
	"strconv"
	"strings"
	"sync"
	"time"

	"gameserverpanel/internal/game"
)

type Restarter struct {
	atLocal   string
	warnMins  []int
	mgr       game.Manager
	announce  game.Announcer
	now       func() time.Time
	mu        sync.Mutex
	warnedDay map[string]bool
}

func NewRestarter(at string, warn []int, mgr game.Manager, announce game.Announcer) *Restarter {
	if announce == nil {
		announce = game.NoopAnnouncer{}
	}
	return &Restarter{
		atLocal:   at,
		warnMins:  warn,
		mgr:       mgr,
		announce:  announce,
		now:       time.Now,
		warnedDay: make(map[string]bool),
	}
}

func (r *Restarter) Enabled() bool {
	return strings.TrimSpace(r.atLocal) != ""
}

func (r *Restarter) Start(ctx context.Context) {
	if !r.Enabled() {
		return
	}
	go func() {
		ticker := time.NewTicker(time.Minute)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case t := <-ticker.C:
				r.tick(t)
			}
		}
	}()
}

func (r *Restarter) tick(now time.Time) {
	hour, minute, ok := parseClock(r.atLocal)
	if !ok {
		return
	}
	dayKey := now.Format("2006-01-02")
	restartAt := time.Date(now.Year(), now.Month(), now.Day(), hour, minute, 0, 0, now.Location())

	for _, mins := range r.warnMins {
		warnAt := restartAt.Add(-time.Duration(mins) * time.Minute)
		key := fmt.Sprintf("%s:%d", dayKey, mins)
		if now.After(warnAt) && now.Before(restartAt) {
			r.mu.Lock()
			already := r.warnedDay[key]
			if !already {
				r.warnedDay[key] = true
			}
			r.mu.Unlock()
			if !already && r.mgr.Running() {
				msg := fmt.Sprintf("Server restart in %d minutes", mins)
				_ = r.announce.Broadcast(msg)
				log.Printf("scheduled restart warning: %s", msg)
			}
		}
	}

	if now.Hour() == hour && now.Minute() == minute {
		r.mu.Lock()
		key := dayKey + ":restart"
		if r.warnedDay[key] {
			r.mu.Unlock()
			return
		}
		r.warnedDay[key] = true
		r.mu.Unlock()
		log.Printf("scheduled restart triggered at %s", r.atLocal)
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Minute)
		defer cancel()
		if err := r.mgr.Restart(ctx); err != nil {
			log.Printf("scheduled restart failed: %v", err)
		}
	}

	if now.Hour() == 0 && now.Minute() == 0 {
		r.mu.Lock()
		r.warnedDay = make(map[string]bool)
		r.mu.Unlock()
	}
}

func parseClock(raw string) (int, int, bool) {
	parts := strings.Split(strings.TrimSpace(raw), ":")
	if len(parts) != 2 {
		return 0, 0, false
	}
	h, err1 := strconv.Atoi(parts[0])
	m, err2 := strconv.Atoi(parts[1])
	if err1 != nil || err2 != nil || h < 0 || h > 23 || m < 0 || m > 59 {
		return 0, 0, false
	}
	return h, m, true
}
