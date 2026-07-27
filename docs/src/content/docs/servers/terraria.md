---
title: Terraria
description: Terraria dedicated server via SteamCMD
---

Compose path: terraria. Image: terraria. Built from the shared [steam-base](/reference/images/) image (Arch Linux with SteamCMD).

Terraria installs the official dedicated server, Steam App **105600**, into the data volume on first start, then writes a default `serverconfig.txt` and auto-creates a world the first time those are missing.

:::note[Requirements]
- Persist `./data` for the installed server, worlds, and config
- Publish TCP **7777**
- No Steam account is required, SteamCMD installs App 105600 anonymously
:::

## How the server is installed

`entrypoint.sh` uses the shared [`bases/steam/steamcmd-app-update.sh`]({{GITHUB_URL}}/blob/master/bases/steam/steamcmd-app-update.sh) helper to run `+app_update 105600 validate` against the data volume, logging in anonymously unless you set `STEAM_USERNAME`/`STEAM_PASSWORD`. If the binary is missing or `TERRARIA_FORCE_UPDATE=true`, it reinstalls before starting. A fallback walks `/home/terraria/Steam/steamapps/common` and relocates any directory containing `Linux/TerrariaServer.bin.x86_64` into the data volume.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7777 | TCP | Game port (`SERVER_PORT`) |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `WORLD_NAME` | `world` | World file name, combined with `WORLD_PATH` as `world=<WORLD_PATH>/<WORLD_NAME>` |
| `WORLD_PATH` | `Worlds` | Directory (relative to `/opt/terraria`) holding world files |
| `SERVER_PORT` | `7777` | Game port |
| `MAX_PLAYERS` | `8` | Player cap |
| `SERVER_PASSWORD` | *(empty)* | Join password |
| `MOTD` | `Welcome` | Message of the day |
| `DIFFICULTY` | `0` | World difficulty written straight into `serverconfig.txt`, Terraria's own values are `0` classic, `1` expert, `2` master, `3` journey |
| `TERRARIA_EXTRA_ARGS` | *(empty)* | Extra CLI flags appended to `TerrariaServer.bin.x86_64 -config ...` |
| `TERRARIA_FORCE_UPDATE` | `false` | Re-run SteamCMD for App 105600 on next start |
| `TERRARIA_APP_ID` | `105600` | Steam app id to install |
| `STEAM_USERNAME` | `anonymous` | Steam login for the install step |
| `STEAM_PASSWORD` | *(empty)* | Steam password |
| `STEAM_GUARD_CODE` | *(empty)* | Steam Guard code |

See [Quick start](/guides/quick-start/) for the shared Steam login pattern.

## First-start config and world

`entrypoint.sh` only writes `serverconfig.txt` when the file does not already exist, filling in the variables above plus `worldpath=<WORLD_PATH>/` and `autocreate=1`. `autocreate=1` tells the Terraria server to generate a **small** world named `WORLD_NAME` if none exists yet. Terraria itself defines `1` small, `2` medium, `3` large for that setting.

Every variable in the table above only takes effect on this first write. Change a running server by editing `terraria/data/serverconfig.txt` directly, or place your own `.wld` file at `terraria/data/Worlds/<WORLD_NAME>.wld` before the first start so Terraria loads it instead of generating a new one.

## Data volume

`./data` mounts to `/opt/terraria`. It holds the installed `Linux/TerrariaServer.bin.x86_64` binary, `serverconfig.txt`, and the `Worlds/` directory with `.wld` and backup files.

## Compose

```bash
docker compose -f terraria/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name terraria --restart unless-stopped --init \
  -p 7777:7777/tcp \
  -v "$PWD/terraria/data:/opt/terraria" \
  {{IMAGE_PREFIX}}/terraria:latest
```

## Updating

Set `TERRARIA_FORCE_UPDATE=true` and recreate the container, or run `./tools/gs update terraria` from [Ops](/guides/ops/). The healthcheck is a `process` probe for `TerrariaServer`.
