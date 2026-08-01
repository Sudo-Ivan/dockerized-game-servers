---
title: Garry's Mod
description: Garry's Mod dedicated server via SteamCMD, App 4020.
---

Compose path: gmod. Image: gmod.

Garry's Mod dedicated server built on the shared [steam-base](/reference/images/) image. SteamCMD installs App **4020** and the entrypoint launches `srcds_run` with `-game garrysmod`, VAC (`-secure`) always enabled.

:::note[Requirements]
- Publish TCP **27015**, UDP **27015**, and UDP **27005**
- Persist `./data` at `/opt/gmod`
- Allocate at least 4 GB RAM
- Anonymous SteamCMD login usually works for App 4020, set `STEAM_USERNAME` and `STEAM_PASSWORD` for an account that owns Garry's Mod if a plain anonymous install fails, optional `STEAM_GUARD_CODE`
- Set `GMOD_GSLT` for a public server listing
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | TCP | Same game port, doubles as the RCON channel once `rcon_password` is set in `server.cfg` or via `GMOD_EXTRA_ARGS` |
| 27015 | UDP | Main game port (`GMOD_PORT`), also passed as `+hostport` |
| 27005 | UDP | Client port (`GMOD_CLIENT_PORT`), passed as `+clientport` |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | Steam login for the SteamCMD install step |
| `STEAM_PASSWORD` | (empty) | Password for `STEAM_USERNAME`, required for non-anonymous login |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code, only needed if Steam challenges the login |
| `GMOD_APP_ID` | `4020` | SteamCMD app id for the dedicated server depot |
| `GMOD_FORCE_UPDATE` | `false` | Set `true` to force `app_update 4020 validate` on next start |
| `STEAMCMD_WINDOWS_WORKAROUND` | `full` | SteamCMD depot fetch mode (`full`, `prime`, or `off`), `full` pulls a Windows depot pass before the Linux depot |
| `GMOD_PORT` | `27015` | Game port, passed as `+port` and `+hostport` |
| `GMOD_CLIENT_PORT` | `27005` | Client port, passed as `+clientport` |
| `GMOD_MAXPLAYERS` | `16` | Player cap, passed as `+maxplayers` |
| `GMOD_STARTMAP` | `gm_flatgrass` | Map loaded on startup, passed as `+map` |
| `GMOD_TICKRATE` | `66` | Server tickrate, passed as `-tickrate` |
| `GMOD_GSLT` | (empty) | Game Server Login Token, passed as `+sv_setsteamaccount` when set |
| `GMOD_EXTRA_ARGS` | (empty) | Extra `srcds_run` arguments, space separated, appended after the built-in flags |

The entrypoint always passes `-game garrysmod`, `-console`, `-usercon`, `-secure`, and `-strictportbind`.

## GSLT

1. Sign in at [Steam game server account management](https://steamcommunity.com/dev/managegameservers) and create a token for game id **4000**.
2. Set `GMOD_GSLT` to that token in compose, a `.env` file, or `-e` on `docker run`.

## Data volume

`./data` mounts to `/opt/gmod`.

| Path | Purpose |
| --- | --- |
| `srcds_run` | Server launcher, installed by SteamCMD |
| `steam_appid.txt` | Rewritten on every start with `4000`, the Steamworks app id Garry's Mod needs at runtime |
| `garrysmod/cfg/server.cfg` | Main server config, create it yourself |
| `garrysmod/maps/` | Custom maps |
| `garrysmod/addons/` | Workshop, Lua addons, SourceMod, and Metamod |
| `bin/` | 32-bit engine libraries referenced by `LD_LIBRARY_PATH` at startup |

## Compose

```bash
docker compose -f gmod/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name gmod --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27005:27005/udp \
  -v "$PWD/gmod/data:/opt/gmod" \
  -e GMOD_GSLT="your-gslt" \
  {{IMAGE_PREFIX}}/gmod:latest
```

## Updating

Set `GMOD_FORCE_UPDATE=true` and recreate the container, or run `./tools/gs update gmod` from [Ops](/guides/ops/). The healthcheck is a `process` probe (`pgrep -f srcds_linux`) with a 900 second start period. First install downloads twice because `STEAMCMD_WINDOWS_WORKAROUND` defaults to `full`.
