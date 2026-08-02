package web

import (
	"html"
	"net/http"
)

func writeFlashOK(w http.ResponseWriter, message string) {
	_, _ = w.Write([]byte(`<div class="flash ok">` + html.EscapeString(message) + `</div>`))
}

func writeFlashErr(w http.ResponseWriter, err error) {
	_, _ = w.Write([]byte(`<div class="flash err">` + html.EscapeString(err.Error()) + `</div>`))
}

func parseBoundedMultipart(w http.ResponseWriter, r *http.Request, limit int64) error {
	r.Body = http.MaxBytesReader(w, r.Body, limit)
	// Request body is capped by MaxBytesReader before multipart parsing.
	return r.ParseMultipartForm(limit) // #nosec G120
}
