package plugins

import (
	"context"
	"log"
	"os"
	"strings"
)

type WebhookPlugin struct {
	url string
}

func NewWebhookPlugin() *WebhookPlugin {
	url := strings.TrimSpace(os.Getenv("PANEL_WEBHOOK_URL"))
	if url == "" {
		url = strings.TrimSpace(os.Getenv("ARMA_PANEL_WEBHOOK_URL"))
	}
	return &WebhookPlugin{url: url}
}

func (p *WebhookPlugin) Name() string {
	return "webhook"
}

func (p *WebhookPlugin) Init(reg *Registry) error {
	if p.url == "" {
		return nil
	}
	events := []EventType{
		EventServerStart,
		EventServerStop,
		EventWorkshopSyncDone,
		EventWorkshopSyncFail,
		EventScheduledRestart,
	}
	for _, event := range events {
		reg.On(event, p.handle)
	}
	return nil
}

func (p *WebhookPlugin) handle(ctx context.Context, event Event) {
	if p.url == "" {
		return
	}
	var payload strings.Builder
	payload.WriteString("event=" + string(event.Type))
	for k, v := range event.Data {
		payload.WriteString("&" + k + "=" + v)
	}
	req, err := newWebhookRequest(ctx, p.url, payload.String())
	if err != nil {
		log.Printf("webhook plugin: %v", err)
		return
	}
	if err := doWebhook(req); err != nil {
		log.Printf("webhook plugin: %v", err)
	}
}
