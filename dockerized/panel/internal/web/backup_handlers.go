package web

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"time"
)

func (s *Server) handleBackup(w http.ResponseWriter, r *http.Request) {
	s.Render(w, "backup.html", s.BasePage("Backup"))
}

func (s *Server) handleBackupDownload(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	backup := s.mod.Backup()
	if backup == nil {
		http.Error(w, "backup not configured", http.StatusInternalServerError)
		return
	}
	var buf bytes.Buffer
	if err := backup.WriteArchive(&buf); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	prefix := backup.FilenamePrefix()
	if prefix == "" {
		prefix = "server-backup"
	}
	w.Header().Set("Content-Type", "application/zip")
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=\"%s-%s.zip\"", prefix, time.Now().UTC().Format("20060102-150405")))
	_, _ = io.Copy(w, &buf)
}

func (s *Server) handleBackupRestore(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	backup := s.mod.Backup()
	if backup == nil {
		http.Error(w, "backup not configured", http.StatusInternalServerError)
		return
	}
	if err := parseBoundedMultipart(w, r, s.maxUpload); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	file, _, err := r.FormFile("backup")
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	defer file.Close()
	data, err := io.ReadAll(file)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	reader := bytes.NewReader(data)
	if err := backup.RestoreArchive(reader, int64(len(data))); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/backup", http.StatusSeeOther)
}
