package auth

import (
	"testing"
	"time"
)

func TestLoginLimiterLockout(t *testing.T) {
	l := NewLoginLimiter(3, time.Minute, 2*time.Minute)
	now := time.Now()
	ip := "10.0.0.1"
	for range 3 {
		l.RecordFailure(ip, now)
	}
	ok, _ := l.Allowed(ip, now)
	if ok {
		t.Fatal("expected lockout")
	}
	l.RecordSuccess(ip)
	ok, _ = l.Allowed(ip, now)
	if !ok {
		t.Fatal("expected allowed after success")
	}
}
