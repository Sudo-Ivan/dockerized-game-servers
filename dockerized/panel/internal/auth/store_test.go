package auth

import (
	"os"
	"path/filepath"
	"testing"
)

func TestLoadOrRotateSessionSecret(t *testing.T) {
	dir := t.TempDir()
	secret, created, err := LoadOrRotateSessionSecret(dir, "", false)
	if err != nil || secret == "" || !created {
		t.Fatalf("create failed: created=%v err=%v", created, err)
	}
	loaded, rotated, err := LoadOrRotateSessionSecret(dir, "", true)
	if err != nil || loaded == secret || !rotated {
		t.Fatalf("rotate failed: rotated=%v err=%v", rotated, err)
	}
	if _, err := os.Stat(filepath.Join(dir, sessionSecretFile)); err != nil {
		t.Fatal(err)
	}
}
