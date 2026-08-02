---
title: Enshrouded
description: Enshrouded dedicated server (Windows binary via Wine).
---

This image downloads the Enshrouded dedicated server through Steam and runs the Windows build under Wine. On first start it writes dockerized/enshrouded_server.json if missing and initializes a Wine prefix.

:::note[Before you start]
- Keep a data folder for the server install, saves, and Wine prefix
- Open UDP ports 15636 (game) and 15637 (query)
- Anonymous Steam login works for most installs
- The compose file sets an 8 GB memory limit. Give the host at least that much RAM
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 15636 | UDP | Game port (ENSHROUDED_GAME_PORT) |
| 15637 | UDP | Query port (ENSHROUDED_QUERY_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used to download the server |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard dockerized/code if prompted during login |
| ENSHROUDED_APP_ID | 2278520 | Steam app id for the dedicated server tool |
| ENSHROUDED_FORCE_UPDATE | false | Reinstall the server on next start |
| ENSHROUDED_SERVER_NAME | Enshrouded Server | Server name in dockerized/enshrouded_server.json |
| ENSHROUDED_PASSWORD | (empty) | Join password in dockerized/enshrouded_server.json |
| ENSHROUDED_GAME_PORT | 15636 | Game UDP port |
| ENSHROUDED_QUERY_PORT | 15637 | Query UDP port |
| ENSHROUDED_SLOT_COUNT | 16 | Player cap in dockerized/enshrouded_server.json |
| ENSHROUDED_BIND_IP | 0.0.0.0 | Bind address in dockerized/enshrouded_server.json |
| ENSHROUDED_EXTRA_ARGS | (empty) | Extra flags appended to the launch command |

## Server settings

dockerized/enshrouded_server.json is written once from the settings above, then left alone. Edit it on the host at:

```text
dockerized/enshrouded/data/enshrouded_server.json
```

Stop the container before editing, then start it again for changes to take effect. Saves and logs default to ./savegame and ./logs relative to the server binary directory.

## Data folder

Your data folder mounts at /opt/enshrouded inside the container.

| Path | Purpose |
| --- | --- |
| .wine/ | Wine prefix, created on first start |
| dockerized/enshrouded_server.json | Server name, password, ports, and slot count |
| savegame/ | World saves, created by the game |
| logs/ | Server logs, created by the game |

If SteamCMD installs files under a nested steamapps/common folder, the container moves them up into /opt/enshrouded on first start.

## Compose

```bash
docker compose -f dockerized/enshrouded/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name enshrouded --restart unless-stopped --init \
  -p 15636:15636/udp -p 15637:15637/udp \
  -v "$PWD/dockerized/enshrouded/data:/opt/enshrouded" \
  -e ENSHROUDED_SERVER_NAME="My Enshrouded Server" \
  {{IMAGE_PREFIX}}/enshrouded:latest
```

## Updates

Set ENSHROUDED_FORCE_UPDATE to true to reinstall on the next start. You can also run ./tools/gs update enshrouded. See [Ops](/guides/ops/).

## Health check

The container reports healthy while the dockerized/enshrouded_server process is running. Startup gets a 900 second grace period.
