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

Prefix `SDVD_` avoids clashes with other compose stacks. Steam credentials use `STEAM_USERNAME` and `STEAM_PASSWORD` (same names as upstream), or `STEAM_REFRESH_TOKEN` for refresh-token login instead of a password.

| Variable | Default | Purpose |
| --- | --- | --- |
| `SDVD_IMAGE_VERSION` | `latest` | Junimo image tag, applies to `server`, `steam-auth`, and `discord-bot` |
| `SDVD_VNC_PASSWORD` | empty | VNC web UI password |
| `SDVD_ALLOW_INSECURE_SETUP` | `false` | Allow the VNC/API to run without a password set |
| `SDVD_API_ENABLED` | `true` | Enable the HTTP API |
| `SDVD_API_KEY` | empty | Protects API write endpoints |
| `SDVD_SERVER_PASSWORD` | empty | In-game `!login` password, empty disables |
| `SDVD_SERVER_TPS` | `60` | Simulation rate |
| `SDVD_SERVER_FPS` | `0` | VNC render FPS, `0` disables rendering |
| `SDVD_MAX_LOGIN_ATTEMPTS` | `3` | Failed `!login` attempts before lockout |
| `SDVD_AUTH_TIMEOUT_SECONDS` | `120` | Seconds before an unauthenticated session is dropped |
| `SDVD_STEAM_KEEP_LANGUAGES` | empty | Passed to `steam-auth` to filter Steam download languages |

Host port overrides (container ports stay fixed): `SDVD_VNC_PORT`, `SDVD_API_PORT`, `SDVD_GAME_PORT`, `SDVD_QUERY_PORT`. `SDVD_STEAM_AUTH_PORT` (default `3001`) is the internal `server` to `steam-auth` link and is not published.

See `stardew-valley/.env.example` for the Steam login and common overrides. The `discord-bot` service (below) takes its own vars directly in `docker-compose.yml`, they are not in `.env.example`.

## Discord bot (optional)

```bash
docker compose --profile discord up -d
```

Set `SDVD_DISCORD_BOT_TOKEN` in `.env`. Requires `SDVD_API_KEY` if the server API is keyed. Additional optional vars, set directly in the environment since they are not in `.env.example`: `SDVD_DISCORD_UPDATE_INTERVAL_MS` (default `30000`), `SDVD_DISCORD_BOT_NICKNAME`, `SDVD_DISCORD_CHAT_CHANNEL_ID`, `SDVD_DISCORD_STATUS_CHANNEL_ID`, `SDVD_DISCORD_STATUS_REFRESH_RATE`.

## Updates

```bash
docker compose pull
docker compose down
docker compose up -d
```

This stack has no `update_envs` entry in `ci/server-catalog.sh`, so `./tools/gs update stardew-valley` is not available, use the `docker compose pull` flow above instead. `./tools/gs backup stardew-valley` and `./tools/gs restore stardew-valley` do work since they only need the container name and the `./data` volume, see [Ops](/guides/ops/).

## Upstream docs

Full guides, API reference, and modding: [JunimoServer documentation](https://stardew-valley-dedicated-server.github.io/server/).

## See also

- [All servers](/reference/servers/) for the compose path
- [Ops](/guides/ops/) for `./tools/gs backup` and `restore`
