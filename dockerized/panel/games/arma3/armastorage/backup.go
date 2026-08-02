package armastorage

import (
	"archive/zip"
	"fmt"
	"gameserverpanel/internal/storage"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const maxZipExtractBytes = 512 << 20

type BackupPaths struct {
	ConfigDir   string
	MissionsDir string
	ModlistFile string
	ServerCfg   string
}

func CreateBackup(w io.Writer, paths BackupPaths) error {
	zw := zip.NewWriter(w)
	defer zw.Close()

	if err := addDirEntries(zw, "configs", paths.ConfigDir); err != nil {
		return err
	}
	if err := addDirEntries(zw, "mpmissions", paths.MissionsDir); err != nil {
		return err
	}
	if paths.ModlistFile != "" {
		if err := addFileEntry(zw, "modlist.html", paths.ModlistFile); err != nil {
			return err
		}
	}
	if paths.ServerCfg != "" && !strings.HasPrefix(filepath.Clean(paths.ServerCfg), filepath.Clean(paths.ConfigDir)) {
		if err := addFileEntry(zw, filepath.Join("configs", filepath.Base(paths.ServerCfg)), paths.ServerCfg); err != nil {
			return err
		}
	}
	return nil
}

func addDirEntries(zw *zip.Writer, prefix, dir string) error {
	info, err := os.Stat(dir)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}
	if !info.IsDir() {
		return addFileEntry(zw, prefix, dir)
	}
	return filepath.Walk(dir, func(path string, fi os.FileInfo, err error) error {
		if err != nil || fi.IsDir() {
			return err
		}
		rel, err := filepath.Rel(dir, path)
		if err != nil {
			return err
		}
		return addFileEntry(zw, filepath.Join(prefix, filepath.ToSlash(rel)), path)
	})
}

func addFileEntry(zw *zip.Writer, name, path string) error {
	if strings.Contains(name, "..") {
		return fmt.Errorf("invalid backup entry")
	}
	f, err := os.Open(path) // #nosec G304 -- backup reads only configured source paths
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}
	defer f.Close()
	info, err := f.Stat()
	if err != nil {
		return err
	}
	hdr, err := zip.FileInfoHeader(info)
	if err != nil {
		return err
	}
	hdr.Name = filepath.ToSlash(name)
	hdr.Method = zip.Deflate
	w, err := zw.CreateHeader(hdr)
	if err != nil {
		return err
	}
	_, err = io.Copy(w, f)
	return err
}

type RestorePaths struct {
	ConfigDir   string
	MissionsDir string
	ModlistFile string
}

func RestoreBackup(r io.ReaderAt, size int64, paths RestorePaths) error {
	zr, err := zip.NewReader(r, size)
	if err != nil {
		return err
	}
	for _, file := range zr.File {
		if file.FileInfo().IsDir() {
			continue
		}
		name := filepath.ToSlash(file.Name)
		if strings.Contains(name, "..") {
			return fmt.Errorf("invalid zip entry: %s", name)
		}
		target, err := mapRestoreTarget(name, paths)
		if err != nil {
			return err
		}
		if target == "" {
			continue
		}
		if err := extractZipFile(file, target); err != nil {
			return err
		}
	}
	return nil
}

func mapRestoreTarget(name string, paths RestorePaths) (string, error) {
	switch {
	case strings.HasPrefix(name, "configs/"):
		target := filepath.Join(paths.ConfigDir, filepath.FromSlash(strings.TrimPrefix(name, "configs/")))
		if err := storage.WithinBase(paths.ConfigDir, target); err != nil {
			return "", err
		}
		return target, nil
	case strings.HasPrefix(name, "mpmissions/"):
		target := filepath.Join(paths.MissionsDir, filepath.FromSlash(strings.TrimPrefix(name, "mpmissions/")))
		if err := storage.WithinBase(paths.MissionsDir, target); err != nil {
			return "", err
		}
		return target, nil
	case name == "modlist.html":
		return paths.ModlistFile, nil
	default:
		return "", nil
	}
}

func extractZipFile(file *zip.File, target string) error {
	rc, err := file.Open()
	if err != nil {
		return err
	}
	defer rc.Close()
	if err := storage.EnsureDir(filepath.Dir(target)); err != nil {
		return err
	}
	out, err := os.OpenFile(target, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, storage.FilePerm) // #nosec G304 -- target validated in mapRestoreTarget
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, io.LimitReader(rc, maxZipExtractBytes))
	return err
}

func BackupFilename() string {
	return fmt.Sprintf("arma3-backup-%s.zip", time.Now().UTC().Format("20060102-150405"))
}
