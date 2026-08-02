package auth

import (
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"strconv"
	"strings"
)

const (
	saltBytes   = 16
	hashRounds  = 120000
	recordParts = 3
)

func HashPassword(password string) (string, error) {
	if password == "" {
		return "", errors.New("empty password")
	}
	salt := make([]byte, saltBytes)
	if _, err := io.ReadFull(rand.Reader, salt); err != nil {
		return "", err
	}
	digest := stretch(password, salt, hashRounds)
	return fmt.Sprintf("%d.%s.%s", hashRounds, hex.EncodeToString(salt), hex.EncodeToString(digest)), nil
}

func VerifyPassword(password, stored string) bool {
	parts := strings.Split(stored, ".")
	if len(parts) != recordParts {
		return false
	}
	rounds, err := strconv.Atoi(parts[0])
	if err != nil || rounds <= 0 {
		return false
	}
	salt, err := hex.DecodeString(parts[1])
	if err != nil {
		return false
	}
	want, err := hex.DecodeString(parts[2])
	if err != nil {
		return false
	}
	got := stretch(password, salt, rounds)
	return subtle.ConstantTimeCompare(got, want) == 1
}

func stretch(password string, salt []byte, rounds int) []byte {
	h := sha256.New()
	_, _ = h.Write(salt)
	_, _ = h.Write([]byte(password))
	digest := h.Sum(nil)
	for i := 1; i < rounds; i++ {
		h = sha256.New()
		_, _ = h.Write(digest)
		digest = h.Sum(nil)
	}
	return digest
}
