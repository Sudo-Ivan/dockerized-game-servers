package armastorage

import (
	"bufio"
	"gameserverpanel/internal/storage"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

type LogSource string

const (
	LogSourceProcess LogSource = "process"
	LogSourceRPT     LogSource = "rpt"
	LogSourceBE      LogSource = "battleye"
)

type LogLine struct {
	Source LogSource
	Text   string
}

func TailLogs(profilesDir string, processLines []string, source, filter string, limit int) ([]LogLine, error) {
	if limit <= 0 {
		limit = 200
	}
	var out []LogLine
	if source == "" || source == "process" {
		start := 0
		if len(processLines) > limit {
			start = len(processLines) - limit
		}
		for _, line := range processLines[start:] {
			out = append(out, LogLine{Source: LogSourceProcess, Text: line})
		}
	}
	if source == "" || source == "rpt" {
		lines, err := tailNewestRPT(profilesDir, limit)
		if err != nil {
			return out, err
		}
		for _, line := range lines {
			out = append(out, LogLine{Source: LogSourceRPT, Text: line})
		}
	}
	if source == "" || source == "battleye" {
		lines, err := tailBattlEye(profilesDir, limit)
		if err != nil {
			return out, err
		}
		for _, line := range lines {
			out = append(out, LogLine{Source: LogSourceBE, Text: line})
		}
	}
	if filter != "" {
		out = filterLines(out, filter)
	}
	if len(out) > limit {
		out = out[len(out)-limit:]
	}
	return out, nil
}

func filterLines(lines []LogLine, filter string) []LogLine {
	filter = strings.ToLower(strings.TrimSpace(filter))
	var out []LogLine
	for _, line := range lines {
		lower := strings.ToLower(line.Text)
		switch filter {
		case "error":
			if strings.Contains(lower, "error") || strings.Contains(lower, "fatal") {
				out = append(out, line)
			}
		case "script":
			if strings.Contains(lower, "script") || strings.Contains(lower, ".sqf") {
				out = append(out, line)
			}
		case "admin":
			if strings.Contains(lower, "admin") || strings.Contains(lower, "rcon") || strings.Contains(lower, "#") {
				out = append(out, line)
			}
		default:
			if strings.Contains(lower, filter) {
				out = append(out, line)
			}
		}
	}
	return out
}

func tailNewestRPT(profilesDir string, limit int) ([]string, error) {
	serverDir := filepath.Join(profilesDir, "server")
	entries, err := os.ReadDir(serverDir)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, nil
		}
		return nil, err
	}
	var rpts []string
	for _, e := range entries {
		if !e.IsDir() && strings.HasSuffix(strings.ToLower(e.Name()), ".rpt") {
			rpts = append(rpts, filepath.Join(serverDir, e.Name()))
		}
	}
	if len(rpts) == 0 {
		return nil, nil
	}
	sort.Strings(rpts)
	return tailFile(profilesDir, rpts[len(rpts)-1], limit)
}

func tailBattlEye(profilesDir string, limit int) ([]string, error) {
	beDir := filepath.Join(profilesDir, "server", "BattlEye")
	entries, err := os.ReadDir(beDir)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, nil
		}
		return nil, err
	}
	var files []string
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		lower := strings.ToLower(e.Name())
		if strings.HasSuffix(lower, ".log") || strings.HasPrefix(lower, "beserver") {
			files = append(files, filepath.Join(beDir, e.Name()))
		}
	}
	if len(files) == 0 {
		return nil, nil
	}
	sort.Strings(files)
	return tailFile(profilesDir, files[len(files)-1], limit)
}

func tailFile(profilesDir, path string, limit int) ([]string, error) {
	if err := storage.WithinBase(profilesDir, path); err != nil {
		return nil, err
	}
	f, err := os.Open(path) // #nosec G304 -- path checked by WithinBase against profiles dir
	if err != nil {
		return nil, err
	}
	defer f.Close()
	var lines []string
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	if err := scanner.Err(); err != nil {
		return nil, err
	}
	if len(lines) > limit {
		lines = lines[len(lines)-limit:]
	}
	return lines, nil
}
