package plugins

import (
	"context"
	"sync"
)

type EventType string

const (
	EventServerStart      EventType = "server.start"
	EventServerStop       EventType = "server.stop"
	EventWorkshopSyncDone EventType = "workshop.sync.done"
	EventWorkshopSyncFail EventType = "workshop.sync.fail"
	EventLoginFailed      EventType = "auth.login.failed"
	EventScheduledRestart EventType = "schedule.restart"
)

type Event struct {
	Type EventType
	Data map[string]string
}

type Plugin interface {
	Name() string
	Init(*Registry) error
}

type Hook func(ctx context.Context, event Event)

type Registry struct {
	mu    sync.RWMutex
	hooks map[EventType][]Hook
}

func NewRegistry() *Registry {
	return &Registry{hooks: make(map[EventType][]Hook)}
}

func (r *Registry) On(event EventType, hook Hook) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.hooks[event] = append(r.hooks[event], hook)
}

func (r *Registry) Emit(ctx context.Context, event Event) {
	r.mu.RLock()
	hooks := append([]Hook(nil), r.hooks[event.Type]...)
	r.mu.RUnlock()
	for _, hook := range hooks {
		hook(ctx, event)
	}
}

func LoadAll(reg *Registry, plugins ...Plugin) error {
	for _, p := range plugins {
		if err := p.Init(reg); err != nil {
			return err
		}
	}
	return nil
}
