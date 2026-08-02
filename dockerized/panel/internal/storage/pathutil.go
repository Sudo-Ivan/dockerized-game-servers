package storage

import (
	"errors"
	"os"
	"path/filepath"
	"strings"
)

const (
	DirPerm  = 0o750
	FilePerm = 0o640
)

const maxZipExtractBytes = 512 << 20

func EnsureDir(path string) error {
	return os.MkdirAll(path, DirPerm)
}

func WithinBase(base, target string) error {
	base = filepath.Clean(base)
	target = filepath.Clean(target)
	if base == target {
		return nil
	}
	prefix := base + string(os.PathSeparator)
	if !strings.HasPrefix(target, prefix) {
		return errors.New("path outside allowed directory")
	}
	return nil
}

func OpenWithin(base, target string, flag int) (*os.File, error) {
	if err := WithinBase(base, target); err != nil {
		return nil, err
	}
	return os.OpenFile(target, flag, FilePerm) // #nosec G304 -- path checked by WithinBase
}

func ReadWithin(base, target string) ([]byte, error) {
	if err := WithinBase(base, target); err != nil {
		return nil, err
	}
	return os.ReadFile(target) // #nosec G304 -- path checked by WithinBase
}

func WriteWithin(base, target string, data []byte) error {
	if err := WithinBase(base, target); err != nil {
		return err
	}
	if err := EnsureDir(filepath.Dir(target)); err != nil {
		return err
	}
	return os.WriteFile(target, data, FilePerm)
}
