---
title: Counter-Strike 2
description: Counter-Strike 2 dedicated server via SteamCMD, App 730.
---

Compose path: cs2. Image: cs2.

Counter-Strike 2 dedicated server built on the shared [steam-base](/reference/images/) image. SteamCMD installs App **730** into the data volume on first start, then launches `game/bin/linuxsteamrt64/cs2` in dedicated mode. Expect roughly **60 GB** of disk space for a full install.

:::note[Requirements]
- Publish TCP **27015**, UDP **27015**, and UDP **27020**
- Persist `./data` at `/opt/cs2`
- Allocate at least 8 GB RAM
- Anonymous SteamCMD login usually works for App 730, set `STEAM_USERNAME` and `STEAM_PASSWORD` if install fails, optional `STEAM_GUARD_CODE`
- Set `CS2_GSLT` for a public server listing
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | TCP | Game port and RCON channel (`CS2_PORT`) |
| 27015 | UDP | Main game port (`CS2_PORT`) |
| 27020 | UDP | Steam server query port used by the CS2 dedicated server |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | Steam login for the SteamCMD install step |
| `STEAM_PASSWORD` | (empty) | Password for `STEAM_USERNAME`, required for non-anonymous login |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code, only needed if Steam challenges the login |
| `CS2_APP_ID` | `730` | SteamCMD app id for the dedicated server depot |
| `CS2_FORCE_UPDATE` | `false` | Set `true` to force `app_update 730 validate` on next start |
| `CS2_PORT` | `27015` | Game port, passed as `-port` |
| `CS2_MAXPLAYERS` | `10` | Player cap, passed as `+maxplayers` |
| `CS2_STARTMAP` | `de_dust2` | Map loaded on startup, passed as `+map` |
| `CS2_GAME_TYPE` | `0` | Game type, passed as `+game_type` |
| `CS2_GAME_MODE` | `1` | Game mode, passed as `+game_mode` |
| `CS2_GSLT` | (empty) | Game Server Login Token, passed as `+sv_setsteamaccount` when set |
| `CS2_EXTRA_ARGS` | (empty) | Extra arguments appended after the built-in flags |

The entrypoint always passes `-dedicated`, `-ip 0.0.0.0`, and `+sv_lan 0`.

## GSLT

1. Sign in at [Steam game server account management](https://steamcommunity.com/dev/managegameservers) and create a token for game id **730**.
2. Set `CS2_GSLT` to that token in compose, a `.env` file, or `-e` on `docker run`.

## Data volume

`./data` mounts to `/opt/cs2`.

| Path | Purpose |
| --- | --- |
| `game/bin/linuxsteamrt64/cs2` | Dedicated server binary, installed by SteamCMD |
| `game/csgo/cfg/` | Server config files |
| `game/csgo/maps/` | Maps and workshop content |

## Compose

```bash
docker compose -f cs2/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cs2 --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27020:27020/udp \
  -v "$PWD/cs2/data:/opt/cs2" \
  -e CS2_GSLT="your-gslt" \
  {{IMAGE_PREFIX}}/cs2:latest
```

## Updating

Set `CS2_FORCE_UPDATE=true` and recreate the container, or run `./tools/gs update cs2` from [Ops](/guides/ops/). The healthcheck is a `process` probe (`pgrep -f game/bin/linuxsteamrt64/cs2`) with an **1800** second start period to allow for the large first install.
