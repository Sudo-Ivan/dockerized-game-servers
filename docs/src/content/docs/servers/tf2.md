---
title: Team Fortress 2
description: Team Fortress 2 dedicated server via SteamCMD, App 232250.
---

Compose path: tf2. Image: tf2.

Team Fortress 2 dedicated server built on the shared [steam-base](/reference/images/) image. SteamCMD installs App **232250** and the entrypoint launches `srcds_run` with `-game tf`, VAC (`-secure`) always enabled.

:::note[Requirements]
- Publish TCP **27015**, UDP **27015**, and UDP **27005**
- Persist `./data` at `/opt/tf2`
- Allocate at least 4 GB RAM
- Anonymous SteamCMD login usually works for App 232250, set `STEAM_USERNAME` and `STEAM_PASSWORD` for an account that owns Team Fortress 2 if a plain anonymous install fails, optional `STEAM_GUARD_CODE`
- Set `TF2_GSLT` for a public server listing
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | TCP | Same game port, doubles as the RCON channel once `rcon_password` is set in `server.cfg` or via `TF2_EXTRA_ARGS` |
| 27015 | UDP | Main game port (`TF2_PORT`), also passed as `+hostport` |
| 27005 | UDP | Client port (`TF2_CLIENT_PORT`), passed as `+clientport` |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | Steam login for the SteamCMD install step |
| `STEAM_PASSWORD` | (empty) | Password for `STEAM_USERNAME`, required for non-anonymous login |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code, only needed if Steam challenges the login |
| `TF2_APP_ID` | `232250` | SteamCMD app id for the dedicated server depot |
| `TF2_FORCE_UPDATE` | `false` | Set `true` to force `app_update 232250 validate` on next start |
| `STEAMCMD_WINDOWS_WORKAROUND` | `full` | SteamCMD depot fetch mode (`full`, `prime`, or `off`), `full` pulls a Windows depot pass before the Linux depot |
| `TF2_PORT` | `27015` | Game port, passed as `+port` and `+hostport` |
| `TF2_CLIENT_PORT` | `27005` | Client port, passed as `+clientport` |
| `TF2_MAXPLAYERS` | `24` | Player cap, passed as `+maxplayers` |
| `TF2_STARTMAP` | `cp_dustbowl` | Map loaded on startup, passed as `+map` |
| `TF2_TICKRATE` | `66` | Server tickrate, passed as `-tickrate` |
| `TF2_GSLT` | (empty) | Game Server Login Token, passed as `+sv_setsteamaccount` when set |
| `TF2_EXTRA_ARGS` | (empty) | Extra `srcds_run` arguments, space separated, appended after the built-in flags |

The entrypoint always passes `-game tf`, `-console`, `-usercon`, `-secure`, and `-strictportbind`.

## GSLT

1. Sign in at [Steam game server account management](https://steamcommunity.com/dev/managegameservers) and create a token for game id **440**.
2. Set `TF2_GSLT` to that token in compose, a `.env` file, or `-e` on `docker run`.

## Data volume

`./data` mounts to `/opt/tf2`.

| Path | Purpose |
| --- | --- |
| `srcds_run` | Server launcher, installed by SteamCMD |
| `steam_appid.txt` | Rewritten on every start with `440`, the Steamworks app id TF2 needs at runtime |
| `tf/cfg/server.cfg` | Main server config, create it yourself |
| `tf/maps/` | Custom or workshop maps |
| `tf/addons/` | SourceMod or Metamod install location |
| `bin/` | 32-bit engine libraries referenced by `LD_LIBRARY_PATH` at startup |

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

## Updating

Set `TF2_FORCE_UPDATE=true` and recreate the container, or run `./tools/gs update tf2` from [Ops](/guides/ops/). The healthcheck is a `process` probe (`pgrep -f srcds_linux`) with a 900 second start period. First install downloads twice because `STEAMCMD_WINDOWS_WORKAROUND` defaults to `full`.
