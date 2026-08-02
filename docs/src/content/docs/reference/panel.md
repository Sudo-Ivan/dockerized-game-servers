---
title: Game server panel
description: Shared Go web panel for dockerized game server images.
---

The repository ships a reusable game server panel under `dockerized/panel/`. It is a single Go binary with an HTMX UI, optional password auth, scheduled restarts, backups, and live SSE updates.

## How it works

- **Core** (`dockerized/panel/internal/`): auth, HTTP shell, scheduling, plugins, path-safe file helpers
- **Game modules** (`dockerized/panel/games/<id>/`): per-game process control, config, routes, and templates
- **Binary**: built from `dockerized/panel/cmd/gameserver-panel`

Select the game at runtime with `PANEL_GAME`. The Arma 3 image sets `PANEL_GAME=arma3` by default.

## Generic environment

| Setting | Default | What it does |
| --- | --- | --- |
| PANEL_GAME | (required) | Registered game module id, e.g. `arma3` |
| PANEL_PORT | 9283 | TCP port (Arma image also accepts ARMA_PANEL_PORT) |
| PANEL_ADDR | :9283 | Listen address |
| PANEL_PASSWORD | (empty) | Enable login when set |
| PANEL_SESSION_SECRET | (empty) | Fixed session signing secret |
| PANEL_ALLOWED_IPS | (empty) | Comma-separated IPs or CIDR allowlist |
| PANEL_AUTO_START | true | Start the game server when the panel starts |
| PANEL_SCHEDULED_RESTART | (empty) | Daily restart time HH:MM |
| PANEL_WEBHOOK_URL | (empty) | Optional webhook for panel events |

Legacy `ARMA_PANEL_*` variables still work in the Arma 3 image for backward compatibility.

## Adding a new game

1. Create `dockerized/panel/games/<id>/` implementing `game.Module` (see `games/arma3/`).
2. Register the module in `init()` with `game.Register("<id>", factory)`.
3. Import the package from `internal/runtime/run.go` (or a game-specific `main` if you prefer a smaller binary).
4. Point your server image Dockerfile panel build stage at `dockerized/panel` and set `PANEL_GAME`.

Each game module provides its own routes, templates, backup layout, and process manager while sharing auth, login rate limits, and the dashboard shell.
