package schedule

import "testing"

func TestParseClock(t *testing.T) {
	h, m, ok := parseClock("04:30")
	if !ok || h != 4 || m != 30 {
		t.Fatalf("unexpected clock: %d:%d ok=%v", h, m, ok)
	}
	if _, _, ok := parseClock("bad"); ok {
		t.Fatal("expected invalid clock")
	}
}
