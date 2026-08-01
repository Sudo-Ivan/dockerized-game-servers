---
title: Longvinter
description: Longvinter dedicated server via SteamCMD
---

Compose path: longvinter. Image: longvinter. Built from the shared [steam-base](/reference/images/) image (Arch Linux with SteamCMD, plus `icu` and `openssl` that the Unreal server binary links against).

Longvinter installs Steam App **1639880** into the data volume on first start, then writes a default `Game.ini` the first time that file is missing.

:::note[Requirements]
- Persist `./data` for the installed server and `Longvinter/Saved/` world data
- Publish UDP **7777** (game port)
- Allocate at least 4 GB RAM
- No Steam account is required, SteamCMD installs App 1639880 anonymously
:::

## How the server is installed

`entrypoint.sh` uses the shared [`bases/steam/steamcmd-app-update.sh`]({{GITHUB_URL}}/blob/master/bases/steam/steamcmd-app-update.sh) helper to run `+app_update 1639880 validate` against the data volume, logging in anonymously unless you set `STEAM_USERNAME`/`STEAM_PASSWORD`. If `LongvinterServer.sh` is missing or `LONGVINTER_FORCE_UPDATE=true`, it reinstalls before starting. A fallback walks `/home/longvinter/Steam/steamapps/common` and relocates any directory containing `LongvinterServer.sh` into the data volume.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7777 | UDP | Game port (`LONGVINTER_PORT`), required for players to join |

Longvinter uses UDP only for gameplay. Do not publish TCP 7777.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `LONGVINTER_PORT` | `7777` | Game port, passed as `-GamePort=` on every start |
| `LONGVINTER_SERVER_NAME` | `Longvinter Server` | `ServerName` in `Game.ini`, first-write only |
| `LONGVINTER_SERVER_MOTD` | `Welcome to Longvinter!` | `ServerMOTD` in `Game.ini`, first-write only |
| `LONGVINTER_MAX_PLAYERS` | `32` | `MaxPlayers` in `Game.ini`, first-write only |
| `LONGVINTER_PASSWORD` | *(empty)* | Join password in `Game.ini`, first-write only |
| `LONGVINTER_COMMUNITY_WEBSITE` | `discord.gg/longvinter` | `CommunityWebsite` in `Game.ini`, first-write only |
| `LONGVINTER_ADMIN_STEAM_ID` | *(empty)* | Space-separated EOS IDs for `AdminSteamID`, first-write only |
| `LONGVINTER_PVP` | `true` | `PVP` in `Game.ini`, first-write only |
| `LONGVINTER_TENT_DECAY` | `true` | `TentDecay` in `Game.ini`, first-write only |
| `LONGVINTER_MAX_TENTS` | `3` | `MaxTents` in `Game.ini`, first-write only |
| `LONGVINTER_RESTART_TIME_24H` | `6` | Scheduled restart hour (`RestartTime24h`), first-write only |
| `LONGVINTER_SAVE_BACKUPS` | `true` | `SaveBackups` in `Game.ini`, first-write only |
| `LONGVINTER_EXTRA_ARGS` | *(empty)* | Extra CLI flags appended after `-GamePort=` |
| `LONGVINTER_FORCE_UPDATE` | `false` | Re-run SteamCMD for App 1639880 on next start |
| `LONGVINTER_APP_ID` | `1639880` | Steam app id to install |
| `STEAM_USERNAME` | `anonymous` | Steam login for the install step |
| `STEAM_PASSWORD` | *(empty)* | Steam password |
| `STEAM_GUARD_CODE` | *(empty)* | Steam Guard code |

See [Quick start](/guides/quick-start/) for the shared Steam login pattern.

`LONGVINTER_PORT` is passed on every launch. The `LONGVINTER_*` settings that map to `Game.ini` only apply when `entrypoint.sh` creates that file on first start. After that, edit `longvinter/data/Longvinter/Saved/Config/LinuxServer/Game.ini` on the host for server name, PvP, admins, and every other Longvinter setting. See the [Longvinter server configuration wiki](https://wiki.longvinter.com/server/configuration) for the full option list.

## Data volume

`./data` mounts to `/opt/longvinter`. It holds the installed `LongvinterServer.sh` launcher and matching binaries, plus everything under `Longvinter/Saved/` (world saves, `Game.ini`, logs) once Longvinter creates it.

## Compose

```bash
docker compose -f longvinter/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name longvinter --restart unless-stopped --init \
  -p 7777:7777/udp \
  -v "$PWD/longvinter/data:/opt/longvinter" \
  {{IMAGE_PREFIX}}/longvinter:latest
```

## Updating

Set `LONGVINTER_FORCE_UPDATE=true` and recreate the container, or run `./tools/gs update longvinter` from [Ops](/guides/ops/). The healthcheck is a `process` probe for `LongvinterServer-Linux-Shipping` (or `Longvinter-Linux-Shipping` on older builds).
