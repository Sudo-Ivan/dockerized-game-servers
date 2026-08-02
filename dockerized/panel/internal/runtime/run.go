package runtime

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	_ "gameserverpanel/games/arma3"
	"gameserverpanel/internal/auth"
	"gameserverpanel/internal/events"
	"gameserverpanel/internal/game"
	"gameserverpanel/internal/panelconfig"
	"gameserverpanel/internal/plugins"
	"gameserverpanel/internal/schedule"
	"gameserverpanel/internal/web"
)

func Run() error {
	panel := panelconfig.Load()
	mod, err := game.Load(panel.GameID)
	if err != nil {
		return err
	}
	if title := panel.Title; title != "" {
		log.Printf("panel title override: %s", title)
	}

	if err := mod.EnsureDirs(); err != nil {
		return err
	}

	cacheDir := panel.CacheDir
	sessionSecret, rotated, err := auth.LoadOrRotateSessionSecret(cacheDir, panel.SessionSec, true)
	if err != nil {
		return err
	}
	if rotated {
		log.Printf("panel session secret rotated, existing sessions invalidated")
	}

	passwordHash, err := auth.LoadPasswordHash(cacheDir, panel.PanelPass)
	if err != nil {
		return err
	}
	authMgr, err := auth.NewManager(sessionSecret, passwordHash)
	if err != nil {
		return err
	}

	reg := plugins.NewRegistry()
	_ = plugins.LoadAll(reg, plugins.NewWebhookPlugin())
	broker := events.NewBroker()
	scheduler := schedule.NewRestarter(panel.ScheduledRestart, panel.ScheduledRestartWarn, mod.Manager(), mod.Announcer())

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	scheduler.Start(ctx)

	srv, err := web.New(panel, mod, authMgr, reg, broker, scheduler)
	if err != nil {
		return err
	}

	httpServer := &http.Server{
		Addr:              panel.ListenAddr,
		Handler:           srv.Handler(),
		ReadHeaderTimeout: 10 * time.Second,
		ReadTimeout:       30 * time.Minute,
		WriteTimeout:      0,
		IdleTimeout:       120 * time.Second,
	}

	go func() {
		log.Printf("%s panel listening on %s", mod.Title(), panel.ListenAddr)
		if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatal(err)
		}
	}()

	if mod.AutoStart() {
		go func() {
			time.Sleep(2 * time.Second)
			startCtx, startCancel := context.WithTimeout(context.Background(), 30*time.Minute)
			defer startCancel()
			if err := mod.Manager().Start(startCtx); err != nil {
				log.Printf("auto start failed: %v", err)
			}
		}()
	}

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)
	<-stop

	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer shutdownCancel()
	_ = httpServer.Shutdown(shutdownCtx)
	_ = mod.Manager().Stop(15 * time.Second)
	return nil
}
