package auth

import "testing"

func TestIPAllowed(t *testing.T) {
	if !IPAllowed("127.0.0.1", nil) {
		t.Fatal("empty allowlist should allow all")
	}
	if IPAllowed("8.8.8.8", []string{"127.0.0.1"}) {
		t.Fatal("unexpected allow")
	}
	if !IPAllowed("10.1.2.3", []string{"10.1.2.0/24"}) {
		t.Fatal("expected cidr match")
	}
}
