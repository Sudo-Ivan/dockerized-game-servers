package game

import (
	"context"
	"time"
)

type State string

const (
	StateStopped  State = "stopped"
	StateStarting State = "starting"
	StateRunning  State = "running"
	StateStopping State = "stopping"
)

type Status struct {
	State   State
	PID     int
	Uptime  string
	Detail  string
	LastErr string
	Logs    []string
}

type Manager interface {
	Start(ctx context.Context) error
	Stop(timeout time.Duration) error
	Restart(ctx context.Context) error
	Running() bool
	Status() Status
}

type Announcer interface {
	Broadcast(message string) error
}

type NoopAnnouncer struct{}

func (NoopAnnouncer) Broadcast(string) error { return nil }
