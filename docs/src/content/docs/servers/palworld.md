---
title: Palworld
description: Palworld dedicated server via SteamCMD
---

On first start the container downloads the Palworld Linux dedicated server (Steam app 2394010) into your data folder. Palworld writes its own settings and save data under Pal/Saved/ once it has run at least once. The container does not create or edit Palworld config files for you.

:::note[Before you start]
- Keep a data folder for the installed server and Pal/Saved/ world data
- Open UDP port 8211 for players. UDP 27015 helps with Steam server browser listing
- Give the container at least 8 GB of RAM
- No Steam account is needed. The server installs anonymously through SteamCMD
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 8211 | UDP | Game port (PALWORLD_PORT). Required for players to join |
| 27015 | UDP | Steam query. Recommended for community browser visibility |
| 25575 | TCP | RCON, only if you enable it in PalWorldSettings.ini |
| 8212 | TCP | REST API, only if you enable it in settings |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| PALWORLD_PORT | 8211 | Game port, passed as -port= |
| PALWORLD_PLAYERS | 32 | Player cap, passed as -players= |
| PALWORLD_EXTRA_ARGS | (empty) | Extra command-line flags added to the server launch |
| PALWORLD_FORCE_UPDATE | false | Re-download the server from Steam on next start |
| PALWORLD_APP_ID | 2394010 | Steam app ID to install |
| STEAM_USERNAME | anonymous | Steam login used during the install step |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard code |

See [Quick start](/guides/quick-start/) if you need to log in with a real Steam account for the install step.

Every launch also passes -useperfthreads, -NoAsyncLoadingThread, and -UseMultithreadForDS along with -port and -players. These performance flags are fixed. Add or remove other flags only through PALWORLD_EXTRA_ARGS.

## Server settings

Palworld does not read the settings above for world name, difficulty, or passwords. Those live in PalWorldSettings.ini, which the game creates on first run. Edit it on the host at:

```text
palworld/data/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
```

Stop the container before editing, then start it again for changes to take effect.

## Data folder

Your data folder mounts to /opt/palworld inside the container. It holds the installed server files plus everything Palworld creates under Pal/Saved/ (world saves, PalWorldSettings.ini, logs) after the first run.

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

## Updates

Set PALWORLD_FORCE_UPDATE to true and recreate the container, or use the update command described in [Ops](/guides/ops/).

## Health check

The container reports healthy while the Palworld server is running. Palworld has renamed its main binary across updates, so the check accepts either shipping binary name.
