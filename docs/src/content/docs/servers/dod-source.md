---
title: Day of Defeat Source
description: Day of Defeat Source dedicated server via SteamCMD, App 232290.
---

Compose path: dod-source. Image: dod-source.

Day of Defeat: Source dedicated server built on the shared [steam-base](/reference/images/) image. SteamCMD installs App **232290** and the entrypoint launches `srcds_run` with `-game dod`, VAC (`-secure`) always enabled.

:::note[Requirements]
- Publish TCP **27015**, UDP **27015**, and UDP **27005**
- Persist `./data` at `/opt/dod-source`
- Anonymous SteamCMD login usually works for App 232290, set `STEAM_USERNAME` and `STEAM_PASSWORD` for an account that owns Day of Defeat: Source if a plain anonymous install fails, optional `STEAM_GUARD_CODE`
- Set `DOD_GSLT` for a public server listing
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | TCP | Same game port, doubles as the RCON channel once `rcon_password` is set in `server.cfg` or via `DOD_EXTRA_ARGS` |
| 27015 | UDP | Main game port (`DOD_PORT`), also passed as `+hostport` |
| 27005 | UDP | Client port (`DOD_CLIENT_PORT`), passed as `+clientport` |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | Steam login for the SteamCMD install step |
| `STEAM_PASSWORD` | (empty) | Password for `STEAM_USERNAME`, required for non-anonymous login |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code, only needed if Steam challenges the login |
| `DOD_APP_ID` | `232290` | SteamCMD app id for the dedicated server depot |
| `DOD_FORCE_UPDATE` | `false` | Set `true` to force `app_update 232290 validate` on next start |
| `STEAMCMD_WINDOWS_WORKAROUND` | `full` | SteamCMD depot fetch mode (`full`, `prime`, or `off`), `full` pulls a Windows depot pass before the Linux depot |
| `DOD_PORT` | `27015` | Game port, passed as `+port` and `+hostport` |
| `DOD_CLIENT_PORT` | `27005` | Client port, passed as `+clientport` |
| `DOD_MAXPLAYERS` | `16` | Player cap, passed as `+maxplayers` |
| `DOD_STARTMAP` | `dod_anzio` | Map loaded on startup, passed as `+map` |
| `DOD_TICKRATE` | `66` | Server tickrate, passed as `-tickrate` |
| `DOD_GSLT` | (empty) | Game Server Login Token, passed as `+sv_setsteamaccount` when set |
| `DOD_EXTRA_ARGS` | (empty) | Extra `srcds_run` arguments, space separated, appended after the built-in flags |

The entrypoint always passes `-game dod`, `-console`, `-usercon`, `-secure`, and `-strictportbind`.

## GSLT

1. Sign in at [Steam game server account management](https://steamcommunity.com/dev/managegameservers) and create a token for game id **300**.
2. Set `DOD_GSLT` to that token in compose, a `.env` file, or `-e` on `docker run`.

## Data volume

`./data` mounts to `/opt/dod-source`.

| Path | Purpose |
| --- | --- |
| `srcds_run` | Server launcher, installed by SteamCMD |
| `steam_appid.txt` | Rewritten on every start with `300`, the Steamworks app id DoD:S needs at runtime |
| `dod/cfg/server.cfg` | Main server config, create it yourself |
| `dod/maps/` | Custom or workshop maps |
| `dod/addons/` | SourceMod or Metamod install location |
| `bin/` | 32-bit engine libraries referenced by `LD_LIBRARY_PATH` at startup |

## Compose

```bash
docker compose -f dod-source/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name dod-source --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27005:27005/udp \
  -v "$PWD/dod-source/data:/opt/dod-source" \
  -e DOD_GSLT="your-gslt" \
  {{IMAGE_PREFIX}}/dod-source:latest
```

## Updating

Set `DOD_FORCE_UPDATE=true` and recreate the container, or run `./tools/gs update dod-source` from [Ops](/guides/ops/). The healthcheck is a `process` probe (`pgrep -f srcds_linux`) with a 900 second start period. First install downloads twice because `STEAMCMD_WINDOWS_WORKAROUND` defaults to `full`.
