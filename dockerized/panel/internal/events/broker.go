package events

import (
	"encoding/json"
	"sync"
)

type Message struct {
	Topic string          `json:"topic"`
	Data  json.RawMessage `json:"data"`
}

type Broker struct {
	mu      sync.RWMutex
	clients map[chan []byte]struct{}
}

func NewBroker() *Broker {
	return &Broker{clients: make(map[chan []byte]struct{})}
}

func (b *Broker) Subscribe(buffer int) (chan []byte, func()) {
	if buffer < 1 {
		buffer = 16
	}
	ch := make(chan []byte, buffer)
	b.mu.Lock()
	b.clients[ch] = struct{}{}
	b.mu.Unlock()
	cancel := func() {
		b.mu.Lock()
		delete(b.clients, ch)
		b.mu.Unlock()
		close(ch)
	}
	return ch, cancel
}

func (b *Broker) Publish(topic string, payload any) {
	data, err := json.Marshal(payload)
	if err != nil {
		return
	}
	msg, err := json.Marshal(Message{Topic: topic, Data: data})
	if err != nil {
		return
	}
	b.mu.RLock()
	defer b.mu.RUnlock()
	for ch := range b.clients {
		select {
		case ch <- msg:
		default:
		}
	}
}
