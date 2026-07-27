---
title: 7 Days to Die
description: 7 Days to Die dedicated server via SteamCMD
---

Compose path: 7-days-to-die. Image: 7-days-to-die. Built from the shared [steam-base](/reference/images/) image (Arch Linux with SteamCMD, plus `libpulse` and `alsa-lib` that the game binary links against even though it runs headless).

7 Days to Die installs the Linux dedicated server, Steam App **294420**, into the data volume on first start, then writes a default config the first time it is missing.

:::note[Requirements]
- Persist `./data` for the installed server, world, and config
- Publish TCP/UDP **26900** and UDP **26901** through **26903**
- Allocate at least 6 GB RAM
- No Steam account is required, SteamCMD installs App 294420 anonymously
:::

## How the server is installed

`entrypoint.sh` uses the shared [`bases/steam/steamcmd-app-update.sh`]({{GITHUB_URL}}/blob/master/bases/steam/steamcmd-app-update.sh) helper to run `+app_update 294420 validate` against the data volume, logging in anonymously unless you set `STEAM_USERNAME`/`STEAM_PASSWORD`. If the binary is missing or `SEVENDTD_FORCE_UPDATE=true`, it reinstalls before starting. A fallback walks `/home/sevendtd/Steam/steamapps/common` and relocates any directory containing `7DaysToDieServer.x86_64` into the data volume.

Before every start, the entrypoint also writes `steam_appid.txt` with `251570`, the game's **client** Steam app id, which the server binary needs present on disk to satisfy its Steamworks linkage even though the container installed dedicated server App 294420.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 26900 | TCP | Main game port (`ServerPort` in `serverconfig.xml`) |
| 26900 | UDP | Main game port (`ServerPort` in `serverconfig.xml`) |
| 26901-26903 | UDP | Additional game data channels used by the engine |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `CONFIG_FILE` | `serverconfig.xml` | Config file name or path. Relative names resolve under `/opt/7dtd`, absolute paths are used as-is |
| `SEVENDTD_EXTRA_ARGS` | *(empty)* | Extra CLI flags appended after `-configfile=...` |
| `SEVENDTD_FORCE_UPDATE` | `false` | Re-run SteamCMD for App 294420 on next start |
| `SEVENDTD_APP_ID` | `294420` | Steam app id to install |
| `STEAM_USERNAME` | `anonymous` | Steam login for the install step |
| `STEAM_PASSWORD` | *(empty)* | Steam password |
| `STEAM_GUARD_CODE` | *(empty)* | Steam Guard code |

See [Quick start](/guides/quick-start/) for the shared Steam login pattern.

## First-start config

`entrypoint.sh` only writes the file at `CONFIG_FILE` when it does not already exist, with this default XML:

| Setting | Default value |
| --- | --- |
| `ServerName` | `7 Days to Die Server` |
| `ServerPort` | `26900` |
| `ServerVisibility` | `2` |
| `ServerPassword` | empty |
| `ServerMaxPlayerCount` | `8` |
| `GameWorld` | `Navezgane` |
| `GameName` | `Dedicated` |
| `GameDifficulty` | `2` |
| `ServerDisabledNetworkProtocols` | `SteamNetworking` |

None of these settings are exposed as separate environment variables. Edit `7-days-to-die/data/serverconfig.xml` (or whatever `CONFIG_FILE` points to) directly on the host, then restart the container. `CONFIG_FILE` is mainly useful for keeping more than one hand-edited config in the same data volume under different names.

If `startserver.sh` exists in the install (some server builds ship one), the entrypoint execs that instead of `7DaysToDieServer.x86_64` directly, passing the same `-configfile=` and `SEVENDTD_EXTRA_ARGS`.

## Data volume

`./data` mounts to `/opt/7dtd`. It holds the installed `7DaysToDieServer.x86_64` binary, `serverconfig.xml`, `steam_appid.txt`, and the world saves and logs 7 Days to Die creates under its own directory layout.

## Compose

```bash
docker compose -f 7-days-to-die/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name 7-days-to-die --restart unless-stopped --init \
  -p 26900:26900/tcp -p 26900:26900/udp \
  -p 26901-26903:26901-26903/udp \
  -v "$PWD/7-days-to-die/data:/opt/7dtd" \
  {{IMAGE_PREFIX}}/7-days-to-die:latest
```

## Updating

Set `SEVENDTD_FORCE_UPDATE=true` and recreate the container, or run `./tools/gs update 7-days-to-die` from [Ops](/guides/ops/). The healthcheck is a `process` probe for `7DaysToDieServer`.
