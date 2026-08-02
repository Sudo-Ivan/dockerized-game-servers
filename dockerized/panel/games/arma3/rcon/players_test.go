package rcon

import "testing"

func TestParsePlayers(t *testing.T) {
	resp := "Players on server:\n#0  PlayerOne  192.168.1.10:2304  45  abcdef0123456789\n"
	players := ParsePlayers(resp)
	if len(players) != 1 || players[0].Name != "PlayerOne" || players[0].ID != 0 {
		t.Fatalf("unexpected players: %+v", players)
	}
}

func TestParseMissions(t *testing.T) {
	resp := "Missions on server:\nAltis_Conflict\nStratis_Scenario"
	missions := ParseMissions(resp)
	if len(missions) != 2 || missions[0] != "Altis_Conflict" {
		t.Fatalf("unexpected missions: %+v", missions)
	}
}
