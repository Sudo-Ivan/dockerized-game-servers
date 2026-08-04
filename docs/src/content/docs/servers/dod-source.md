---
title: Day of Defeat Source
description: Day of Defeat Source dedicated server via SteamCMD, App 232290.
---

On first start the container downloads the Day of Defeat: Source dedicated server through Steam. After that it launches the game with VAC enabled and the usual Source dedicated server options.

:::note[Before you start]
- Open TCP port 27015, UDP port 27015, and UDP port 27005
- Keep a data folder mounted at /opt/dod-source inside the container
- SteamCMD defaults to anonymous login. If download fails, set STEAM_USERNAME and STEAM_PASSWORD for an account that owns Day of Defeat: Source. Add STEAM_GUARD_CODE if Steam asks for it
- Set DOD_GSLT if you want the server to show up in the public server browser
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | TCP | Game port. Also used for remote console once you set rcon_password in server.cfg or through DOD_EXTRA_ARGS |
| 27015 | UDP | Main game port (DOD_PORT) |
| 27005 | UDP | Client port (DOD_CLIENT_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam account used to download server files |
| STEAM_PASSWORD | (empty) | Password for STEAM_USERNAME when not using anonymous login |
| STEAM_GUARD_CODE | (empty) | One-time Steam Guard code if Steam challenges the login |
| DOD_APP_ID | 232290 | Steam app id for the dedicated server download |
| DOD_FORCE_UPDATE | false | Re-download and validate server files on next start |
| STEAMCMD_WINDOWS_WORKAROUND | full | How SteamCMD fetches depots. full downloads a Windows pass first, then Linux. prime and off are lighter options |
| DOD_PORT | 27015 | Game port |
| DOD_CLIENT_PORT | 27005 | Client port |
| DOD_MAXPLAYERS | 16 | Maximum players |
| DOD_STARTMAP | dod_anzio | Map loaded at startup |
| DOD_TICKRATE | 66 | Server tickrate |
| DOD_GSLT | (empty) | Game Server Login Token for public listing |
| DOD_EXTRA_ARGS | (empty) | Extra launch flags appended after the built-in ones |

The server always starts with the Day of Defeat game mode, console access, remote console support, VAC, and strict port binding.

## GSLT

1. Sign in at [Steam game server account management](https://steamcommunity.com/dev/managegameservers) and create a token for game id 300.
2. Set DOD_GSLT to that token in compose, a .env file, or with -e on docker run.

## Data folder

Your data folder mounts to /opt/dod-source inside the container.

| Path | Purpose |
| --- | --- |
| srcds_run | Server launcher installed by Steam |
| steam_appid.txt | Written on every start with app id 300 for Steamworks |
| dod/cfg/server.cfg | Main server config. Create this yourself |
| dod/maps/ | Custom or workshop maps |
| dod/addons/ | SourceMod or Metamod |
| bin/ | 32-bit engine libraries the server needs at startup |

## Compose

```bash
docker compose -f dockerized/dod-source/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name dod-source --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27005:27005/udp \
  -v "$PWD/dockerized/dod-source/data:/opt/dod-source" \
  -e DOD_GSLT="your-gslt" \
  {{IMAGE_PREFIX}}/dod-source:latest
```

## Updates

Set DOD_FORCE_UPDATE to true and recreate the container, or use the update workflow in [Ops](/guides/ops/).

## Health check

The container reports healthy while the game server process is running. The first install can take a while, so startup gets a 900 second grace period. With STEAMCMD_WINDOWS_WORKAROUND at its default of full, the first download runs twice (Windows depot pass, then Linux).
