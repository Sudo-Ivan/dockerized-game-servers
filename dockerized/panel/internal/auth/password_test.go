package auth

import "testing"

func TestPasswordHashAndVerify(t *testing.T) {
	hash, err := HashPassword("panel-secret")
	if err != nil {
		t.Fatal(err)
	}
	if !VerifyPassword("panel-secret", hash) {
		t.Fatal("expected password to verify")
	}
	if VerifyPassword("wrong", hash) {
		t.Fatal("expected wrong password to fail")
	}
}
