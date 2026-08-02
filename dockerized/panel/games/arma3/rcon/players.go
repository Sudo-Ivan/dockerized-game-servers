package rcon

import (
	"regexp"
	"strconv"
	"strings"
)

type Player struct {
	ID    int
	Name  string
	IP    string
	Ping  int
	GUID  string
	Lobby bool
}

var playerLine = regexp.MustCompile(`^\s*#?(\d+)\s+(.+?)\s+(\d+\.\d+\.\d+\.\d+):(\d+)\s+(\d+)\s+([0-9a-f]+)`)

func ParsePlayers(response string) []Player {
	var out []Player
	for _, line := range strings.Split(response, "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(strings.ToLower(line), "players") {
			continue
		}
		m := playerLine.FindStringSubmatch(line)
		if len(m) < 7 {
			continue
		}
		id, _ := strconv.Atoi(m[1])
		ping, _ := strconv.Atoi(m[5])
		out = append(out, Player{
			ID:   id,
			Name: strings.TrimSpace(m[2]),
			IP:   m[3] + ":" + m[4],
			Ping: ping,
			GUID: m[6],
		})
	}
	return out
}

func ParseMissions(response string) []string {
	var out []string
	for _, line := range strings.Split(response, "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(strings.ToLower(line), "missions") {
			continue
		}
		out = append(out, line)
	}
	return out
}
