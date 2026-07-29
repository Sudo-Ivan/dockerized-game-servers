---
title: Space Engineers
description: Space Engineers dedicated server (Windows binary via Wine).
steamAppId: "298740"
---

Compose path: `space-engineers`. Image: `space-engineers`.

Downloads the dedicated server tool (Steam App **298740**) with SteamCMD and runs `SpaceEngineersDedicated.exe` under Wine. The base game is Steam App **244850**, written to `steam_appid.txt`. Anonymous SteamCMD (the default) downloads App 298740. If the install fails, set `STEAM_USERNAME` and `STEAM_PASSWORD` for an account entitled to Space Engineers.

:::note[Requirements]
- Persist three separate paths, `dedicated`, `instances`, and `plugins` (see Volumes below)
- Publish UDP **27016** (game) and UDP **8766** (Steam)
- First start runs SteamCMD plus Wine and .NET Framework 4.8 setup and can take several minutes, `start_period` in the healthcheck is 900 seconds for this reason
- `mem_limit` is set to 8192M in compose
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27016 (`SE_PORT`) | UDP | Game port (`ServerPort` in the instance config) |
| 8766 (`SE_STEAM_PORT`) | UDP | Steam networking (`SteamPort` in the instance config) |
| 8080 | TCP | VRage Remote API, only if enabled in the instance config |

## Volumes

| Host path | Container path | Purpose |
| --- | --- | --- |
| `space-engineers/data/dedicated` | `/opt/spaceengineers/dedicated` | SteamCMD install of the dedicated server tool and game content |
| `space-engineers/data/instances` | `/opt/spaceengineers/instances` | Per-instance config and saves, default instance name `Default` |
| `space-engineers/data/plugins` | `/opt/spaceengineers/plugins` | Drop `.dll` plugins here, rebuilt into the instance config on every start |

The Wine prefix (`WINEPREFIX=/home/spaceengineers/.wine`) is baked into the image at build time under the container's home directory, not under any of the mounted volumes. `winetricks` installs `vcrun2019` and `dotnet48` there using a virtual X server during the image build. Rebuilding the image resets the prefix, recreating the container does not.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | SteamCMD login |
| `STEAM_PASSWORD` | empty | SteamCMD password |
| `STEAM_GUARD_CODE` | empty | Steam Guard code if prompted |
| `SE_APP_ID` | `298740` | Dedicated server tool SteamCMD app id |
| `SE_GAME_APP_ID` | `244850` | Space Engineers' own Steam app id, written to `steam_appid.txt` |
| `SE_FORCE_UPDATE` | `false` | Set `true` to reinstall on next start |
| `SE_INSTANCE_NAME` | `Default` | Instance folder name under `instances/` |
| `SE_SERVER_NAME` | `Space Engineers` | Name shown in the server list |
| `SE_WORLD_NAME` | `DedicatedWorld` | Save folder name under the instance |
| `SE_PUBLIC_IP` | empty | `<IP>` written into the instance config, auto-detected from the container's address when empty |
| `SE_PORT` | `27016` | Game UDP port (`ServerPort`) |
| `SE_STEAM_PORT` | `8766` | Steam UDP port (`SteamPort`) |
| `SE_EXTRA_ARGS` | empty | Extra flags appended to the launch command |
| `SE_PREMADE_CHECKPOINT` | `<dedicated>/Content/CustomWorlds/Earth Planet/PC` | Starting scenario checkpoint, used only when no save exists yet |

`SE_EXTRA_ARGS` has no shell default inside the entrypoint, unlike the other games on this page. Compose always defines it as an empty string, but a plain `docker run` must still pass `-e SE_EXTRA_ARGS=` (even empty), or the container exits immediately on an unset variable.

## Instance config

`instances/<SE_INSTANCE_NAME>/SpaceEngineers-Dedicated.cfg` is written once with `GameMode Survival`, a fixed `MaxPlayers` of `4`, and the other session defaults visible in `space-engineers/entrypoint.sh`. There is no `SE_MAX_PLAYERS` variable, edit `MaxPlayers` in the generated cfg by hand for a different cap.

On every start, not only the first, the entrypoint also rewrites three elements in that file regardless of manual edits:

| Element | Rewritten from |
| --- | --- |
| `<IP>` | `SE_PUBLIC_IP`, or the container's detected address when empty |
| `<LoadWorld>` | The instance's save path if one already exists under `Saves/<SE_WORLD_NAME>/`, cleared otherwise |
| `<SteamPort>` | `SE_STEAM_PORT` |
| `<ServerPort>` | `SE_PORT` |
| `<Plugins>` | Every `.dll` currently in the `plugins/` volume |

Everything else in the file (`GameMode`, `InventorySize`, `TotalPCU`, `ViewDistance`, and so on) persists across restarts once written. The whole file is regenerated from scratch if it looks like an old `MyObjectBuilder_ConfigDedicated`-style file or is missing `PremadeCheckpointPath`.

## Updates

Set `SE_FORCE_UPDATE=true` to reinstall on the next start, or run `./tools/gs update space-engineers` from the [Ops](../guides/ops/) guide.

## Healthcheck

Process check (`pgrep -f SpaceEngineersDedicated`), 900 second start period.

## Compose

```bash
docker compose -f space-engineers/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name space-engineers --restart unless-stopped --init \
  -p 27016:27016/udp \
  -v "$PWD/space-engineers/data/dedicated:/opt/spaceengineers/dedicated" \
  -v "$PWD/space-engineers/data/instances:/opt/spaceengineers/instances" \
  -v "$PWD/space-engineers/data/plugins:/opt/spaceengineers/plugins" \
  -e SE_PUBLIC_IP=203.0.113.10 \
  -e SE_EXTRA_ARGS= \
  {{IMAGE_PREFIX}}/space-engineers:latest
```
