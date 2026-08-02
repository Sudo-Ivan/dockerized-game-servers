package arma3

import "testing"

func TestNeedsSteamGuard(t *testing.T) {
	if !NeedsSteamGuard("Steam login failed: AccountLoginDeniedNeedTwoFactor") {
		t.Fatal("expected guard detection")
	}
	if NeedsSteamGuard("workshop sync failed: timeout") {
		t.Fatal("unexpected guard detection")
	}
}
