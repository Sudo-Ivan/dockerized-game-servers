---
title: Palworld
description: Palworld dedicated server via SteamCMD
---

Compose path: palworld. Image: palworld. Built from the shared [steam-base](/reference/images/) image (Arch Linux with SteamCMD, plus `icu` and `openssl` that the server binary links against).

Palworld installs the Linux dedicated server, Steam App **2394010**, into the data volume on first start. Palworld itself writes its settings and save data under `Pal/Saved/` inside the data volume once it has run at least once, the entrypoint does not template any config file.

:::note[Requirements]
- Persist `./data` for the installed server and `Pal/Saved/` world data
- Publish UDP **8211**
- Allocate at least 8 GB RAM
- No Steam account is required, SteamCMD installs App 2394010 anonymously
:::

## How the server is installed

`entrypoint.sh` uses the shared [`bases/steam/steamcmd-app-update.sh`]({{GITHUB_URL}}/blob/master/bases/steam/steamcmd-app-update.sh) helper to run `+app_update 2394010 validate` against the data volume, logging in anonymously unless you set `STEAM_USERNAME`/`STEAM_PASSWORD`. If `PalServer.sh` is missing or `PALWORLD_FORCE_UPDATE=true`, it reinstalls before starting. A fallback walks `/home/palworld/Steam/steamapps/common` and relocates any directory containing `PalServer.sh` into the data volume.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 8211 | UDP | Game port (`PALWORLD_PORT`) |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `PALWORLD_PORT` | `8211` | Game port, passed as `-port=` |
| `PALWORLD_PLAYERS` | `32` | Player cap, passed as `-players=` |
| `PALWORLD_EXTRA_ARGS` | *(empty)* | Extra CLI flags appended to `PalServer.sh` |
| `PALWORLD_FORCE_UPDATE` | `false` | Re-run SteamCMD for App 2394010 on next start |
| `PALWORLD_APP_ID` | `2394010` | Steam app id to install |
| `STEAM_USERNAME` | `anonymous` | Steam login for the install step |
| `STEAM_PASSWORD` | *(empty)* | Steam password |
| `STEAM_GUARD_CODE` | *(empty)* | Steam Guard code |

See [Quick start](/guides/quick-start/) for the shared Steam login pattern.

Every launch always passes `-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS` in addition to `-port` and `-players`. These performance flags are not individually configurable, add or remove flags only through `PALWORLD_EXTRA_ARGS`.

## Server settings

Palworld does not read any of the environment variables above for world name, difficulty, or passwords, those live in `PalWorldSettings.ini`, which the game creates on first run. Edit it on the host at:

```text
palworld/data/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
```

Stop the container before editing, then start it again for the new settings to load.

## Data volume

`./data` mounts to `/opt/palworld`. It holds the installed `PalServer.sh` launcher and matching binaries, plus everything Palworld creates under `Pal/Saved/` (world saves, `PalWorldSettings.ini`, logs) after the first run.

## Compose

```bash
docker compose -f palworld/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name palworld --restart unless-stopped --init \
  -p 8211:8211/udp \
  -v "$PWD/palworld/data:/opt/palworld" \
  {{IMAGE_PREFIX}}/palworld:latest
```

## Updating

Set `PALWORLD_FORCE_UPDATE=true` and recreate the container, or run `./tools/gs update palworld` from [Ops](/guides/ops/). The healthcheck is a `process` probe that matches either `PalServer-Linux-Shipping` or `Pal-Linux-Shipping`, since Palworld has renamed its shipping binary across updates.
