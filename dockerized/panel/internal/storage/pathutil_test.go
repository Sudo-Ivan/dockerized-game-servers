package storage

import (
	"path/filepath"
	"testing"
)

func TestWithinBase(t *testing.T) {
	base := filepath.Clean("/tmp/arma")
	if err := WithinBase(base, filepath.Join(base, "configs/server.cfg")); err != nil {
		t.Fatal(err)
	}
	if err := WithinBase(base, "/etc/passwd"); err == nil {
		t.Fatal("expected rejection outside base")
	}
}
