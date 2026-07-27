---
title: Ground Branch
description: Ground Branch dedicated server (Windows binary via Wine).
---

Compose path: `ground-branch`. Image: `ground-branch`.

Downloads the dedicated server tool (Steam App **476400**) with SteamCMD and runs `GroundBranchServer-Win64-Shipping.exe` under Wine. Ground Branch itself is Steam App **16900**, written to `steam_appid.txt` on every start so the Steamworks shim inside Wine reports the right game. Anonymous SteamCMD (the default) downloads App 476400. If the install fails, set `STEAM_USERNAME` and `STEAM_PASSWORD` for an account entitled to Ground Branch.

:::note[Requirements]
- Persist `ground-branch/data` at `/opt/groundbranch`
- Publish UDP **7777** (game) and UDP **27015** (query)
- First start downloads the server through SteamCMD and initializes a Wine prefix, which takes noticeably longer than later restarts
- `mem_limit` is set to 4096M in compose, raise it if the server struggles under load
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7777 (`GB_PORT`) | UDP | Game traffic |
| 27015 (`GB_QUERY_PORT`) | UDP | Server browser query |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | SteamCMD login |
| `STEAM_PASSWORD` | empty | SteamCMD password, required with a real username |
| `STEAM_GUARD_CODE` | empty | Steam Guard code if prompted |
| `GB_APP_ID` | `476400` | Dedicated server tool SteamCMD app id |
| `GB_STEAM_APP_ID` | `16900` | Ground Branch's own Steam app id, written to `steam_appid.txt` |
| `GB_FORCE_UPDATE` | `false` | Set `true` to reinstall on next start |
| `GB_PORT` | `7777` | Game UDP port |
| `GB_QUERY_PORT` | `27015` | Query UDP port |
| `GB_MULTIHOME` | `0.0.0.0` | Bind address, passed as `MultiHome=` |
| `GB_MAX_PLAYERS` | `8` | Player cap, passed as `MaxPlayers=` |
| `GB_MAX_AI` | `30` | AI bot cap, passed as `MaxAI=` |
| `GB_MAP` | empty | Map to load on launch, for example `GB-Woodland` |
| `GB_MISSION` | empty | Mission name, only applied when `GB_MAP` is also set |
| `GB_EXTRA_ARGS` | empty | Extra flags appended to the launch command |

`WINEPREFIX`, `WINEARCH`, `WINEDEBUG`, and `SteamAppId` are also set in compose for Wine runtime plumbing. Leave them alone unless you know you need to change them.

## Data volume

`ground-branch/data` mounts at `/opt/groundbranch`.

| Path | Purpose |
| --- | --- |
| `GroundBranch/ServerConfig/` | Created empty on first start, the game process populates and manages its own config and admin files here afterward |
| `.wine/` | Wine prefix (`WINEPREFIX`), created on first start with `wineboot --init` |
| `steam_appid.txt` | Rewritten every start with `GB_STEAM_APP_ID` |

The entrypoint does not template any config file. `GB_MAP`, `GB_MISSION`, `GB_MAX_PLAYERS`, and `GB_MAX_AI` are all passed as launch arguments instead of being written to disk. For settings not covered by an env var, edit the files the game writes under `ServerConfig/` and restart.

The container starts as root, chowns `/opt/groundbranch` to the `groundbranch` user, then drops privileges before launching the game, so no manual chown of the host directory is needed.

## Updates

Set `GB_FORCE_UPDATE=true` to reinstall on the next start, or run `./tools/gs update ground-branch` from the [Ops](../guides/ops/) guide.

## Healthcheck

Process check (`pgrep -f GroundBranchServer`), 300 second start period before the first probe counts against the retry limit.

## Compose

```bash
docker compose -f ground-branch/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name ground-branch --restart unless-stopped --init \
  -p 7777:7777/udp -p 27015:27015/udp \
  -v "$PWD/ground-branch/data:/opt/groundbranch" \
  -e GB_MAP=GB-Woodland \
  -e GB_MAX_PLAYERS=8 \
  {{IMAGE_PREFIX}}/ground-branch:latest
```
