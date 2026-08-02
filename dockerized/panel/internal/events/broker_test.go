package events

import (
	"testing"
	"time"
)

func TestBrokerPublishSubscribe(t *testing.T) {
	b := NewBroker()
	ch, cancel := b.Subscribe(2)
	defer cancel()
	b.Publish("status", map[string]string{"state": "running"})
	select {
	case msg := <-ch:
		if len(msg) == 0 {
			t.Fatal("empty message")
		}
	case <-time.After(time.Second):
		t.Fatal("timeout waiting for event")
	}
}
