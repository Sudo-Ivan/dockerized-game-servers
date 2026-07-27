---
title: Starbound
description: Starbound dedicated server via SteamCMD
---

Compose path: starbound. Image: starbound. Built from the shared [steam-base](/reference/images/) image (Arch Linux with SteamCMD).

Starbound installs Steam App **211820** into the data volume on first start, then writes a default `starbound_server.config` the first time that file is missing.

:::note[Requirements]
- Persist `./data` for the installed server, universe, and player data
- Publish TCP **21025**
- No Steam account is required, SteamCMD installs App 211820 anonymously
:::

## How the server is installed

`entrypoint.sh` uses the shared [`bases/steam/steamcmd-app-update.sh`]({{GITHUB_URL}}/blob/master/bases/steam/steamcmd-app-update.sh) helper to run `+app_update 211820 validate` against the data volume, logging in anonymously unless you set `STEAM_USERNAME`/`STEAM_PASSWORD`. If the binary is missing or `STARBOUND_FORCE_UPDATE=true`, it reinstalls before starting. A fallback walks `/home/starbound/Steam/steamapps/common` and relocates any directory containing `linux/starbound_server` into the data volume.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 21025 | TCP | Game port (`STARBOUND_PORT`), also used as `steamPort` in the generated config |

`rconPort` **21026** is written into the generated config bound to `127.0.0.1` only, and it is not published by compose. Map it yourself and change `rconBindAddress` in `starbound_server.config` if you want remote RCON.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STARBOUND_PORT` | `21025` | Game port, only takes effect while writing the config the first time |
| `STARBOUND_BIND` | `0.0.0.0` | Bind address for `gameServerBindAddress` and `steamBindAddress`, first-write only |
| `STARBOUND_EXTRA_ARGS` | *(empty)* | Extra CLI flags appended to `starbound_server -configfile ...` |
| `STARBOUND_FORCE_UPDATE` | `false` | Re-run SteamCMD for App 211820 on next start |
| `STARBOUND_APP_ID` | `211820` | Steam app id to install |
| `STEAM_USERNAME` | `anonymous` | Steam login for the install step |
| `STEAM_PASSWORD` | *(empty)* | Steam password |
| `STEAM_GUARD_CODE` | *(empty)* | Steam Guard code |

See [Quick start](/guides/quick-start/) for the shared Steam login pattern.

## First-start config

`entrypoint.sh` only writes `starbound_server.config` when the file does not already exist, using this template:

| Setting | Default value |
| --- | --- |
| `gameServerPort` / `steamPort` | `STARBOUND_PORT` (`21025`) |
| `gameServerBindAddress` / `steamBindAddress` | `STARBOUND_BIND` (`0.0.0.0`) |
| `gameServerPassword` | empty |
| `maxPlayers` | `8` |
| `rconPort` / `rconBindAddress` | `21026` / `127.0.0.1` |
| `rconPassword` | empty |
| `allowAdminCommands` | `false` |
| `allowAnonymousConnections` | `true` |
| `serverName` / `serverDescription` | `Starbound Server` / `Starbound dedicated server` |

`STARBOUND_PORT` and `STARBOUND_BIND` only affect this first write. After that, edit `starbound/data/starbound_server.config` on the host directly for server name, password, RCON, admin list, and every other Starbound setting. The running server also rewrites this file itself as it operates.

## Data volume

`./data` mounts to `/opt/starbound`. It holds the installed `linux/starbound_server` binary, `starbound_server.config`, and everything under `storage/` (universe, player, and world data) once Starbound creates it.

## Compose

```bash
docker compose -f starbound/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name starbound --restart unless-stopped --init \
  -p 21025:21025/tcp \
  -v "$PWD/starbound/data:/opt/starbound" \
  {{IMAGE_PREFIX}}/starbound:latest
```

## Updating

Set `STARBOUND_FORCE_UPDATE=true` and recreate the container, or run `./tools/gs update starbound` from [Ops](/guides/ops/). The healthcheck is a `process` probe for `starbound_server`.
