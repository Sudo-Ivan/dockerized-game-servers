package auth

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"
)

const (
	cookieName = "panel_session"
	sessionTTL = 12 * time.Hour
	issueSkew  = time.Minute
)

type Manager struct {
	secret []byte
	hash   string
}

func NewManager(secret, passwordHash string) (*Manager, error) {
	if len(secret) < 32 {
		return nil, errors.New("session secret must be at least 32 bytes")
	}
	return &Manager{secret: []byte(secret), hash: passwordHash}, nil
}

func NewSecret() (string, error) {
	buf := make([]byte, 32)
	if _, err := rand.Read(buf); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(buf), nil
}

func (m *Manager) Enabled() bool {
	return m.hash != ""
}

func (m *Manager) Login(password string) bool {
	return VerifyPassword(password, m.hash)
}

func (m *Manager) SetCookie(w http.ResponseWriter, r *http.Request) error {
	token, err := m.issueToken(time.Now().UTC())
	if err != nil {
		return err
	}
	setSessionCookie(w, r, token, int(sessionTTL.Seconds()))
	return nil
}

func (m *Manager) ClearCookie(w http.ResponseWriter, r *http.Request) {
	setSessionCookie(w, r, "", -1)
}

func (m *Manager) Authenticated(r *http.Request) bool {
	if !m.Enabled() {
		return true
	}
	cookie, err := r.Cookie(cookieName)
	if err != nil || cookie.Value == "" {
		return false
	}
	return m.validateToken(cookie.Value, time.Now().UTC())
}

func (m *Manager) issueToken(now time.Time) (string, error) {
	nonce := make([]byte, 16)
	if _, err := rand.Read(nonce); err != nil {
		return "", err
	}
	payload := fmt.Sprintf("%d.%s", now.Unix(), base64.RawURLEncoding.EncodeToString(nonce))
	sig := sign(m.secret, payload)
	return payload + "." + base64.RawURLEncoding.EncodeToString(sig), nil
}

func (m *Manager) validateToken(token string, now time.Time) bool {
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return false
	}
	issued, err := strconv.ParseInt(parts[0], 10, 64)
	if err != nil {
		return false
	}
	issuedAt := time.Unix(issued, 0)
	if now.Before(issuedAt.Add(-issueSkew)) || now.After(issuedAt.Add(sessionTTL)) {
		return false
	}
	payload := parts[0] + "." + parts[1]
	want, err := base64.RawURLEncoding.DecodeString(parts[2])
	if err != nil {
		return false
	}
	got := sign(m.secret, payload)
	return subtle.ConstantTimeCompare(got, want) == 1
}

func sign(secret []byte, payload string) []byte {
	mac := hmac.New(sha256.New, secret)
	_, _ = mac.Write([]byte(payload))
	return mac.Sum(nil)
}
