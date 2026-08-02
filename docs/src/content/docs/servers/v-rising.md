---
title: V Rising
description: V Rising dedicated server (Windows binary via Wine).
---

This image downloads the V Rising dedicated server through Steam and runs the Windows build under Wine. On first start it writes ServerHostSettings.json if missing and initializes a Wine prefix.

:::note[Before you start]
- Keep a data folder for the server install, saves, and Wine prefix
- Open UDP port 9876 for game traffic and UDP/TCP 9877 for queries
- Anonymous Steam login works for most installs
- The compose file sets a 6 GB memory limit. Give the host at least that much RAM
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 9876 | UDP | Game port (VRISING_PORT) |
| 9877 | UDP | Query port (VRISING_QUERY_PORT) |
| 9877 | TCP | Query port (same as UDP) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used to download the server |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard dockerized/code if prompted during login |
| VRISING_APP_ID | 1829350 | Steam app id for the dedicated server tool |
| VRISING_STEAM_APP_ID | 1604030 | Game app id, written to steam_appid.txt |
| VRISING_FORCE_UPDATE | false | Reinstall the server on next start |
| VRISING_PORT | 9876 | Game UDP port |
| VRISING_QUERY_PORT | 9877 | Query UDP/TCP port |
| VRISING_SERVER_NAME | V Rising Server | Server name in ServerHostSettings.json |
| VRISING_MAX_PLAYERS | 40 | Player cap in ServerHostSettings.json |
| VRISING_PASSWORD | (empty) | Join password in ServerHostSettings.json |
| VRISING_SAVE_NAME | world1 | Save slot name in ServerHostSettings.json |
| VRISING_EXTRA_ARGS | (empty) | Extra flags appended to the launch command |

## Server settings

ServerHostSettings.json is written once from the settings above, then left alone. Edit it on the host at:

```text
dockerized/v-rising/data/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json
```

Stop the container before editing, then start it again for changes to take effect.

## Data folder

Your data folder mounts at /opt/vrising inside the container.

| Path | Purpose |
| --- | --- |
| .wine/ | Wine prefix, created on first start |
| steam_appid.txt | Rewritten every start with VRISING_STEAM_APP_ID |
| VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json | Server name, ports, password, and save name |

If SteamCMD installs files under a nested steamapps/common folder, the container moves them up into /opt/vrising on first start.

## Compose

```bash
docker compose -f dockerized/v-rising/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name v-rising --restart unless-stopped --init \
  -p 9876:9876/udp -p 9877:9877/udp -p 9877:9877/tcp \
  -v "$PWD/dockerized/v-rising/data:/opt/vrising" \
  -e VRISING_SERVER_NAME="My V Rising Server" \
  {{IMAGE_PREFIX}}/v-rising:latest
```

## Updates

Set VRISING_FORCE_UPDATE to true to reinstall on the next start. You can also run ./tools/gs update v-rising. See [Ops](/guides/ops/).

## Health check

The container reports healthy while the VRisingServer process is running. Startup gets a 900 second grace period.
