package game

import (
	"fmt"
	"strings"
)

var registry = map[string]func() Module{}

func Register(id string, factory func() Module) {
	registry[strings.ToLower(strings.TrimSpace(id))] = factory
}

func Load(id string) (Module, error) {
	factory, ok := registry[strings.ToLower(strings.TrimSpace(id))]
	if !ok {
		return nil, fmt.Errorf("unknown panel game %q", id)
	}
	return factory(), nil
}

func IDs() []string {
	out := make([]string, 0, len(registry))
	for id := range registry {
		out = append(out, id)
	}
	return out
}
