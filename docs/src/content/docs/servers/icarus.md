---
title: Icarus
description: Icarus dedicated server (Windows binary via Wine).
---

Compose path: `icarus`. Image: `icarus`.

Downloads the dedicated server tool (Steam App **2089300**) with SteamCMD and runs `IcarusServer-Win64-Shipping.exe` under Wine. Icarus itself is Steam App **1149460**, written to `steam_appid.txt`. Anonymous SteamCMD (the default) downloads App 2089300. If the install fails, set `STEAM_USERNAME` and `STEAM_PASSWORD` for an account entitled to Icarus.

:::note[Requirements]
- Persist `icarus/data` at `/opt/icarus`
- Publish UDP **17777** (game) and UDP **27015** (query)
- First start downloads through SteamCMD and initializes a Wine prefix, `start_period` in the healthcheck is 1200 seconds (20 minutes) for this reason
- `mem_limit` is set to 8192M in compose, allocate at least that much RAM
- Starts as root and self-heals `icarus/data` ownership on every start, see Permissions below
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 17777 (`ICARUS_PORT`) | UDP | Game traffic |
| 27015 (`ICARUS_QUERY_PORT`) | UDP | Server browser query |

Only one service on the host should bind UDP 27015 unless you change `ICARUS_QUERY_PORT` and the published port mapping.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | SteamCMD login |
| `STEAM_PASSWORD` | empty | SteamCMD password |
| `STEAM_GUARD_CODE` | empty | Steam Guard code if prompted |
| `ICARUS_APP_ID` | `2089300` | Dedicated server tool SteamCMD app id |
| `ICARUS_STEAM_APP_ID` | `1149460` | Icarus's own Steam app id, written to `steam_appid.txt`. Not set in compose, override with `-e` if you need to change it |
| `ICARUS_FORCE_UPDATE` | `false` | Set `true` to reinstall on next start |
| `ICARUS_PORT` | `17777` | Game UDP port |
| `ICARUS_QUERY_PORT` | `27015` | Query UDP port |
| `ICARUS_GAME_MODE` | `Prospect` | Passed through as `-GameMode=`, not validated by the entrypoint |
| `ICARUS_SESSION_NAME` | `Icarus Server` | Session name shown to players, also used as `-SteamServerName=` |
| `ICARUS_MAX_PLAYERS` | `8` | Player cap |
| `ICARUS_ADMIN_PASSWORD` | empty | Adds `-AdminPassword=` when set |
| `ICARUS_EXTRA_ARGS` | empty | Extra flags appended to the launch command |

## Data volume

`icarus/data` mounts at `/opt/icarus`.

| Path | Purpose |
| --- | --- |
| `.wine/` | Wine prefix (`WINEPREFIX`), created on first start |
| `steam_appid.txt` | Rewritten every start with `ICARUS_STEAM_APP_ID` |
| game install tree | Wherever SteamCMD placed `IcarusServer-Win64-Shipping.exe`, located by search rather than a fixed path |

The entrypoint does not write a session or server config file, every setting above is a launch argument. If SteamCMD lays the depot out under a nested `steamapps/common/<name>` folder instead of the volume root, the entrypoint detects it and moves the files up into `/opt/icarus` on first start.

## Permissions

The container starts as root, `docker-entrypoint.sh` creates `/opt/icarus`, chowns it to `icarus` (UID 1000), then drops privileges via `runuser` before running `entrypoint.sh`, so a fresh or root-owned host `icarus/data` directory is fixed up automatically on every start.

## Updates

Set `ICARUS_FORCE_UPDATE=true` to reinstall on the next start, or run `./tools/gs update icarus` from the [Ops](../guides/ops/) guide.

## Healthcheck

Process check (`pgrep -f IcarusServer-Win64-Shipping.exe`), 1200 second start period.

## Compose

```bash
docker compose -f icarus/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name icarus --restart unless-stopped --init \
  -p 17777:17777/udp -p 27015:27015/udp \
  -v "$PWD/icarus/data:/opt/icarus" \
  -e ICARUS_SESSION_NAME="My Prospect" \
  -e ICARUS_GAME_MODE=Prospect \
  {{IMAGE_PREFIX}}/icarus:latest
```
