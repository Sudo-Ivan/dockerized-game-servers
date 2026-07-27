---
title: Stardew Valley
description: Always-on farm via JunimoServer (external Docker images).
---

Compose path: stardew-valley. This stack uses [JunimoServer](https://github.com/stardew-valley-dedicated-server/server) images (`sdvd/server`, `sdvd/steam-service`), not a GHCR image from this repository.

JunimoServer runs Stardew Valley headless with SMAPI, optional VNC admin, HTTP API, backups, and mod support. You need a Steam account that owns Stardew Valley to download game files.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 24642 | UDP | Multiplayer (Steam relay) |
| 27015 | UDP | Steam query |
| 5800 | TCP | VNC web admin (`SDVD_VNC_PASSWORD`) |
| 8080 | TCP | HTTP API (`SDVD_API_ENABLED`) |

## Volumes

All paths are under `stardew-valley/data/` on the host:

| Mount | Container path | Purpose |
| --- | --- | --- |
| `game` | `/data/game` | Game install (Steam download) |
| `steam-session` | `/data/steam-session` | Steam login session |
| `saves` | `/config/xdg/config/StardewValley` | Save games |
| `settings` | `/data/settings` | `server-settings.json` |

## Quick start

```bash
cd stardew-valley
cp .env.example .env
# Edit .env: STEAM_USERNAME, STEAM_PASSWORD, SDVD_VNC_PASSWORD
docker compose run --rm -it steam-auth setup
docker compose up -d
docker compose logs -f server
```

`steam-auth setup` handles Steam Guard and the initial game download into `data/game`.

## Environment

Prefix `SDVD_` avoids clashes with other compose stacks. Steam credentials use `STEAM_USERNAME` and `STEAM_PASSWORD` (same names as upstream).

| Variable | Purpose |
| --- | --- |
| `SDVD_IMAGE_VERSION` | Junimo image tag (`latest` or a release tag) |
| `SDVD_VNC_PASSWORD` | VNC web UI password |
| `SDVD_SERVER_PASSWORD` | In-game `!login` password (empty disables) |
| `SDVD_API_KEY` | Protects API write endpoints |
| `SDVD_SERVER_TPS` | Simulation rate (default 60) |
| `SDVD_SERVER_FPS` | VNC render FPS (0 disables rendering) |

See `stardew-valley/.env.example` for more options.

## Discord bot (optional)

```bash
docker compose --profile discord up -d
```

Set `SDVD_DISCORD_BOT_TOKEN` in `.env`. Requires `SDVD_API_KEY` if the server API is keyed.

## Updates

```bash
docker compose pull
docker compose down
docker compose up -d
```

## Upstream docs

Full guides, API reference, and modding: [JunimoServer documentation](https://stardew-valley-dedicated-server.github.io/server/).
