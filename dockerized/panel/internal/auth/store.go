package auth

import (
	"path/filepath"

	"gameserverpanel/internal/storage"
)

const sessionSecretFile = "panel.session.secret"

func LoadOrRotateSessionSecret(cacheDir, envSecret string, rotate bool) (string, bool, error) {
	path := filepath.Join(cacheDir, sessionSecretFile)
	if envSecret != "" {
		if err := storage.WriteWithin(cacheDir, path, []byte(envSecret)); err != nil {
			return "", false, err
		}
		return envSecret, false, nil
	}

	if data, err := storage.ReadWithin(cacheDir, path); err == nil && len(data) > 0 {
		if rotate {
			secret, err := NewSecret()
			if err != nil {
				return "", false, err
			}
			if err := storage.WriteWithin(cacheDir, path, []byte(secret)); err != nil {
				return "", false, err
			}
			return secret, true, nil
		}
		return string(data), false, nil
	}

	secret, err := NewSecret()
	if err != nil {
		return "", false, err
	}
	if err := storage.EnsureDir(cacheDir); err != nil {
		return "", false, err
	}
	if err := storage.WriteWithin(cacheDir, path, []byte(secret)); err != nil {
		return "", false, err
	}
	return secret, true, nil
}

func LoadPasswordHash(cacheDir, envPassword string) (string, error) {
	if envPassword == "" {
		return "", nil
	}
	path := filepath.Join(cacheDir, "panel.password")
	if stored, err := storage.ReadWithin(cacheDir, path); err == nil && len(stored) > 0 {
		return string(stored), nil
	}
	hash, err := HashPassword(envPassword)
	if err != nil {
		return "", err
	}
	if err := storage.EnsureDir(cacheDir); err != nil {
		return "", err
	}
	if err := storage.WriteWithin(cacheDir, path, []byte(hash)); err != nil {
		return "", err
	}
	return hash, nil
}

func SecretPath(cacheDir string) string {
	return filepath.Join(cacheDir, sessionSecretFile)
}
