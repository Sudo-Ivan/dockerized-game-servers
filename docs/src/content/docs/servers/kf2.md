---
title: Killing Floor 2
description: Killing Floor 2 dedicated server via SteamCMD, App 232130.
---

Compose path: kf2. Image: kf2.

Killing Floor 2 dedicated server built on the shared [steam-base](/reference/images/) image. SteamCMD installs App **232130** (the Linux dedicated server depot) and the entrypoint launches the Unreal Engine 3 `KFGameSteamServer.bin.x86_64` binary directly.

:::note[Requirements]
- Publish UDP **7777**, UDP **27015**, TCP **8080**, and UDP **20560**
- Persist `./data` at `/opt/kf2`
- Killing Floor 2 is free to play, anonymous SteamCMD login normally works for App 232130, set `STEAM_USERNAME` and `STEAM_PASSWORD` only if an anonymous install fails
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7777 | UDP | Main game port (`KF2_PORT`) |
| 27015 | UDP | Query port (`KF2_QUERY_PORT`), used for server browser queries |
| 8080 | TCP | WebAdmin, fixed port, not configurable through any environment variable, enable and set credentials in `KFGame/Config/PCServer-KFWeb.ini` |
| 20560 | UDP | Steam networking port, fixed, not configurable through any environment variable |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | Steam login for the SteamCMD install step |
| `STEAM_PASSWORD` | (empty) | Password for `STEAM_USERNAME`, required for non-anonymous login |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code, only needed if Steam challenges the login |
| `KF2_APP_ID` | `232130` | SteamCMD app id for the dedicated server depot |
| `KF2_FORCE_UPDATE` | `false` | Set `true` to force `app_update 232130 validate` on next start |
| `STEAMCMD_WINDOWS_WORKAROUND` | `full` | SteamCMD depot fetch mode (`full`, `prime`, or `off`), `full` pulls a Windows depot pass before the Linux depot |
| `KF2_PORT` | `7777` | Game port, passed as `Port=` on the map launch line |
| `KF2_QUERY_PORT` | `27015` | Query port, passed as `QueryPort=` on the map launch line |
| `KF2_STARTMAP` | `kf-bioticslab` | Map loaded on startup |
| `KF2_EXTRA_ARGS` | (empty) | Extra launch arguments, space separated, appended after the built-in ones, use this for map URL options such as `?MaxPlayers=6` or `?Difficulty=4` |

There is no `KF2_MAXPLAYERS`, admin password, or RCON variable, set player count, difficulty, game length, and web admin login through `KF2_EXTRA_ARGS` map URL options or by editing the `.ini` files under `KFGame/Config/` in the data volume.

## Data volume

`./data` mounts to `/opt/kf2`.

| Path | Purpose |
| --- | --- |
| `Binaries/Win64/KFGameSteamServer.bin.x86_64` | The actual server executable, a native Linux ELF binary despite the `Win64` directory name from Tripwire's build layout |
| `steam_appid.txt` | Rewritten on every start with `232090`, the Steamworks app id KF2 needs at runtime |
| `KFGame/Config/PCServer-KFGame.ini` | Main gameplay config: mutators, difficulty, game length |
| `KFGame/Config/PCServer-KFEngine.ini` | Engine and networking config |
| `KFGame/Config/PCServer-KFWeb.ini` | WebAdmin port and login credentials |
| `KFGame/Logs/` | Server logs |
| `linux64/steamclient.so`, `linux32/steamclient.so` | Copied from the image's bundled SteamCMD runtime into the data volume on every start, required for the Steamworks API the engine loads |

## Updates and healthchecks

Set `KF2_FORCE_UPDATE=true` or run `./tools/gs update kf2` from the [Ops](../guides/ops/) guide. The healthcheck is a `process` probe (`pgrep -f KFGameSteamServer.bin`) with a 900 second start period, the longest of these four games since the KF2 depot is large.

Every install and forced update runs `app_update 232130 validate`. If you keep heavily customized `.ini` files under `KFGame/Config/`, back them up before setting `KF2_FORCE_UPDATE=true`.

## Notes

- The container starts as root, `docker-entrypoint.sh` creates `/opt/kf2`, chowns it to `kf2` (uid 1000), then drops privileges via `runuser` before running `entrypoint.sh`, so a fresh or root-owned host `./data` directory is fixed up automatically on every start.
- The Steam runtime library copy (`linux64/steamclient.so`, `linux32/steamclient.so`) runs on every start, even when `KF2_FORCE_UPDATE` is not set, do not rely on those folders staying empty.
- `LD_LIBRARY_PATH` is set to `${KF2_DIR}/linux64:${KF2_DIR}/Binaries/Linux` before launch, distinct from the `bin/` path CS:S uses.
- The image sends `SIGTERM` on stop (unlike the `SIGINT` used by the other three games here), and compose sets `mem_limit: 4096M` and `stop_grace_period: 90s`.

## Compose

```bash
docker compose -f kf2/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name kf2 --restart unless-stopped --init \
  -p 7777:7777/udp -p 27015:27015/udp -p 8080:8080/tcp -p 20560:20560/udp \
  -v "$PWD/kf2/data:/opt/kf2" \
  {{IMAGE_PREFIX}}/kf2:latest
```
