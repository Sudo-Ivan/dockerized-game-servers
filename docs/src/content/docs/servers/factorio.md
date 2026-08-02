---
title: Factorio
description: Factorio headless dedicated server downloaded directly from dockerized/factorio.com.
iconFit: contain
---

On first start the container downloads the official headless Linux package from dockerized/factorio.com. No Steam account is required. It extracts the server into your data folder and creates a default server-settings.json and an initial save if neither already exists.

:::note[Before you start]
- Keep a data folder for the server binary, saves, config, mods, and script output
- Open UDP port 34197 for the game. Open TCP 27015 if you set RCON_PASSWORD
- Changing FACTORIO_VERSION alone triggers a reinstall. FACTORIO_FORCE_UPDATE is only needed to reinstall the same version again
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 34197 | UDP | Game port (PORT) |
| 27015 | TCP | RCON, only opens when RCON_PASSWORD is set (RCON_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| FACTORIO_VERSION | stable | Release channel or exact version used in the download URL |
| FACTORIO_DOWNLOAD_URL | https://www.factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64 | Override the download URL directly. Ignores FACTORIO_VERSION when set |
| FACTORIO_FORCE_UPDATE | false | Force a reinstall even if the installed version already matches FACTORIO_VERSION |
| SERVER_NAME | Factorio Server | Name shown in the server browser |
| SERVER_DESCRIPTION | Factorio dedicated server | Description shown in the server browser |
| SERVER_PASSWORD | (empty) | Join password. Leave empty for an open server |
| MAX_PLAYERS | 0 | Player cap. 0 means unlimited |
| SAVE_NAME | world | Base name of the save file under saves/. Becomes world.zip |
| LOAD_LATEST | false | Start with the latest save instead of SAVE_NAME. Skips creating a new save |
| PORT | 34197 | Game UDP port |
| BIND | 0.0.0.0 | Bind address |
| RCON_PORT | 27015 | RCON TCP port |
| RCON_PASSWORD | (empty) | Enables RCON when set |
| PUBLIC_VISIBILITY | false | List on the public server browser |
| LAN_VISIBILITY | true | Advertise on LAN |
| AUTOSAVE_INTERVAL | 10 | Minutes between autosaves |
| AUTO_PAUSE | true | Pause the game while no clients are connected |
| FACTORIO_EXTRA_ARGS | (empty) | Extra launch arguments, space-separated |

## Data folder and file layout

Mount dockerized/factorio/data at /opt/factorio. These folders survive reinstalls and version upgrades. Everything else under /opt/factorio is replaced on install:

| Path | Purpose |
| --- | --- |
| saves/world.zip | Active save (name follows SAVE_NAME) |
| config/server-settings.json | Created on first start if missing. Edit directly for settings not covered above |
| mods/ | Drop .zip mod files here and restart |
| script-output/ | Mod and scenario script output |
| .installed-version | Tracks the installed FACTORIO_VERSION |

The generated server-settings.json ships with placeholder tags. Edit the file by hand if you want real tags.

## Updates

Set FACTORIO_FORCE_UPDATE to true and recreate the container, or change FACTORIO_VERSION to trigger a reinstall. See [Ops](/guides/ops/) for the update command and backup tips.

## Health check

The container reports healthy while the Factorio server is running. Startup gets a 300 second grace period.

## Compose

```bash
export RCON_PASSWORD=changeme
docker compose -f dockerized/factorio/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name factorio --restart unless-stopped --init \
  -p 34197:34197/udp -p 27015:27015/tcp \
  -v "$PWD/dockerized/factorio/data:/opt/factorio" \
  -e RCON_PASSWORD=changeme \
  {{IMAGE_PREFIX}}/factorio:latest
```

Match mod versions in dockerized/factorio/data/mods/ to your server's Factorio version. The included compose file caps the container at 4096 MB of memory.
