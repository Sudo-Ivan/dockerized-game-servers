---
title: Unturned
description: Unturned dedicated server via SteamCMD, App 1110390.
---

On first start the container downloads the Unturned dedicated server (Steam app 1110390, not the client app 304930) into your data folder, then launches ServerHelper.sh with +InternetServer/name.

:::note[Before you start]
- Open UDP ports 27015 and 27016
- Keep a data folder for the installed server and config
- Give the container at least 4 GB of RAM
- No Steam account is needed. The server installs anonymously through SteamCMD
- For public listing, create a GSLT for game ID 304930 and configure it under Servers/ or through UNTURNED_EXTRA_ARGS
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | UDP | Main game port |
| 27016 | UDP | Secondary game port |

Unturned uses UDP only for gameplay. Do not publish TCP on these ports.

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used during the install step |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard code |
| UNTURNED_APP_ID | 1110390 | SteamCMD app ID for the dedicated server depot |
| UNTURNED_FORCE_UPDATE | false | Re-download the server from Steam on next start |
| UNTURNED_SERVER_NAME | UnturnedServer | Internet server slot name, passed as +InternetServer/name |
| UNTURNED_EXTRA_ARGS | (empty) | Extra command-line flags added after the InternetServer argument |

See [Quick start](/guides/quick-start/) if you need to log in with a real Steam account for the install step.

## GSLT

SteamCMD installs app 1110390, but public server tokens are created for game ID 304930 at [Steam game server account management](https://steamcommunity.com/dev/managegameservers). Add the token in your server config under Servers/UNTURNED_SERVER_NAME/ or pass it through UNTURNED_EXTRA_ARGS.

## Data folder

Your data folder mounts to /opt/unturned inside the container.

| Path | Purpose |
| --- | --- |
| ServerHelper.sh | Server launcher, installed by SteamCMD |
| Servers/ | Per-server config folders keyed by UNTURNED_SERVER_NAME |
| Maps/ | Custom maps |

## Compose

```bash
docker compose -f dockerized/unturned/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name unturned --restart unless-stopped --init \
  -p 27015:27015/udp -p 27016:27016/udp \
  -v "$PWD/dockerized/unturned/data:/opt/unturned" \
  -e UNTURNED_SERVER_NAME="MyUnturnedServer" \
  {{IMAGE_PREFIX}}/unturned:latest
```

## Updates

Set UNTURNED_FORCE_UPDATE to true and recreate the container, or use the update command described in [Ops](/guides/ops/).

## Health check

The container reports healthy while the Unturned server is running. Startup gets a 600 second grace period.
