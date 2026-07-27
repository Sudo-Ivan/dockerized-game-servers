---
title: Factorio
description: Factorio headless dedicated server downloaded directly from factorio.com.
iconFit: contain
---

Compose path: `factorio`. Image: `factorio`.

The entrypoint downloads the official headless Linux package from `factorio.com` (no Steam or account needed), extracts it into the data volume, and writes a default `server-settings.json` and an initial save if neither already exists.

:::note[Requirements]
- Persist `./data` for the binary, saves, config, mods, and script output
- Publish UDP **34197** for the game and TCP **27015** if you set `RCON_PASSWORD`
- Changing `FACTORIO_VERSION` alone triggers a reinstall, `FACTORIO_FORCE_UPDATE` is only needed to force a reinstall of the same version
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 34197 | UDP | Game port (`PORT`) |
| 27015 | TCP | RCON, only opens when `RCON_PASSWORD` is set (`RCON_PORT`) |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `FACTORIO_VERSION` | `stable` | Release channel or exact version string used in the download URL |
| `FACTORIO_DOWNLOAD_URL` | `https://www.factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64` | Override the download URL directly, ignores `FACTORIO_VERSION` when set |
| `FACTORIO_FORCE_UPDATE` | `false` | Force a reinstall even if the installed version already matches `FACTORIO_VERSION` |
| `SERVER_NAME` | `Factorio Server` | Listing name |
| `SERVER_DESCRIPTION` | `Factorio dedicated server` | Listing description |
| `SERVER_PASSWORD` | (empty) | Join password, empty leaves the server open |
| `MAX_PLAYERS` | `0` | Player cap, `0` is unlimited |
| `SAVE_NAME` | `world` | Base name of the save file under `saves/`, becomes `<SAVE_NAME>.zip` |
| `LOAD_LATEST` | `false` | Start with `--start-server-load-latest` instead of loading `SAVE_NAME` explicitly, skips creating a new save |
| `PORT` | `34197` | Game UDP port |
| `BIND` | `0.0.0.0` | Bind address |
| `RCON_PORT` | `27015` | RCON TCP port |
| `RCON_PASSWORD` | (empty) | Enables RCON when non-empty |
| `PUBLIC_VISIBILITY` | `false` | List on the public server browser |
| `LAN_VISIBILITY` | `true` | Advertise on LAN |
| `AUTOSAVE_INTERVAL` | `10` | Minutes between autosaves |
| `AUTO_PAUSE` | `true` | Pause the game while no clients are connected |
| `FACTORIO_EXTRA_ARGS` | (empty) | Extra arguments appended verbatim to the launch command, space-separated |

## Data volume and file layout

Mount `factorio/data` at `/opt/factorio`. These subdirectories survive reinstalls and version upgrades, everything else under `/opt/factorio` is replaced on install:

| Path | Purpose |
| --- | --- |
| `saves/<SAVE_NAME>.zip` | Active save |
| `config/server-settings.json` | Generated on first start if missing, edit directly for settings not covered by the environment variables above |
| `mods/` | Drop `.zip` mod files here and restart |
| `script-output/` | Mod and scenario script output |
| `.installed-version` | Tracks the installed `FACTORIO_VERSION`, compared on every start to decide whether to reinstall |

The generated `server-settings.json` ships a placeholder `"tags": ["game", "tags"]` array, edit it by hand if you want real tags.

## Update

`FACTORIO_FORCE_UPDATE=true` forces a reinstall on the next recreate, but changing `FACTORIO_VERSION` alone already triggers one. See [Ops](/guides/ops/) for `./tools/gs update factorio` and backups.

## Healthcheck

Process check: the container is healthy while a `factorio` process is running under `bin/x64/factorio`, with a 300 second start period.

## Compose

```bash
export RCON_PASSWORD=changeme
docker compose -f factorio/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name factorio --restart unless-stopped --init \
  -p 34197:34197/udp -p 27015:27015/tcp \
  -v "$PWD/factorio/data:/opt/factorio" \
  -e RCON_PASSWORD=changeme \
  {{IMAGE_PREFIX}}/factorio:latest
```

Match mod versions in `factorio/data/mods/` to your server's Factorio version. The shipped compose file caps the container at 4096 MB of memory.
