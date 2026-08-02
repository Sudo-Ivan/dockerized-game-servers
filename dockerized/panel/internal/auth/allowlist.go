package auth

import (
	"net"
	"strings"
)

func IPAllowed(ip string, allowed []string) bool {
	if len(allowed) == 0 {
		return true
	}
	clientIP := net.ParseIP(ip)
	if clientIP == nil {
		return false
	}
	for _, entry := range allowed {
		entry = strings.TrimSpace(entry)
		if entry == "" {
			continue
		}
		if strings.Contains(entry, "/") {
			_, network, err := net.ParseCIDR(entry)
			if err == nil && network.Contains(clientIP) {
				return true
			}
			continue
		}
		if host := net.ParseIP(entry); host != nil && host.Equal(clientIP) {
			return true
		}
	}
	return false
}
