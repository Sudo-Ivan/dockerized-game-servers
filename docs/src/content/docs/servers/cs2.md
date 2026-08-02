---
title: Counter-Strike 2
description: Counter-Strike 2 dedicated server via SteamCMD, App 730.
---

On first start the container downloads the Counter-Strike 2 dedicated server through Steam into your data folder, then launches it in dedicated mode. Plan for roughly 60 GB of disk space for a full install.

:::note[Before you start]
- Open TCP port 27015, UDP port 27015, and UDP port 27020
- Keep a data folder mounted at /opt/cs2 inside the container
- Give the container at least 8 GB of RAM
- Anonymous Steam login usually works. If the install fails, set STEAM_USERNAME and STEAM_PASSWORD. Add STEAM_GUARD_CODE if Steam asks for it
- Set CS2_GSLT if you want the server to show up in the public server browser
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | TCP | Game port and remote console (CS2_PORT) |
| 27015 | UDP | Main game port (CS2_PORT) |
| 27020 | UDP | Steam server query port |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam account used to download server files |
| STEAM_PASSWORD | (empty) | Password for STEAM_USERNAME when not using anonymous login |
| STEAM_GUARD_CODE | (empty) | One-time Steam Guard dockerized/code if Steam challenges the login |
| CS2_APP_ID | 730 | Steam app id for the dedicated server download |
| CS2_FORCE_UPDATE | false | Re-download and validate server files on next start |
| CS2_PORT | 27015 | Game port |
| CS2_MAXPLAYERS | 10 | Maximum players |
| CS2_STARTMAP | de_dust2 | Map loaded at startup |
| CS2_GAME_TYPE | 0 | Game type |
| CS2_GAME_MODE | 1 | Game mode |
| CS2_GSLT | (empty) | Game Server Login Token for public listing |
| CS2_EXTRA_ARGS | (empty) | Extra launch flags appended after the built-in ones |

The server always starts in dedicated mode, bound to all interfaces, with LAN mode off.

## GSLT

1. Sign in at [Steam game server account management](https://steamcommunity.com/dev/managegameservers) and create a token for game id 730.
2. Set CS2_GSLT to that token in compose, a .env file, or with -e on docker run.

## Data folder

Your data folder mounts to /opt/cs2 inside the container.

| Path | Purpose |
| --- | --- |
| game/bin/linuxsteamrt64/cs2 | Dedicated server binary installed by Steam |
| game/csgo/cfg/ | Server config files |
| game/csgo/maps/ | Maps and workshop content |

## Compose

```bash
docker compose -f dockerized/cs2/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cs2 --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27020:27020/udp \
  -v "$PWD/dockerized/cs2/data:/opt/cs2" \
  -e CS2_GSLT="your-gslt" \
  {{IMAGE_PREFIX}}/cs2:latest
```

## Updates

Set CS2_FORCE_UPDATE to true and recreate the container, or use the update workflow in [Ops](/guides/ops/).

## Health check

The container reports healthy while the game server process is running. The first install is large, so startup gets an 1800 second grace period.
