package auth

import (
	"net/http"
	"strings"
)

func cookieSecure(r *http.Request) bool {
	if r.TLS != nil {
		return true
	}
	return strings.EqualFold(r.Header.Get("X-Forwarded-Proto"), "https")
}

func setSessionCookie(w http.ResponseWriter, r *http.Request, value string, maxAge int) {
	if cookieSecure(r) {
		http.SetCookie(w, &http.Cookie{
			Name:     cookieName,
			Value:    value,
			Path:     "/",
			HttpOnly: true,
			SameSite: http.SameSiteStrictMode,
			Secure:   true,
			MaxAge:   maxAge,
		})
		return
	}
	http.SetCookie(w, &http.Cookie{ // #nosec G124 -- plain HTTP panel on LAN without TLS
		Name:     cookieName,
		Value:    value,
		Path:     "/",
		HttpOnly: true,
		SameSite: http.SameSiteStrictMode,
		MaxAge:   maxAge,
	})
}
