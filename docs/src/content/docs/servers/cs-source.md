---
title: Counter-Strike Source
description: Counter-Strike Source dedicated server via SteamCMD, App 232330.
---

On first start the container downloads the Counter-Strike: Source dedicated server through Steam, then launches it as a native Linux server with VAC always enabled.

:::note[Before you start]
- Open TCP port 27015, UDP port 27015, and UDP port 27005
- Keep a data folder mounted at /opt/cs-source inside the container
- SteamCMD defaults to anonymous login. If download fails, set STEAM_USERNAME and STEAM_PASSWORD for an account that owns Counter-Strike: Source. Add STEAM_GUARD_CODE if Steam asks for it
- Set CSS_GSLT if you want the server to show up in the public server browser
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | TCP | Game port. Also used for remote console once you set rcon_password in server.cfg or through CSS_EXTRA_ARGS |
| 27015 | UDP | Main game port (CSS_PORT) |
| 27005 | UDP | Client port (CSS_CLIENT_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam account used to download server files |
| STEAM_PASSWORD | (empty) | Password for STEAM_USERNAME when not using anonymous login |
| STEAM_GUARD_CODE | (empty) | One-time Steam Guard code if Steam challenges the login |
| CSS_APP_ID | 232330 | Steam app id for the dedicated server download |
| CSS_FORCE_UPDATE | false | Re-download and validate server files on next start |
| STEAMCMD_WINDOWS_WORKAROUND | full | How SteamCMD fetches depots. full downloads a Windows pass first, then Linux. prime and off are lighter options |
| CSS_PORT | 27015 | Game port |
| CSS_CLIENT_PORT | 27005 | Client port |
| CSS_MAXPLAYERS | 16 | Maximum players |
| CSS_STARTMAP | de_dust2 | Map loaded at startup |
| CSS_TICKRATE | 66 | Server tickrate |
| CSS_GSLT | (empty) | Game Server Login Token for public listing |
| CSS_EXTRA_ARGS | (empty) | Extra launch flags appended after the built-in ones |

The server always starts with the Counter-Strike game mode, console access, remote console support, VAC, and strict port binding.

## GSLT

1. Sign in at [Steam game server account management](https://steamcommunity.com/dev/managegameservers) and create a token for game id 240.
2. Set CSS_GSLT to that token in compose, a .env file, or with -e on docker run.

## Data folder

Your data folder mounts to /opt/cs-source inside the container.

| Path | Purpose |
| --- | --- |
| srcds_run | Server launcher installed by Steam |
| steam_appid.txt | Written on every start with app id 240 for Steamworks |
| cstrike/cfg/server.cfg | Main server config. Create this yourself |
| cstrike/maps/ | Custom or workshop maps |
| cstrike/addons/ | SourceMod or Metamod if you add plugins |
| bin/ | 32-bit engine libraries the server needs at startup |

## Updates

Set CSS_FORCE_UPDATE to true and recreate the container, or use the update workflow in [Ops](/guides/ops/).

## Health check

The container reports healthy while the game server process is running. Startup gets a 600 second grace period.

## Notes

- The container starts as root, fixes ownership of the data folder, then runs the server as the cssource user (uid 1000).
- The launcher script is cleaned of Windows line endings on every start.
- This server needs the bundled 32-bit libraries in bin/, which are added to the library path before launch.
- VAC is always on and cannot be turned off through settings.
- There is no dedicated remote console setting. TCP port 27015 handles remote console once you set rcon_password in server.cfg.
- With STEAMCMD_WINDOWS_WORKAROUND at its default of full, the first download runs twice (Windows depot pass, then Linux).
- Compose sets a 2 GB memory limit and a 90 second stop grace period. The image sends SIGINT on stop so the server can shut down cleanly.

## Compose

```bash
docker compose -f dockerized/cs-source/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cs-source --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27005:27005/udp \
  -v "$PWD/dockerized/cs-source/data:/opt/cs-source" \
  -e CSS_GSLT="your-gslt" \
  {{IMAGE_PREFIX}}/cs-source:latest
```
