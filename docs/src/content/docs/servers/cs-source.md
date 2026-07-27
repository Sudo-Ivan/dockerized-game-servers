---
title: Counter-Strike Source
description: Counter-Strike Source dedicated server via SteamCMD, App 232330.
---

Compose path: cs-source. Image: cs-source.

Counter-Strike: Source dedicated server built on the shared [steam-base](/reference/images/) image. SteamCMD installs App **232330** (the Linux dedicated server depot) and the entrypoint launches `srcds_run` directly with VAC (`-secure`) always enabled.

:::note[Requirements]
- Publish TCP **27015**, UDP **27015**, and UDP **27005**
- Persist `./data` at `/opt/cs-source`
- Anonymous SteamCMD login usually works for App 232330, set `STEAM_USERNAME` and `STEAM_PASSWORD` for an account that owns Counter-Strike: Source if a plain anonymous install fails, optional `STEAM_GUARD_CODE`
- Set `CSS_GSLT` for a public server listing
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | TCP | Same game port, doubles as the RCON channel once `rcon_password` is set in `server.cfg` or via `CSS_EXTRA_ARGS` |
| 27015 | UDP | Main game port (`CSS_PORT`), also passed as `+hostport` |
| 27005 | UDP | Client port (`CSS_CLIENT_PORT`), passed as `+clientport` |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | Steam login for the SteamCMD install step |
| `STEAM_PASSWORD` | (empty) | Password for `STEAM_USERNAME`, required for non-anonymous login |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code, only needed if Steam challenges the login |
| `CSS_APP_ID` | `232330` | SteamCMD app id for the dedicated server depot |
| `CSS_FORCE_UPDATE` | `false` | Set `true` to force `app_update 232330 validate` on next start |
| `STEAMCMD_WINDOWS_WORKAROUND` | `full` | SteamCMD depot fetch mode (`full`, `prime`, or `off`), `full` pulls a Windows depot pass before the Linux depot |
| `CSS_PORT` | `27015` | Game port, passed as `+port` and `+hostport` |
| `CSS_CLIENT_PORT` | `27005` | Client port, passed as `+clientport` |
| `CSS_MAXPLAYERS` | `16` | Player cap, passed as `+maxplayers` |
| `CSS_STARTMAP` | `de_dust2` | Map loaded on startup, passed as `+map` |
| `CSS_TICKRATE` | `66` | Server tickrate, passed as `-tickrate` |
| `CSS_GSLT` | (empty) | Game Server Login Token, passed as `+sv_setsteamaccount` when set, needed for a public listing |
| `CSS_EXTRA_ARGS` | (empty) | Extra `srcds_run` arguments, space separated, appended after the built-in flags |

The entrypoint always passes `-game cstrike`, `-console`, `-usercon`, `-secure`, and `-strictportbind`.

## GSLT

1. Sign in at [Steam game server account management](https://steamcommunity.com/dev/managegameservers) and create a token for game id **240**.
2. Set `CSS_GSLT` to that token in compose, a `.env` file, or `-e` on `docker run`. The entrypoint only adds `+sv_setsteamaccount <token>` when `CSS_GSLT` is non-empty.

## Data volume

`./data` mounts to `/opt/cs-source`.

| Path | Purpose |
| --- | --- |
| `srcds_run` | Server launcher, installed by SteamCMD |
| `steam_appid.txt` | Rewritten on every start with `240`, the Steamworks app id CS:S needs at runtime |
| `cstrike/cfg/server.cfg` | Main server config, create it yourself, the entrypoint does not generate one |
| `cstrike/maps/` | Custom or workshop maps you copy in manually |
| `cstrike/addons/` | SourceMod or Metamod install location if you add server plugins |
| `bin/` | 32-bit engine libraries, referenced by `LD_LIBRARY_PATH` at startup |

## Updates and healthchecks

Set `CSS_FORCE_UPDATE=true` or run `./tools/gs update cs-source` from the [Ops](../guides/ops/) guide. The healthcheck is a `process` probe (`pgrep -f srcds_linux`) with a 600 second start period.

## Notes

- The Dockerfile sets `USER cssource`, so the container runs as that unprivileged user (uid 1000) by default. `docker-entrypoint.sh` only chowns `/opt/cs-source` when it is invoked as root, match host `./data` ownership to uid 1000 if you never run as root.
- `entrypoint.sh` strips Windows line endings from `srcds_run` (`sed -i 's/\r$//'`) on every start, not only on install.
- Unlike L4D2 and Insurgency Source, this entrypoint exports `LD_LIBRARY_PATH="${CSS_DIR}/bin:${CSS_DIR}:/usr/lib32:/usr/lib"` before launch, CS:S's older engine binaries need the bundled 32-bit libraries in `bin/`.
- `-secure` (VAC) is always passed and cannot be disabled through any environment variable.
- There is no dedicated RCON environment variable beyond `CSS_GSLT`. TCP 27015 is the RCON channel once you set `rcon_password` yourself, and `-usercon` is always passed to open the engine's console socket.
- First install downloads twice (a Windows depot pass, then the Linux depot) because `STEAMCMD_WINDOWS_WORKAROUND` defaults to `full`.
- Compose sets `mem_limit: 2048M` and `stop_grace_period: 90s`, the image sends `SIGINT` on stop so `srcds` can shut down cleanly.

## Compose

```bash
docker compose -f cs-source/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cs-source --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27005:27005/udp \
  -v "$PWD/cs-source/data:/opt/cs-source" \
  -e CSS_GSLT="your-gslt" \
  {{IMAGE_PREFIX}}/cs-source:latest
```
