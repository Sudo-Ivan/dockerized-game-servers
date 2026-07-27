---
title: Factorio
description: Factorio dedicated headless server.
iconFit: contain
---

Compose path: `factorio`. Image: `factorio`.

Downloads the official headless package from factorio.com. `FACTORIO_VERSION` defaults to `stable`. Creates `saves/<SAVE_NAME>.zip` on first start and writes `config/server-settings.json` if missing.

## Ports

- UDP **34197** (game, `PORT`)
- TCP **27015** (RCON when `RCON_PASSWORD` is set)

## Configuration

| Variable | Purpose |
| --- | --- |
| `FACTORIO_VERSION` | Release channel or version string from factorio.com |
| `FACTORIO_FORCE_UPDATE` | Re-download headless package on start |
| `SERVER_NAME` / `SERVER_DESCRIPTION` | Listing metadata |
| `SERVER_PASSWORD` | Join password (empty for open) |
| `SAVE_NAME` | Save file base name under `saves/` |
| `RCON_PASSWORD` | Enables RCON on `RCON_PORT` |
| `PUBLIC_VISIBILITY` / `LAN_VISIBILITY` | Browser visibility flags |
| `FACTORIO_EXTRA_ARGS` | Extra CLI flags |

Edit `factorio/data/config/` after the first run for advanced settings and blueprints.

## Compose

```bash
export RCON_PASSWORD=changeme
docker compose -f factorio/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name factorio --restart unless-stopped --init \
  -p 34197:34197/udp -p 27015:27015/tcp \
  -v "$PWD/factorio/data:/opt/factorio" \
  -e RCON_PASSWORD=changeme \
  {{IMAGE_PREFIX}}/factorio:latest
```

Mods: place them under `factorio/data/mods/` and restart. Match mod versions to your Factorio server version.
