package armastorage

import (
	"bytes"
	"os"
	"path/filepath"
	"testing"
)

func TestServerCfgParseAndApply(t *testing.T) {
	raw := `hostname = "Test";
maxPlayers = 16;
passwordAdmin = "secret";
motd[] = {
    "hello"
};
`
	cfg := ParseServerCfg(raw)
	if cfg.Hostname != "Test" || cfg.MaxPlayers != 16 {
		t.Fatalf("parse failed: %+v", cfg)
	}
	cfg.Hostname = "Updated"
	cfg.MaxPlayers = 32
	out := ApplyServerCfgForm(raw, cfg)
	if !contains(out, "Updated") || !contains(out, "maxPlayers = 32;") {
		t.Fatalf("apply failed: %s", out)
	}
}

func TestBackupRoundTrip(t *testing.T) {
	root := t.TempDir()
	configDir := filepath.Join(root, "configs")
	missionsDir := filepath.Join(root, "mpmissions")
	modlist := filepath.Join(root, "modlist.html")
	if err := os.MkdirAll(configDir, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.MkdirAll(missionsDir, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(configDir, "server.cfg"), []byte("hostname = \"x\";"), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(missionsDir, "test.pbo"), []byte("pbo"), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(modlist, []byte("<html></html>"), 0o644); err != nil {
		t.Fatal(err)
	}

	var buf bytes.Buffer
	if err := CreateBackup(&buf, BackupPaths{
		ConfigDir:   configDir,
		MissionsDir: missionsDir,
		ModlistFile: modlist,
		ServerCfg:   filepath.Join(configDir, "server.cfg"),
	}); err != nil {
		t.Fatal(err)
	}

	restoreRoot := t.TempDir()
	restoreConfig := filepath.Join(restoreRoot, "configs")
	restoreMissions := filepath.Join(restoreRoot, "mpmissions")
	restoreModlist := filepath.Join(restoreRoot, "modlist.html")
	reader := bytes.NewReader(buf.Bytes())
	if err := RestoreBackup(reader, int64(buf.Len()), RestorePaths{
		ConfigDir:   restoreConfig,
		MissionsDir: restoreMissions,
		ModlistFile: restoreModlist,
	}); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(filepath.Join(restoreConfig, "server.cfg")); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(filepath.Join(restoreMissions, "test.pbo")); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(restoreModlist); err != nil {
		t.Fatal(err)
	}
}

func contains(s, needle string) bool {
	return bytes.Contains([]byte(s), []byte(needle))
}
