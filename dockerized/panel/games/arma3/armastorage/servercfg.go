package armastorage

import (
	"regexp"
	"strconv"
	"strings"
)

type ServerCfg struct {
	Hostname              string
	Password              string
	PasswordAdmin         string
	ServerCommandPassword string
	MOTD                  string
	MOTDInterval          int
	MaxPlayers            int
	KickDuplicate         bool
	VerifySignatures      int
	AllowedFilePatching   int
	DisconnectTimeout     int
	BattlEye              bool
	Persistent            bool
	DisableVoN            bool
	VonCodec              int
	Template              string
}

var cfgKey = regexp.MustCompile(`(?i)^\s*([a-zA-Z0-9_]+)\s*=\s*(.+?)\s*;\s*$`)

func ParseServerCfg(text string) ServerCfg {
	cfg := ServerCfg{
		MaxPlayers:        32,
		MOTDInterval:      30,
		VerifySignatures:  2,
		DisconnectTimeout: 90,
		BattlEye:          true,
		Persistent:        true,
		KickDuplicate:     true,
	}
	for _, line := range strings.Split(text, "\n") {
		trim := strings.TrimSpace(line)
		if strings.HasPrefix(trim, "//") || trim == "" {
			continue
		}
		if strings.HasPrefix(strings.ToLower(trim), "template") {
			cfg.Template = parseStringValue(trim)
			continue
		}
		m := cfgKey.FindStringSubmatch(trim)
		if len(m) != 3 {
			continue
		}
		key := strings.ToLower(m[1])
		val := strings.TrimSpace(m[2])
		switch key {
		case "hostname":
			cfg.Hostname = parseQuoted(val)
		case "password":
			cfg.Password = parseQuoted(val)
		case "passwordadmin":
			cfg.PasswordAdmin = parseQuoted(val)
		case "servercommandpassword":
			cfg.ServerCommandPassword = parseQuoted(val)
		case "motdinterval":
			cfg.MOTDInterval = parseInt(val, cfg.MOTDInterval)
		case "maxplayers":
			cfg.MaxPlayers = parseInt(val, cfg.MaxPlayers)
		case "kickduplicate":
			cfg.KickDuplicate = parseBool(val, cfg.KickDuplicate)
		case "verifysignatures":
			cfg.VerifySignatures = parseInt(val, cfg.VerifySignatures)
		case "allowedfilepatching":
			cfg.AllowedFilePatching = parseInt(val, cfg.AllowedFilePatching)
		case "disconnecttimeout":
			cfg.DisconnectTimeout = parseInt(val, cfg.DisconnectTimeout)
		case "battleeye":
			cfg.BattlEye = parseBool(val, cfg.BattlEye)
		case "persistent":
			cfg.Persistent = parseBool(val, cfg.Persistent)
		case "disablevon":
			cfg.DisableVoN = parseBool(val, cfg.DisableVoN)
		case "voncodec":
			cfg.VonCodec = parseInt(val, cfg.VonCodec)
		}
	}
	cfg.MOTD = extractMOTD(text)
	return cfg
}

func ApplyServerCfgForm(text string, form ServerCfg) string {
	updates := map[string]string{
		"hostname":              quote(form.Hostname),
		"password":              quote(form.Password),
		"passwordadmin":         quote(form.PasswordAdmin),
		"servercommandpassword": quote(form.ServerCommandPassword),
		"motdinterval":          strconv.Itoa(form.MOTDInterval),
		"maxplayers":            strconv.Itoa(form.MaxPlayers),
		"kickduplicate":         boolNum(form.KickDuplicate),
		"verifysignatures":      strconv.Itoa(form.VerifySignatures),
		"allowedfilepatching":   strconv.Itoa(form.AllowedFilePatching),
		"disconnecttimeout":     strconv.Itoa(form.DisconnectTimeout),
		"battleeye":             boolNum(form.BattlEye),
		"persistent":            boolNum(form.Persistent),
		"disablevon":            boolNum(form.DisableVoN),
		"voncodec":              strconv.Itoa(form.VonCodec),
	}
	lines := strings.Split(text, "\n")
	seen := map[string]bool{}
	for i, line := range lines {
		m := cfgKey.FindStringSubmatch(strings.TrimSpace(line))
		if len(m) != 3 {
			continue
		}
		key := strings.ToLower(m[1])
		if val, ok := updates[key]; ok {
			indent := line[:len(line)-len(strings.TrimLeft(line, " \t"))]
			lines[i] = indent + m[1] + " = " + val + ";"
			seen[key] = true
		}
	}
	var additions []string
	for key, val := range updates {
		if seen[key] {
			continue
		}
		additions = append(additions, key+" = "+val+";")
	}
	out := strings.Join(lines, "\n")
	if strings.TrimSpace(out) == "" {
		out = strings.Join(additions, "\n")
	} else if len(additions) > 0 {
		out += "\n" + strings.Join(additions, "\n")
	}
	out = replaceMOTD(out, form.MOTD)
	if strings.TrimSpace(form.Template) != "" {
		out = SetActiveMissionTemplate(out, form.Template)
	}
	return out
}

func extractMOTD(text string) string {
	idx := strings.Index(strings.ToLower(text), "motd[]")
	if idx < 0 {
		return ""
	}
	rest := text[idx:]
	start := strings.Index(rest, "{")
	end := strings.Index(rest, "};")
	if start < 0 || end < 0 || end <= start {
		return ""
	}
	block := rest[start+1 : end]
	var lines []string
	for _, line := range strings.Split(block, "\n") {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "\"") {
			lines = append(lines, strings.Trim(line, "\","))
		}
	}
	return strings.Join(lines, "\n")
}

func replaceMOTD(text, motd string) string {
	lines := strings.Split(strings.TrimSpace(motd), "\n")
	if len(lines) == 0 || strings.TrimSpace(motd) == "" {
		return text
	}
	var block strings.Builder
	block.WriteString("motd[] = {\n")
	for _, line := range lines {
		block.WriteString("    \"" + strings.ReplaceAll(line, "\"", "'") + "\"\n")
	}
	block.WriteString("};")
	if strings.Contains(strings.ToLower(text), "motd[]") {
		re := regexp.MustCompile(`(?is)motd\s*\[\s*\]\s*=\s*\{.*?\};`)
		return re.ReplaceAllString(text, block.String())
	}
	if strings.TrimSpace(text) == "" {
		return block.String()
	}
	return text + "\n" + block.String()
}

func parseQuoted(raw string) string {
	raw = strings.TrimSpace(raw)
	return strings.Trim(raw, "\"")
}

func parseStringValue(line string) string {
	parts := strings.SplitN(line, "=", 2)
	if len(parts) != 2 {
		return ""
	}
	return parseQuoted(strings.TrimSpace(parts[1]))
}

func parseInt(raw string, fallback int) int {
	raw = parseQuoted(strings.TrimSpace(raw))
	n, err := strconv.Atoi(raw)
	if err != nil {
		return fallback
	}
	return n
}

func parseBool(raw string, fallback bool) bool {
	raw = strings.ToLower(parseQuoted(strings.TrimSpace(raw)))
	switch raw {
	case "1", "true", "yes":
		return true
	case "0", "false", "no":
		return false
	default:
		return fallback
	}
}

func quote(v string) string {
	return "\"" + strings.ReplaceAll(v, "\"", "'") + "\""
}

func boolNum(v bool) string {
	if v {
		return "1"
	}
	return "0"
}
