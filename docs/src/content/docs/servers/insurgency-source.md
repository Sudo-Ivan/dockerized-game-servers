---
title: Insurgency Source
description: Insurgency (2014) Source dedicated server via SteamCMD, App 237410.
---

Compose path: insurgency-source. Image: insurgency-source.

Insurgency (2014, the Source mod turned standalone game) dedicated server built on the shared [steam-base](/reference/images/) image. SteamCMD installs App **237410** (the Linux dedicated server depot) and the entrypoint launches `srcds_run` directly.

:::note[Requirements]
- Publish TCP **27015**, UDP **27015**, and UDP **27016**
- Persist `./data` at `/opt/insurgency-source`
- Anonymous SteamCMD login usually works for App 237410, set `STEAM_USERNAME` and `STEAM_PASSWORD` for an account that owns Insurgency if a plain anonymous install fails, optional `STEAM_GUARD_CODE`
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | TCP | Same game port, doubles as the RCON channel once `rcon_password` is set in `server.cfg` or via `INS_SOURCE_EXTRA_ARGS` |
| 27015 | UDP | Main game port (`INS_SOURCE_PORT`), also passed as `+hostport` |
| 27016 | UDP | Client port (`INS_SOURCE_CLIENT_PORT`), passed as `+clientport` |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | Steam login for the SteamCMD install step |
| `STEAM_PASSWORD` | (empty) | Password for `STEAM_USERNAME`, required for non-anonymous login |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code, only needed if Steam challenges the login |
| `INS_SOURCE_APP_ID` | `237410` | SteamCMD app id for the dedicated server depot |
| `INS_SOURCE_FORCE_UPDATE` | `false` | Set `true` to force `app_update 237410 validate` on next start |
| `STEAMCMD_WINDOWS_WORKAROUND` | `full` | SteamCMD depot fetch mode (`full`, `prime`, or `off`), `full` pulls a Windows depot pass before the Linux depot |
| `INS_SOURCE_PORT` | `27015` | Game port, passed as `+port` and `+hostport` |
| `INS_SOURCE_CLIENT_PORT` | `27016` | Client port, passed as `+clientport` |
| `INS_SOURCE_MAXPLAYERS` | `16` | Player cap, passed as `+maxplayers` |
| `INS_SOURCE_STARTMAP` | `ministry` | Map loaded on startup, passed as `+map` |
| `INS_SOURCE_TICKRATE` | `128` | Server tickrate, passed as `-tickrate` |
| `INS_SOURCE_EXTRA_ARGS` | (empty) | Extra `srcds_run` arguments, space separated, appended after the built-in flags |

The entrypoint always passes `-game insurgency`, `-console`, `-usercon`, and `-strictportbind`.

## Data volume

`./data` mounts to `/opt/insurgency-source`.

| Path | Purpose |
| --- | --- |
| `srcds_run` | Server launcher, installed by SteamCMD |
| `steam_appid.txt` | Rewritten on every start with `222880`, the Steamworks app id Insurgency needs at runtime |
| `insurgency/cfg/server.cfg` | Main server config, create it yourself, the entrypoint does not generate one |
| `insurgency/maps/` | Custom or workshop maps you copy in manually |
| `insurgency/addons/` | SourceMod or Metamod install location if you add server plugins |

## Updates and healthchecks

Set `INS_SOURCE_FORCE_UPDATE=true` or run `./tools/gs update insurgency-source` from the [Ops](../guides/ops/) guide. The healthcheck is a `process` probe (`pgrep -f srcds_linux` falling back to `pgrep -f srcds_run`) with a 600 second start period.

## Notes

- The Dockerfile sets `USER inssource`, so the container runs as that unprivileged user (uid 1000) by default. `docker-entrypoint.sh` only chowns `/opt/insurgency-source` when it is invoked as root, if the host `./data` directory is owned by a different uid and you never run as root, the container may hit permission errors, match host ownership to uid 1000 or override `user: root` once to let it self-heal.
- `entrypoint.sh` strips Windows line endings from `srcds_run` (`sed -i 's/\r$//'`) on every start, not only on install, this is a known artifact of the Insurgency Source depot.
- There is no dedicated RCON environment variable. TCP 27015 is the RCON channel once you set `rcon_password` yourself, and `-usercon` is always passed to open the engine's console socket.
- `-strictportbind` is always passed, so the server exits immediately rather than silently rebinding if `INS_SOURCE_PORT` or `INS_SOURCE_CLIENT_PORT` are already taken.
- First install downloads twice (a Windows depot pass, then the Linux depot) because `STEAMCMD_WINDOWS_WORKAROUND` defaults to `full`.
- Compose sets `mem_limit: 2048M` and `stop_grace_period: 90s`, the image sends `SIGINT` on stop so `srcds` can shut down cleanly.

## Compose

```bash
docker compose -f insurgency-source/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name insurgency-source --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27016:27016/udp \
  -v "$PWD/insurgency-source/data:/opt/insurgency-source" \
  -e STEAM_USERNAME="your_steam_user" \
  -e STEAM_PASSWORD="your_steam_password" \
  {{IMAGE_PREFIX}}/insurgency-source:latest
```
