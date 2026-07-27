---
title: The Forest
description: The Forest dedicated server, a native Linux binary via SteamCMD with no Wine involved.
---

Compose path: `the-forest`. Image: `the-forest`.

Downloads and runs the native Linux dedicated server binary `TheForestDedicatedServer` for Steam App **556450** with SteamCMD. Unlike the other five games on this page, there is no Wine, no Windows binary, and no `steam_appid.txt` shim, the server and the game share this one Linux app id. Anonymous SteamCMD (the default) downloads App 556450. If the install fails, set `STEAM_USERNAME` and `STEAM_PASSWORD` for an account entitled to The Forest.

:::note[Requirements]
- Persist `the-forest/data` at `/opt/theforest`
- Publish TCP and UDP **8766**, **27015**, and **27016**
- `mem_limit` is set to 3072M in compose, the lightest of the six games covered under Servers since there is no Wine overhead
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 8766 (`FOREST_STEAM_PORT`) | TCP and UDP | Steam networking |
| 27015 (`FOREST_GAME_PORT`) | TCP and UDP | Game traffic |
| 27016 (`FOREST_QUERY_PORT`) | TCP and UDP | Server browser query |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | SteamCMD login |
| `STEAM_PASSWORD` | empty | SteamCMD password |
| `STEAM_GUARD_CODE` | empty | Steam Guard code if prompted |
| `FOREST_APP_ID` | `556450` | SteamCMD app id, shared by the server and the game |
| `FOREST_FORCE_UPDATE` | `false` | Set `true` to reinstall on next start |
| `FOREST_IP` | `0.0.0.0` | `-serverip` |
| `FOREST_STEAM_PORT` | `8766` | `-serversteamport` |
| `FOREST_GAME_PORT` | `27015` | `-servergameport` |
| `FOREST_QUERY_PORT` | `27016` | `-serverqueryport` |
| `FOREST_SERVER_NAME` | `The Forest Dedicated Server` | `-servername` |
| `FOREST_MAX_PLAYERS` | `8` | `-serverplayers` |
| `FOREST_PASSWORD` | empty | `-serverpassword`, join password, omitted from the command line when empty |
| `FOREST_ADMIN_PASSWORD` | empty | `-serverpassword_admin`, omitted when empty |
| `FOREST_STEAM_ACCOUNT` | empty | `-serversteamaccount`, Game Server Login Token, omitted when empty |
| `FOREST_DIFFICULTY` | `Normal` | `Peaceful`, `Normal`, or `Hard` |
| `FOREST_INIT_TYPE` | `Continue` | `New` or `Continue`. `Continue` means restarts do not wipe the save |
| `FOREST_SLOT` | `1` | Save slot, 1-5 |
| `FOREST_AUTOSAVE_INTERVAL` | `15` | `-serverautosaveinterval` |
| `FOREST_ENABLE_VAC` | `true` | Adds `-enableVAC` when `true` |
| `FOREST_EXTRA_ARGS` | empty | Extra flags appended to the launch command |

## Data volume

`the-forest/data` mounts at `/opt/theforest`.

| Path | Purpose |
| --- | --- |
| `TheForestDedicatedServer` and game files | Installed by SteamCMD |
| `home/.config/unity3d/SKS/TheForestDedicatedServer/ds/` | Unity persistent data directory, save games and server state the game itself manages |

The entrypoint exports `HOME=/opt/theforest/home` before launch so Unity's per-user config path lands inside the data volume instead of the container's throwaway home directory. No config file is templated by the entrypoint, every setting above is a launch argument. If SteamCMD lays the depot out under a nested `steamapps/common/<name>` folder instead of the volume root, the entrypoint detects it and moves the files up into `/opt/theforest` on first start.

The container starts as root, chowns `/opt/theforest` to the `theforest` user, then drops privileges before launching the game, so no manual chown of the host directory is needed.

## Updates

Set `FOREST_FORCE_UPDATE=true` to reinstall on the next start, or run `./tools/gs update the-forest` from the [Ops](../guides/ops/) guide.

## Healthcheck

Process check (`pgrep -f TheForestDedicatedServer`), 300 second start period.

## Compose

```bash
docker compose -f the-forest/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name the-forest --restart unless-stopped --init \
  -p 8766:8766/tcp -p 8766:8766/udp \
  -p 27015:27015/tcp -p 27015:27015/udp \
  -p 27016:27016/tcp -p 27016:27016/udp \
  -v "$PWD/the-forest/data:/opt/theforest" \
  -e FOREST_SERVER_NAME="My Forest Server" \
  {{IMAGE_PREFIX}}/the-forest:latest
```
