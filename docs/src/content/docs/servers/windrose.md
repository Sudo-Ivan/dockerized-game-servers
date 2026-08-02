---
title: Windrose
description: Windrose dedicated server (Windows binary via Wine).
---

This image downloads the Windrose dedicated server through Steam and runs the Windows build under Wine. On first start it writes R5/ServerDescription.json if missing and initializes a Wine prefix.

:::note[Before you start]
- Keep a data folder for the server install and Wine prefix
- Open TCP and UDP port 7777 for direct connection
- Anonymous Steam login works for most installs
- The compose file sets an 8 GB memory limit. Give the host at least that much RAM
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7777 | TCP | Direct connection port (WINDROSE_DIRECT_PORT) |
| 7777 | UDP | Direct connection port (WINDROSE_DIRECT_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used to download the server |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard code if prompted during login |
| WINDROSE_APP_ID | 4129620 | Steam app id for the dedicated server tool |
| WINDROSE_FORCE_UPDATE | false | Reinstall the server on next start |
| WINDROSE_SERVER_NAME | Windrose Server | Server name in ServerDescription.json |
| WINDROSE_DIRECT_PORT | 7777 | Direct connection TCP/UDP port |
| WINDROSE_MAX_PLAYERS | 4 | Player cap in ServerDescription.json |
| WINDROSE_PASSWORD | (empty) | Join password in ServerDescription.json |
| WINDROSE_EXTRA_ARGS | (empty) | Extra flags appended to the launch command |

## Server settings

R5/ServerDescription.json is written once from the settings above, then left alone. Edit it on the host at:

```text
windrose/data/R5/ServerDescription.json
```

Stop the container before editing, then start it again for changes to take effect.

## Data folder

Your data folder mounts at /opt/windrose inside the container.

| Path | Purpose |
| --- | --- |
| .wine/ | Wine prefix, created on first start |
| R5/ServerDescription.json | Server name, password, player cap, and direct connection port |

If SteamCMD installs files under a nested steamapps/common folder, the container moves them up into /opt/windrose on first start.

## Compose

```bash
docker compose -f windrose/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name windrose --restart unless-stopped --init \
  -p 7777:7777/tcp -p 7777:7777/udp \
  -v "$PWD/windrose/data:/opt/windrose" \
  -e WINDROSE_SERVER_NAME="My Windrose Server" \
  {{IMAGE_PREFIX}}/windrose:latest
```

## Updates

Set WINDROSE_FORCE_UPDATE to true to reinstall on the next start. You can also run ./tools/gs update windrose. See [Ops](/guides/ops/).

## Health check

The container reports healthy while the WindroseServer process is running. Startup gets a 900 second grace period.
