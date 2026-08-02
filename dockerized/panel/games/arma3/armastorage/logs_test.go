package armastorage

import "testing"

func TestFilterLines(t *testing.T) {
	lines := []LogLine{
		{Source: LogSourceRPT, Text: "Error: something failed"},
		{Source: LogSourceRPT, Text: "Player connected"},
		{Source: LogSourceBE, Text: "Admin kicked player"},
	}
	out := filterLines(lines, "error")
	if len(out) != 1 {
		t.Fatalf("expected 1 error line, got %d", len(out))
	}
	out = filterLines(lines, "admin")
	if len(out) != 1 {
		t.Fatalf("expected 1 admin line, got %d", len(out))
	}
}
