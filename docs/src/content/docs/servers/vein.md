---
title: VEIN
description: VEIN dedicated server (Windows binary via Wine).
---

This image downloads the VEIN dedicated server through Steam and runs the Windows build under Wine. Settings are passed as launch arguments. On first start it initializes a Wine prefix.

:::note[Before you start]
- Keep a data folder for the server install and Wine prefix
- Open UDP port 7777 for game traffic and UDP 27015 for Steam server browser queries
- Anonymous Steam login works for most installs
- The compose file sets an 8 GB memory limit. Give the host at least that much RAM
- Only one service on the host should use UDP 27015 unless you change VEIN_QUERY_PORT and the published port mapping
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7777 | UDP | Game port (VEIN_PORT) |
| 27015 | UDP | Steam query port (VEIN_QUERY_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used to download the server |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard dockerized/code if prompted during login |
| VEIN_APP_ID | 2131400 | Steam app id for the dedicated server tool |
| VEIN_FORCE_UPDATE | false | Reinstall the server on next start |
| VEIN_PORT | 7777 | Game UDP port, passed as -port= |
| VEIN_QUERY_PORT | 27015 | Query UDP port, passed as -QueryPort= |
| VEIN_MAX_PLAYERS | 16 | Player cap, passed as -MaxPlayers= |
| VEIN_EXTRA_ARGS | (empty) | Extra flags appended to the launch command |

## Data folder

Your data folder mounts at /opt/vein inside the container.

| Path | Purpose |
| --- | --- |
| .wine/ | Wine prefix, created on first start |
| game install tree | Wherever SteamCMD placed the VeinServer executable |

The container does not write a config file. All settings above are launch arguments. If SteamCMD installs files under a nested steamapps/common folder, the container moves them up into /opt/vein on first start.

## Compose

```bash
docker compose -f dockerized/vein/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name vein --restart unless-stopped --init \
  -p 7777:7777/udp -p 27015:27015/udp \
  -v "$PWD/dockerized/vein/data:/opt/vein" \
  -e VEIN_MAX_PLAYERS=16 \
  {{IMAGE_PREFIX}}/vein:latest
```

## Updates

Set VEIN_FORCE_UPDATE to true to reinstall on the next start. You can also run ./tools/gs update vein. See [Ops](/guides/ops/).

## Health check

The container reports healthy while the VeinServer process is running. Startup gets a 900 second grace period.
