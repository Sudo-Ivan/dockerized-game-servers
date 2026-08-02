package auth

import (
	"net"
	"net/http"
	"strings"
	"sync"
	"time"
)

type LoginLimiter struct {
	mu       sync.Mutex
	attempts map[string][]time.Time
	locked   map[string]time.Time

	maxAttempts int
	window      time.Duration
	lockout     time.Duration
}

func NewLoginLimiter(maxAttempts int, window, lockout time.Duration) *LoginLimiter {
	if maxAttempts < 1 {
		maxAttempts = 5
	}
	if window <= 0 {
		window = 15 * time.Minute
	}
	if lockout <= 0 {
		lockout = 15 * time.Minute
	}
	return &LoginLimiter{
		attempts:    make(map[string][]time.Time),
		locked:      make(map[string]time.Time),
		maxAttempts: maxAttempts,
		window:      window,
		lockout:     lockout,
	}
}

func ClientIP(r *http.Request) string {
	if xff := strings.TrimSpace(r.Header.Get("X-Forwarded-For")); xff != "" {
		parts := strings.Split(xff, ",")
		return strings.TrimSpace(parts[0])
	}
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}

func (l *LoginLimiter) Allowed(ip string, now time.Time) (bool, time.Duration) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.prune(now)
	if until, ok := l.locked[ip]; ok {
		if now.Before(until) {
			return false, until.Sub(now)
		}
		delete(l.locked, ip)
	}
	return true, 0
}

func (l *LoginLimiter) RecordFailure(ip string, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.prune(now)
	l.attempts[ip] = append(l.attempts[ip], now)
	if len(l.attempts[ip]) >= l.maxAttempts {
		l.locked[ip] = now.Add(l.lockout)
		delete(l.attempts, ip)
	}
}

func (l *LoginLimiter) RecordSuccess(ip string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	delete(l.attempts, ip)
	delete(l.locked, ip)
}

func (l *LoginLimiter) prune(now time.Time) {
	cutoff := now.Add(-l.window)
	for ip, times := range l.attempts {
		kept := times[:0]
		for _, t := range times {
			if t.After(cutoff) {
				kept = append(kept, t)
			}
		}
		if len(kept) == 0 {
			delete(l.attempts, ip)
		} else {
			l.attempts[ip] = kept
		}
	}
	for ip, until := range l.locked {
		if !now.Before(until) {
			delete(l.locked, ip)
		}
	}
}
