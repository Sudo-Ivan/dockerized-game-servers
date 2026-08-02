---
title: Ground Branch
description: Ground Branch dedicated server (Windows binary via Wine).
---

This image downloads the Ground Branch dedicated server through Steam and runs the Windows build under Wine. On first start it also sets up a Wine environment, so expect the initial launch to take longer than later restarts.

:::note[Before you start]
- Keep a data folder for the server install and config
- Open UDP port 7777 for game traffic and UDP 27015 for server browser queries
- Anonymous Steam login works for most installs. If the download fails, use a Steam account that owns Ground Branch
- The compose file sets a 4 GB memory limit. Raise it if the server struggles under load
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7777 | UDP | Game traffic (GB_PORT) |
| 27015 | UDP | Server browser query (GB_QUERY_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used to download the server |
| STEAM_PASSWORD | (empty) | Steam password, required when using a real account |
| STEAM_GUARD_CODE | (empty) | Steam Guard dockerized/code if prompted during login |
| GB_APP_ID | 476400 | Steam app id for the dedicated server tool |
| GB_STEAM_APP_ID | 16900 | Ground Branch game app id, written to steam_appid.txt on every start |
| GB_FORCE_UPDATE | false | Reinstall the server on next start |
| GB_PORT | 7777 | Game UDP port |
| GB_QUERY_PORT | 27015 | Query UDP port |
| GB_MULTIHOME | 0.0.0.0 | Bind address, passed as MultiHome= |
| GB_MAX_PLAYERS | 8 | Player cap, passed as MaxPlayers= |
| GB_MAX_AI | 30 | AI bot cap, passed as MaxAI= |
| GB_MAP | (empty) | Map to load on launch, for example GB-Woodland |
| GB_MISSION | (empty) | Mission name, only used when GB_MAP is also set |
| GB_EXTRA_ARGS | (empty) | Extra flags appended to the launch command |

Wine-related settings (WINEPREFIX, WINEARCH, WINEDEBUG, SteamAppId) are set in compose for the runtime. Leave them alone unless you know you need to change them.

## Data folder

Your data folder mounts at /opt/groundbranch inside the container.

| Path | Purpose |
| --- | --- |
| GroundBranch/ServerConfig/ | Created empty on first start. The game writes and manages its own config and admin files here |
| .wine/ | Wine prefix, created on first start |
| steam_appid.txt | Rewritten every start with GB_STEAM_APP_ID |

The container does not write a config file. Map, mission, player cap, and AI cap are passed as launch arguments. For other settings, edit the files the game creates under ServerConfig/ and restart.

The container fixes file ownership on the data folder automatically, so you do not need to chown the host directory yourself.

## Updates

Set GB_FORCE_UPDATE to true to reinstall on the next start. You can also run ./tools/gs update ground-branch. See [Ops](/guides/ops/).

## Health check

The container reports healthy while the Ground Branch server process is running. Startup gets a 300 second grace period before health checks count against the retry limit.

## Compose

```bash
docker compose -f dockerized/ground-branch/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name ground-branch --restart unless-stopped --init \
  -p 7777:7777/udp -p 27015:27015/udp \
  -v "$PWD/dockerized/ground-branch/data:/opt/groundbranch" \
  -e GB_MAP=GB-Woodland \
  -e GB_MAX_PLAYERS=8 \
  {{IMAGE_PREFIX}}/ground-branch:latest
```
