---
title: OpenMoHAA
description: OpenMoHAA dedicated server, requires your own Medal of Honor Allied Assault game assets.
---

Compose path: `openmohaa`. Image: `openmohaa`.

[OpenMoHAA](https://github.com/openmoh/openmohaa) is an open re-implementation of the Medal of Honor: Allied Assault dedicated server. The image bundles the `omohaaded` binary from an upstream release, but not the game's PK3 data. You must own Allied Assault (and any expansions you want to host) and copy the PK3 files into the data volume yourself, the entrypoint refuses to start without them.

:::note[Requirements]
- Persist `./data` for game assets, config, and mods, mounted at `/usr/local/share/mohaa`
- Copy `main/Pak*.pk3` (and `mainta/`, `maintt/` for the expansions) from your owned install before first start
- Publish UDP **12203** (game) and UDP **12300** (GameSpy query)
:::

## Game data (required)

Copy folders from your owned install into `openmohaa/data/`:

```text
openmohaa/data/
  main/     Pak*.pk3 from Allied Assault (required)
  mainta/   pak*.pk3 from Spearhead (optional, only if you host that content)
  maintt/   pak*.pk3 from Breakthrough (optional, only if you host that content)
  home/     per-user overrides, mods, and the generated server config
```

`sound/` and `video/` are not needed for a dedicated server. On every start the entrypoint checks `main/`, `mainta/`, and `maintt/` for `.pk3` files (any case, including `Pak*.pk3` or `pak*.pk3`) and exits with an error explaining the expected layout if none are found anywhere. Custom PK3s can go under `home/main`, `home/mainta`, or `home/maintt`, see the [upstream server container docs](https://github.com/openmoh/openmohaa/tree/main/container/server) and [docs.openmohaa.org](https://docs.openmohaa.org/).

If `home/main/settings/<MOH_SERVER_CFG>` is missing, the entrypoint writes a minimal default (shown here for the default filename `server.cfg`):

```text
set sv_hostname "OpenMoHAA Server"
set sv_maxclients 16
set g_gametype 0
map mohdm1
```

Edit that file for hostname, map rotation, and game rules, the entrypoint only writes it once and never overwrites an existing one.

## Tuning the server (server.cfg cvars)

The generated file only sets three cvars. Everything else is a normal `omohaaded` console variable you add yourself with `set <cvar> <value>`, one per line, or `exec` a second file from inside it. Useful ones beyond the default:

| Cvar | Purpose |
| --- | --- |
| `g_password` | Password required to join, leave empty for a public server |
| `sv_privateclients` / `sv_privatepassword` | Reserve a number of slots behind a separate password for admins or VIPs |
| `rconpassword` | Enables remote console admin commands, unset means rcon is disabled |
| `sv_netoptimize` | `0` disables (default), `1` skips sending data about moving entities a client can't see, `2` always skips it, both reduce bandwidth and make wallhacking harder |
| `net_enabled` | `1` IPv4 only (the dedicated server default), `2` IPv6 only, `3` both |
| `sv_maxRate` / `sv_minRate` | Per-client bandwidth caps |
| `fraglimit` / `timelimit` / `roundlimit` | Match end conditions, game-mode dependent |
| `sv_maplist` | Map rotation list |
| `g_navigation_legacy 1` | Enables bot navigation on stock maps once the `mp-navigation` pk3 is installed |

IP bans persist in `serverbans.dat` (path configurable via `sv_banFile`) and are managed with the in-game `banuser`, `banip`, and `rehashbans` commands. The full, versioned cvar list lives in [OpenMoHAA's own docs](https://docs.openmohaa.org/) and the [server configuration reference](https://github.com/openmoh/openmohaa/blob/main/docs/markdown/03-configuration/02-configuration-server.md), check there for anything not covered above, cvars are added over time as the reimplementation grows.

Changes to `server.cfg` only take effect on restart, `omohaaded` does not hot-reload it.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 12203 | UDP | Game port (`MOH_GAME_PORT`) |
| 12300 | UDP | GameSpy query port (`MOH_GAMESPY_PORT`) |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `OPENMOHAA_VERSION` | `v0.82.1` | Upstream `openmoh/openmohaa` release tag to download |
| `OPENMOHAA_FORCE_UPDATE` | `false` | Force a re-download of `omohaaded` even if the installed version already matches |
| `MOH_GAME_PORT` | `12203` | `+set net_port`, game UDP port |
| `MOH_GAMESPY_PORT` | `12300` | `+set net_gamespy_port`, GameSpy query UDP port |
| `MOH_TARGET_GAME` | `0` | `+set com_target_game`, selects the base game slot (`0` for Allied Assault) |
| `MOH_SERVER_CFG` | `server.cfg` | Config filename under `home/main/settings/`, `+exec`'d on start if present |
| `MOH_EXTRA_ARGS` | (empty) | Extra `+set`/console arguments appended verbatim, space-separated |

Any arguments you append to the container's command (for example a custom `command:` in compose) are appended after `MOH_EXTRA_ARGS`.

## Data volume and file layout

Mount `openmohaa/data` at `/usr/local/share/mohaa`. Unlike the Steam-based servers in this repository, this single volume holds both the game assets you provide and the server's writable state:

| Path | Purpose |
| --- | --- |
| `main/`, `mainta/`, `maintt/` | Your PK3 game assets (required, see above) |
| `home/main/settings/<MOH_SERVER_CFG>` | Server config, auto-created once if missing |
| `home/` | `fs_homepath`, holds save state, logs, and mod overrides written by the server |

## Update

`OPENMOHAA_FORCE_UPDATE=true` forces a re-download of the `omohaaded` binary on the next recreate. See [Ops](/guides/ops/) for `./tools/gs update openmohaa` and backups. This only updates the server binary, your PK3 game assets are yours to manage and are never touched by the entrypoint or by `gs update`.

## Healthcheck

Catalog kind: `process`. In practice `healthcheck.sh` does not check for a process name, it sends a UDP status query to `MOH_GAME_PORT` and checks for the ioquake3-style `disconnect` header in the response, retrying every second until it gets one or the 20 second healthcheck timeout expires. The 60 second start period covers normal startup only, it does not wait out a slow first download.

## Compose

```bash
docker compose -f openmohaa/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name openmohaa --restart unless-stopped --init \
  -p 12203:12203/udp -p 12300:12300/udp \
  -v "$PWD/openmohaa/data:/usr/local/share/mohaa" \
  {{IMAGE_PREFIX}}/openmohaa:latest
```

Populate `openmohaa/data/main` (and expansion folders if needed) before starting the container, otherwise it exits immediately with an error. The shipped compose file caps the container at 2048 MB of memory.
