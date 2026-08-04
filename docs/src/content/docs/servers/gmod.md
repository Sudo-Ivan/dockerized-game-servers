---
title: Garry's Mod
description: Garry's Mod dedicated server via SteamCMD, App 4020.
---

On first start the container downloads the Garry's Mod dedicated server through Steam. After that it launches the game with VAC enabled and the usual Source dedicated server options.

:::note[Before you start]
- Open TCP port 27015, UDP port 27015, and UDP port 27005
- Keep a data folder mounted at /opt/gmod inside the container
- Give the container at least 4 GB of RAM
- SteamCMD defaults to anonymous login. If download fails, set STEAM_USERNAME and STEAM_PASSWORD for an account that owns Garry's Mod. Add STEAM_GUARD_CODE if Steam asks for it
- Set GMOD_GSLT if you want the server to show up in the public server browser
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | TCP | Game port. Also used for remote console once you set rcon_password in server.cfg or through GMOD_EXTRA_ARGS |
| 27015 | UDP | Main game port (GMOD_PORT) |
| 27005 | UDP | Client port (GMOD_CLIENT_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam account used to download server files |
| STEAM_PASSWORD | (empty) | Password for STEAM_USERNAME when not using anonymous login |
| STEAM_GUARD_CODE | (empty) | One-time Steam Guard code if Steam challenges the login |
| GMOD_APP_ID | 4020 | Steam app id for the dedicated server download |
| GMOD_FORCE_UPDATE | false | Re-download and validate server files on next start |
| STEAMCMD_WINDOWS_WORKAROUND | full | How SteamCMD fetches depots. full downloads a Windows pass first, then Linux. prime and off are lighter options |
| GMOD_PORT | 27015 | Game port |
| GMOD_CLIENT_PORT | 27005 | Client port |
| GMOD_MAXPLAYERS | 16 | Maximum players |
| GMOD_STARTMAP | gm_flatgrass | Map loaded at startup |
| GMOD_TICKRATE | 66 | Server tickrate |
| GMOD_GSLT | (empty) | Game Server Login Token for public listing |
| GMOD_EXTRA_ARGS | (empty) | Extra launch flags appended after the built-in ones |

The server always starts with the Garry's Mod game mode, console access, remote console support, VAC, and strict port binding.

## GSLT

1. Sign in at [Steam game server account management](https://steamcommunity.com/dev/managegameservers) and create a token for game id 4000.
2. Set GMOD_GSLT to that token in compose, a .env file, or with -e on docker run.

## Data folder

Your data folder mounts to /opt/gmod inside the container.

| Path | Purpose |
| --- | --- |
| srcds_run | Server launcher installed by Steam |
| steam_appid.txt | Written on every start with app id 4000 for Steamworks |
| garrysmod/cfg/server.cfg | Main server config. Create this yourself |
| garrysmod/maps/ | Custom maps |
| garrysmod/addons/ | Workshop content, Lua addons, SourceMod, and Metamod |
| bin/ | 32-bit engine libraries the server needs at startup |

## Compose

```bash
docker compose -f dockerized/gmod/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name gmod --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27005:27005/udp \
  -v "$PWD/dockerized/gmod/data:/opt/gmod" \
  -e GMOD_GSLT="your-gslt" \
  {{IMAGE_PREFIX}}/gmod:latest
```

## Updates

Set GMOD_FORCE_UPDATE to true and recreate the container, or use the update workflow in [Ops](/guides/ops/).

## Health check

The container reports healthy while the game server process is running. The first install can take a while, so startup gets a 900 second grace period. With STEAMCMD_WINDOWS_WORKAROUND at its default of full, the first download runs twice (Windows depot pass, then Linux).
