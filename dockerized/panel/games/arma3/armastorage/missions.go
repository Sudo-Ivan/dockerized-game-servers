package armastorage

import (
	"errors"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"gameserverpanel/internal/storage"
)

var safeName = regexp.MustCompile(`^[A-Za-z0-9._ -]+$`)

type Mission struct {
	Name     string
	Path     string
	Size     int64
	IsActive bool
}

func ListMissions(dir, activeTemplate string) ([]Mission, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		if os.IsNotExist(err) {
			if mkErr := storage.EnsureDir(dir); mkErr != nil {
				return nil, mkErr
			}
			return []Mission{}, nil
		}
		return nil, err
	}

	active := strings.TrimSpace(activeTemplate)
	var out []Mission
	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		name := entry.Name()
		lower := strings.ToLower(name)
		if !strings.HasSuffix(lower, ".pbo") {
			continue
		}
		info, err := entry.Info()
		if err != nil {
			continue
		}
		base := strings.TrimSuffix(name, filepath.Ext(name))
		out = append(out, Mission{
			Name:     name,
			Path:     filepath.Join(dir, name),
			Size:     info.Size(),
			IsActive: active != "" && strings.EqualFold(active, base),
		})
	}
	sort.Slice(out, func(i, j int) bool { return out[i].Name < out[j].Name })
	return out, nil
}

func SaveMission(dir, filename string, r io.Reader) error {
	if !safeName.MatchString(filename) || !strings.HasSuffix(strings.ToLower(filename), ".pbo") {
		return errors.New("invalid mission filename")
	}
	if err := storage.EnsureDir(dir); err != nil {
		return err
	}
	path := filepath.Join(dir, filepath.Base(filename))
	f, err := storage.OpenWithin(dir, path, os.O_CREATE|os.O_WRONLY|os.O_TRUNC)
	if err != nil {
		return err
	}
	defer f.Close()
	_, err = io.Copy(f, r)
	return err
}

func RenameMission(dir, oldName, newName string) error {
	if !safeName.MatchString(oldName) || !safeName.MatchString(newName) {
		return errors.New("invalid mission filename")
	}
	oldPath := filepath.Join(dir, filepath.Base(oldName))
	newPath := filepath.Join(dir, filepath.Base(newName))
	if err := storage.WithinBase(dir, oldPath); err != nil {
		return err
	}
	if err := storage.WithinBase(dir, newPath); err != nil {
		return err
	}
	return os.Rename(oldPath, newPath)
}

func RemoveMission(dir, name string) error {
	if !safeName.MatchString(name) {
		return errors.New("invalid mission filename")
	}
	path := filepath.Join(dir, filepath.Base(name))
	if err := storage.WithinBase(dir, path); err != nil {
		return err
	}
	return os.Remove(path)
}

func ActiveMissionTemplate(cfgText string) string {
	lines := strings.Split(cfgText, "\n")
	for _, line := range lines {
		trim := strings.TrimSpace(line)
		if strings.HasPrefix(strings.ToLower(trim), "template") {
			parts := strings.SplitN(trim, "=", 2)
			if len(parts) != 2 {
				continue
			}
			return strings.Trim(strings.TrimSpace(parts[1]), `";`)
		}
	}
	return ""
}

func SetActiveMissionTemplate(cfgText, template string) string {
	template = strings.TrimSpace(template)
	if template == "" {
		return cfgText
	}
	lines := strings.Split(cfgText, "\n")
	found := false
	for i, line := range lines {
		trim := strings.TrimSpace(line)
		if strings.HasPrefix(strings.ToLower(trim), "template") {
			indent := line[:len(line)-len(strings.TrimLeft(line, " \t"))]
			lines[i] = indent + "template = \"" + template + "\";"
			found = true
			break
		}
	}
	if found {
		return strings.Join(lines, "\n")
	}
	block := "\nclass Missions {\n    class Mission1 {\n        template = \"" + template + "\";\n        difficulty = \"Regular\";\n    };\n};\n"
	if strings.TrimSpace(cfgText) == "" {
		return block
	}
	return cfgText + block
}
