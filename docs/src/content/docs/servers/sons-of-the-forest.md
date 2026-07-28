---
title: Sons Of The Forest
description: Sons Of The Forest dedicated server (Windows binary via Wine).
---

Compose path: `sons-of-the-forest`. Image: `sons-of-the-forest`.

Downloads the dedicated server tool (Steam App **2465200**) with SteamCMD and runs `SonsOfTheForestDS.exe` under Wine. Sons Of The Forest itself is Steam App **1326470**, written to `steam_appid.txt`. Anonymous SteamCMD is the default, but on current testing it fails with a fatal `SteamCMD needs to be online to update` error while fetching the depot, the tool is not entitled to anonymous accounts. Set `STEAM_USERNAME` and `STEAM_PASSWORD` for an account that owns Sons Of The Forest.

:::note[Requirements]
- Persist `sons-of-the-forest/data` at `/opt/sotf`
- Publish UDP **8766** (game), UDP **27016** (query), and UDP **9700** (BlobSync)
- First start downloads through SteamCMD and initializes a Wine prefix, `start_period` in the healthcheck is 900 seconds for this reason
- `mem_limit` is set to 6144M in compose, allocate at least that much RAM
- Runs as the non-root `sotf` user (UID 1000) by default, see Permissions below
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 8766 (`SOTF_GAME_PORT`) | UDP | Game traffic |
| 27016 (`SOTF_QUERY_PORT`) | UDP | Server browser query |
| 9700 (`SOTF_BLOB_SYNC_PORT`) | UDP | BlobSync, large data transfer between clients and the server |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | SteamCMD login |
| `STEAM_PASSWORD` | empty | SteamCMD password |
| `STEAM_GUARD_CODE` | empty | Steam Guard code if prompted |
| `SOTF_APP_ID` | `2465200` | Dedicated server tool SteamCMD app id |
| `SOTF_STEAM_APP_ID` | `1326470` | Sons Of The Forest's own Steam app id, written to `steam_appid.txt` |
| `SOTF_FORCE_UPDATE` | `false` | Set `true` to reinstall on next start |
| `SOTF_IP` | `0.0.0.0` | `IpAddress` in `dedicatedserver.cfg` |
| `SOTF_GAME_PORT` | `8766` | Game UDP port |
| `SOTF_QUERY_PORT` | `27016` | Query UDP port |
| `SOTF_BLOB_SYNC_PORT` | `9700` | BlobSync UDP port |
| `SOTF_SERVER_NAME` | `Sons Of The Forest Server (dedicated)` | Name shown in the server list |
| `SOTF_MAX_PLAYERS` | `8` | Player cap, 1-8 |
| `SOTF_PASSWORD` | empty | Join password, empty for open |
| `SOTF_LAN_ONLY` | `false` | Set `true` to hide from the public list |
| `SOTF_SAVE_SLOT` | `1` | Save slot number |
| `SOTF_SAVE_MODE` | `Continue` | `New` or `Continue`, `Continue` creates the slot if it does not exist |
| `SOTF_GAME_MODE` | `Normal` | `Normal`, `Hard`, `Hardsurvival`, `Peaceful`, or `Custom` |
| `SOTF_SAVE_INTERVAL` | `600` | Autosave interval in seconds |
| `SOTF_EXTRA_ARGS` | empty | Extra flags appended to the launch command |

## Data volume

`sons-of-the-forest/data` mounts at `/opt/sotf`.

| Path | Purpose |
| --- | --- |
| `userdata/dedicatedserver.cfg` | JSON config, written once from the environment variables above then left alone. Edit it directly for settings not exposed as env vars, such as `GameSettings` or `CustomGameModeSettings` |
| `userdata/ownerswhitelist.txt` | Created empty once, add one Steam64 ID per line to grant in-game admin |
| `.wine/` | Wine prefix (`WINEPREFIX`), created on first start |
| `steam_appid.txt` | Rewritten every start with `SOTF_STEAM_APP_ID` |

If SteamCMD lays the depot out under a nested `steamapps/common/<name>` folder instead of the volume root, the entrypoint detects it and moves the files up into `/opt/sotf` on first start.

## Permissions

The image runs as the non-root `sotf` user (UID 1000) by default. The container only chowns `/opt/sotf` when actually started as root (for example with `user: root`), so if the host `sons-of-the-forest/data` directory is owned by a different UID, `chown` it to `1000:1000` yourself before first start.

## Updates

Set `SOTF_FORCE_UPDATE=true` to reinstall on the next start, or run `./tools/gs update sons-of-the-forest` from the [Ops](../guides/ops/) guide.

## Healthcheck

Process check (`pgrep -f SonsOfTheForestDS`), 900 second start period.

## Compose

```bash
docker compose -f sons-of-the-forest/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name sons-of-the-forest --restart unless-stopped --init \
  -p 8766:8766/udp -p 27016:27016/udp -p 9700:9700/udp \
  -v "$PWD/sons-of-the-forest/data:/opt/sotf" \
  -e SOTF_SERVER_NAME="My SOTF Server" \
  {{IMAGE_PREFIX}}/sons-of-the-forest:latest
```
