---
title: Team Fortress 2
description: Team Fortress 2 dedicated server via SteamCMD, App 232250.
---

On first start the container downloads the Team Fortress 2 dedicated server through Steam. After that it launches the game with VAC enabled and the usual Source dedicated server options.

:::note[Before you start]
- Open TCP port 27015, UDP port 27015, and UDP port 27005
- Keep a data folder mounted at /opt/tf2 inside the container
- Give the container at least 4 GB of RAM
- Anonymous Steam login usually works. If the install fails, set STEAM_USERNAME and STEAM_PASSWORD for an account that owns Team Fortress 2. Add STEAM_GUARD_CODE if Steam asks for it
- Set TF2_GSLT if you want the server to show up in the public server browser
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | TCP | Game port. Also used for remote console once you set rcon_password in server.cfg or through TF2_EXTRA_ARGS |
| 27015 | UDP | Main game port (TF2_PORT) |
| 27005 | UDP | Client port (TF2_CLIENT_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam account used to download server files |
| STEAM_PASSWORD | (empty) | Password for STEAM_USERNAME when not using anonymous login |
| STEAM_GUARD_CODE | (empty) | One-time Steam Guard code if Steam challenges the login |
| TF2_APP_ID | 232250 | Steam app id for the dedicated server download |
| TF2_FORCE_UPDATE | false | Re-download and validate server files on next start |
| STEAMCMD_WINDOWS_WORKAROUND | full | How SteamCMD fetches depots. full downloads a Windows pass first, then Linux. prime and off are lighter options |
| TF2_PORT | 27015 | Game port |
| TF2_CLIENT_PORT | 27005 | Client port |
| TF2_MAXPLAYERS | 24 | Maximum players |
| TF2_STARTMAP | cp_dustbowl | Map loaded at startup |
| TF2_TICKRATE | 66 | Server tickrate |
| TF2_GSLT | (empty) | Game Server Login Token for public listing |
| TF2_EXTRA_ARGS | (empty) | Extra launch flags appended after the built-in ones |

The server always starts with the Team Fortress 2 game mode, console access, remote console support, VAC, and strict port binding.

## GSLT

1. Sign in at [Steam game server account management](https://steamcommunity.com/dev/managegameservers) and create a token for game id 440.
2. Set TF2_GSLT to that token in compose, a .env file, or with -e on docker run.

## Data folder

Your data folder mounts to /opt/tf2 inside the container.

| Path | Purpose |
| --- | --- |
| srcds_run | Server launcher installed by Steam |
| steam_appid.txt | Written on every start with app id 440 for Steamworks |
| tf/cfg/server.cfg | Main server config. Create this yourself |
| tf/maps/ | Custom or workshop maps |
| tf/addons/ | SourceMod or Metamod |
| bin/ | 32-bit engine libraries the server needs at startup |

## Compose

```bash
docker compose -f tf2/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name tf2 --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27005:27005/udp \
  -v "$PWD/tf2/data:/opt/tf2" \
  -e TF2_GSLT="your-gslt" \
  {{IMAGE_PREFIX}}/tf2:latest
```

## Updates

Set TF2_FORCE_UPDATE to true and recreate the container, or use the update workflow in [Ops](/guides/ops/).

## Health check

The container reports healthy while the game server process is running. The first install can take a while, so startup gets a 900 second grace period. With STEAMCMD_WINDOWS_WORKAROUND at its default of full, the first download runs twice (Windows depot pass, then Linux).
