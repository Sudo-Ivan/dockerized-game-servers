package storage

import (
	"os"
	"path/filepath"
)

func ReadFile(path string) (string, error) {
	b, err := os.ReadFile(path) // #nosec G304 -- caller supplies config-managed paths only
	if err != nil {
		if os.IsNotExist(err) {
			return "", nil
		}
		return "", err
	}
	return string(b), nil
}

func ReadFileWithin(base, path string) (string, error) {
	b, err := ReadWithin(base, path)
	if err != nil {
		if os.IsNotExist(err) {
			return "", nil
		}
		return "", err
	}
	return string(b), nil
}

func WriteFile(path, content string) error {
	if err := EnsureDir(filepath.Dir(path)); err != nil {
		return err
	}
	return os.WriteFile(path, []byte(content), FilePerm)
}

func WriteFileWithin(base, path, content string) error {
	return WriteWithin(base, path, []byte(content))
}
