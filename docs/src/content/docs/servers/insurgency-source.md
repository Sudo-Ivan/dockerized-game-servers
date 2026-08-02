---
title: Insurgency Source
description: Insurgency (2014) Source dedicated server via SteamCMD, App 237410.
---

On first start the container downloads the Insurgency (2014) dedicated server through Steam, then launches it as a native Linux server.

:::note[Before you start]
- Open TCP port 27015, UDP port 27015, and UDP port 27016
- Keep a data folder mounted at /opt/insurgency-source inside the container
- Anonymous Steam login usually works. If the install fails, set STEAM_USERNAME and STEAM_PASSWORD for an account that owns Insurgency. Add STEAM_GUARD_CODE if Steam asks for it
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | TCP | Game port. Also used for remote console once you set rcon_password in server.cfg or through INS_SOURCE_EXTRA_ARGS |
| 27015 | UDP | Main game port (INS_SOURCE_PORT) |
| 27016 | UDP | Client port (INS_SOURCE_CLIENT_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam account used to download server files |
| STEAM_PASSWORD | (empty) | Password for STEAM_USERNAME when not using anonymous login |
| STEAM_GUARD_CODE | (empty) | One-time Steam Guard dockerized/code if Steam challenges the login |
| INS_SOURCE_APP_ID | 237410 | Steam app id for the dedicated server download |
| INS_SOURCE_FORCE_UPDATE | false | Re-download and validate server files on next start |
| STEAMCMD_WINDOWS_WORKAROUND | full | How SteamCMD fetches depots. full downloads a Windows pass first, then Linux. prime and off are lighter options |
| INS_SOURCE_PORT | 27015 | Game port |
| INS_SOURCE_CLIENT_PORT | 27016 | Client port |
| INS_SOURCE_MAXPLAYERS | 16 | Maximum players |
| INS_SOURCE_STARTMAP | ministry | Map loaded at startup |
| INS_SOURCE_TICKRATE | 128 | Server tickrate |
| INS_SOURCE_EXTRA_ARGS | (empty) | Extra launch flags appended after the built-in ones |

The server always starts with the Insurgency game mode, console access, remote console support, and strict port binding.

## Data folder

Your data folder mounts to /opt/insurgency-source inside the container.

| Path | Purpose |
| --- | --- |
| srcds_run | Server launcher installed by Steam |
| steam_appid.txt | Written on every start with app id 222880 for Steamworks |
| insurgency/cfg/server.cfg | Main server config. Create this yourself |
| insurgency/maps/ | Custom or workshop maps |
| insurgency/addons/ | SourceMod or Metamod if you add plugins |

## Updates

Set INS_SOURCE_FORCE_UPDATE to true and recreate the container, or use the update workflow in [Ops](/guides/ops/).

## Health check

The container reports healthy while the game server process is running. Startup gets a 600 second grace period.

## Notes

- The container starts as root, fixes ownership of the data folder, then runs the server as the inssource user (uid 1000).
- The launcher script is cleaned of Windows line endings on every start. This is a known quirk of the Insurgency Source download.
- There is no dedicated remote console setting. TCP port 27015 handles remote console once you set rcon_password in server.cfg.
- Strict port binding is always on. If INS_SOURCE_PORT or INS_SOURCE_CLIENT_PORT is already in use, the server exits instead of picking another port.
- With STEAMCMD_WINDOWS_WORKAROUND at its default of full, the first download runs twice (Windows depot pass, then Linux).
- Compose sets a 2 GB memory limit and a 90 second stop grace period. The image sends SIGINT on stop so the server can shut down cleanly.

## Compose

```bash
docker compose -f dockerized/insurgency-source/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name insurgency-source --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27016:27016/udp \
  -v "$PWD/dockerized/insurgency-source/data:/opt/insurgency-source" \
  -e STEAM_USERNAME="your_steam_user" \
  -e STEAM_PASSWORD="your_steam_password" \
  {{IMAGE_PREFIX}}/insurgency-source:latest
```
