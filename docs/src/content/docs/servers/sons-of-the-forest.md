---
title: Sons Of The Forest
description: Sons Of The Forest dedicated server (Windows binary via Wine).
---

This image downloads the Sons Of The Forest dedicated server through Steam and runs the Windows build under Wine. Unlike most servers here, anonymous Steam login does not work. You need a Steam account that owns Sons Of The Forest.

:::note[Before you start]
- Keep a data folder for the server install and saves
- Open UDP port 8766 for game traffic, UDP 27016 for queries, and UDP 9700 for BlobSync
- Set STEAM_USERNAME and STEAM_PASSWORD for an account that owns the game
- The compose file sets a 6 GB memory limit. Give the host at least that much RAM
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 8766 | UDP | Game traffic (SOTF_GAME_PORT) |
| 27016 | UDP | Server browser query (SOTF_QUERY_PORT) |
| 9700 | UDP | BlobSync, large data transfer between clients and the server |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used to download the server |
| STEAM_PASSWORD | (empty) | Steam password, required for this server |
| STEAM_GUARD_CODE | (empty) | Steam Guard dockerized/code if prompted during login |
| SOTF_APP_ID | 2465200 | Steam app id for the dedicated server tool |
| SOTF_STEAM_APP_ID | 1326470 | Game app id, written to steam_appid.txt |
| SOTF_FORCE_UPDATE | false | Reinstall the server on next start |
| SOTF_IP | 0.0.0.0 | Bind address in dedicatedserver.cfg |
| SOTF_GAME_PORT | 8766 | Game UDP port |
| SOTF_QUERY_PORT | 27016 | Query UDP port |
| SOTF_BLOB_SYNC_PORT | 9700 | BlobSync UDP port |
| SOTF_SERVER_NAME | Sons Of The Forest Server (dedicated) | Name shown in the server list |
| SOTF_MAX_PLAYERS | 8 | Player cap, 1 to 8 |
| SOTF_PASSWORD | (empty) | Join password, empty for an open server |
| SOTF_LAN_ONLY | false | Set true to hide from the public list |
| SOTF_SAVE_SLOT | 1 | Save slot number |
| SOTF_SAVE_MODE | Continue | New or Continue. Continue creates the slot if it does not exist |
| SOTF_GAME_MODE | Normal | Normal, Hard, Hardsurvival, Peaceful, or Custom |
| SOTF_SAVE_INTERVAL | 600 | Autosave interval in seconds |
| SOTF_EXTRA_ARGS | (empty) | Extra flags appended to the launch command |

## Data folder

Your data folder mounts at /opt/sotf inside the container.

| Path | Purpose |
| --- | --- |
| userdata/dedicatedserver.cfg | JSON config, written once from the settings above then left alone. Edit directly for game settings not exposed as settings |
| userdata/ownerswhitelist.txt | Created empty once. Add one Steam64 ID per line to grant in-game admin |
| .wine/ | Wine prefix, created on first start |
| steam_appid.txt | Rewritten every start with SOTF_STEAM_APP_ID |

If SteamCMD installs files under a nested steamapps/common folder, the container moves them up into /opt/sotf on first start.

The container fixes file ownership on the data folder automatically on every start.

## Updates

Set SOTF_FORCE_UPDATE to true to reinstall on the next start. You can also run ./tools/gs update sons-of-the-forest. See [Ops](/guides/ops/).

## Health check

The container reports healthy while the Sons Of The Forest server process is running. Startup gets a 900 second grace period.

## Compose

```bash
docker compose -f dockerized/sons-of-the-forest/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name sons-of-the-forest --restart unless-stopped --init \
  -p 8766:8766/udp -p 27016:27016/udp -p 9700:9700/udp \
  -v "$PWD/dockerized/sons-of-the-forest/data:/opt/sotf" \
  -e SOTF_SERVER_NAME="My SOTF Server" \
  {{IMAGE_PREFIX}}/sons-of-the-forest:latest
```
