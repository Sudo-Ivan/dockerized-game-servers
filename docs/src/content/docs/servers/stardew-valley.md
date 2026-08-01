---
title: Stardew Valley
description: Always-on farm via JunimoServer (external Docker images).
---

This stack runs an always-on Stardew Valley farm using [JunimoServer](https://github.com/stardew-valley-dedicated-server/server) images (sdvd/server, sdvd/steam-service). It runs the game headless with SMAPI, optional VNC admin, HTTP API, backups, and mod support. You need a Steam account that owns Stardew Valley to download game files.

:::note[Before you start]
- Keep data folders for the game install, Steam session, saves, and settings
- Open UDP port 24642 for multiplayer, UDP 27015 for Steam query, TCP 5800 for VNC admin, and TCP 8080 for the HTTP API
- Copy .env.example to .env and set STEAM_USERNAME, STEAM_PASSWORD, and SDVD_VNC_PASSWORD before first start
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 24642 | UDP | Multiplayer (Steam relay) |
| 27015 | UDP | Steam query |
| 5800 | TCP | VNC web admin (SDVD_VNC_PASSWORD) |
| 8080 | TCP | HTTP API (SDVD_API_ENABLED) |

## Data folders

All paths are under stardew-valley/data/ on the host:

| Mount | Container path | Purpose |
| --- | --- | --- |
| game | /data/game | Game install (Steam download) |
| steam-session | /data/steam-session | Steam login session |
| saves | /config/xdg/config/StardewValley | Save games |
| settings | /data/settings | server-settings.json |

## Quick start

```bash
cd stardew-valley
cp .env.example .env
# Edit .env: STEAM_USERNAME, STEAM_PASSWORD, SDVD_VNC_PASSWORD
docker compose run --rm -it steam-auth setup
docker compose up -d
docker compose logs -f server
```

steam-auth setup handles Steam Guard and the initial game download into data/game.

## Settings

Prefix SDVD_ avoids clashes with other compose stacks. Steam credentials use STEAM_USERNAME and STEAM_PASSWORD, or STEAM_REFRESH_TOKEN for refresh-token login instead of a password.

| Setting | Default | What it does |
| --- | --- | --- |
| SDVD_IMAGE_VERSION | latest | Junimo image tag for server, steam-auth, and discord-bot |
| SDVD_VNC_PASSWORD | (empty) | VNC web UI password |
| SDVD_ALLOW_INSECURE_SETUP | false | Allow the VNC/API to run without a password set |
| SDVD_API_ENABLED | true | Enable the HTTP API |
| SDVD_API_KEY | (empty) | Protects API write endpoints |
| SDVD_SERVER_PASSWORD | (empty) | In-game !login password, empty disables |
| SDVD_SERVER_TPS | 60 | Simulation rate |
| SDVD_SERVER_FPS | 0 | VNC render FPS, 0 disables rendering |
| SDVD_MAX_LOGIN_ATTEMPTS | 3 | Failed !login attempts before lockout |
| SDVD_AUTH_TIMEOUT_SECONDS | 120 | Seconds before an unauthenticated session is dropped |
| SDVD_STEAM_KEEP_LANGUAGES | (empty) | Passed to steam-auth to filter Steam download languages |

Host port overrides (container ports stay fixed): SDVD_VNC_PORT, SDVD_API_PORT, SDVD_GAME_PORT, SDVD_QUERY_PORT. SDVD_STEAM_AUTH_PORT (default 3001) is the internal server-to-steam-auth link and is not published.

See stardew-valley/.env.example for Steam login and common overrides. The discord-bot service takes its own vars directly in docker-compose.yml.

## Discord bot (optional)

```bash
docker compose --profile discord up -d
```

Set SDVD_DISCORD_BOT_TOKEN in .env. Requires SDVD_API_KEY if the server API is keyed. Additional optional vars: SDVD_DISCORD_UPDATE_INTERVAL_MS (default 30000), SDVD_DISCORD_BOT_NICKNAME, SDVD_DISCORD_CHAT_CHANNEL_ID, SDVD_DISCORD_STATUS_CHANNEL_ID, SDVD_DISCORD_STATUS_REFRESH_RATE.

## Updates

./tools/gs update stardew-valley is not available. Pull newer images instead:

```bash
docker compose pull
docker compose down
docker compose up -d
```

./tools/gs backup stardew-valley and restore do work. See [Ops](/guides/ops/).

## Upstream docs

Full guides, API reference, and modding: [JunimoServer documentation](https://stardew-valley-dedicated-server.github.io/server/).

## See also

- [All servers](/reference/servers/) for the compose path
- [Ops](/guides/ops/) for ./tools/gs backup and restore
