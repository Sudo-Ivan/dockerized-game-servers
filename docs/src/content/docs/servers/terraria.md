---
title: Terraria
description: Terraria dedicated server via SteamCMD
---

On first start the container downloads the Terraria dedicated server (Steam app 105600) into your data folder. It also writes a default serverconfig.txt and auto-creates a world the first time those files are missing.

:::note[Before you start]
- Keep a data folder for the installed server, worlds, and config
- Open TCP port 7777
- No Steam account is needed. The server installs anonymously through SteamCMD
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7777 | TCP | Game port (SERVER_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| WORLD_NAME | world | World file name, combined with WORLD_PATH as world=WORLD_PATH/WORLD_NAME |
| WORLD_PATH | Worlds | Folder (relative to /opt/terraria) that holds world files |
| SERVER_PORT | 7777 | Game port |
| MAX_PLAYERS | 8 | Player cap |
| SERVER_PASSWORD | (empty) | Join password |
| MOTD | Welcome | Message of the day |
| DIFFICULTY | 0 | World difficulty written into serverconfig.txt. Terraria values: 0 classic, 1 expert, 2 master, 3 journey |
| TERRARIA_EXTRA_ARGS | (empty) | Extra command-line flags added to the server launch |
| TERRARIA_FORCE_UPDATE | false | Re-download the server from Steam on next start |
| TERRARIA_APP_ID | 105600 | Steam app ID to install |
| STEAM_USERNAME | anonymous | Steam login used during the install step |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard code |

See [Quick start](/guides/quick-start/) if you need to log in with a real Steam account for the install step.

## First-start config and world

The container only writes serverconfig.txt when the file does not already exist. It fills in the settings above plus worldpath=WORLD_PATH/ and autocreate=1. autocreate=1 tells Terraria to generate a small world named WORLD_NAME if none exists yet. Terraria defines 1 as small, 2 as medium, and 3 as large for that setting.

Settings in the table above only take effect on this first write. To change a running server, edit terraria/data/serverconfig.txt directly. You can also place your own .wld file at terraria/data/Worlds/WORLD_NAME.wld before the first start so Terraria loads it instead of generating a new one.

## Data folder

Your data folder mounts to /opt/terraria inside the container. It holds the installed server binary, serverconfig.txt, and the Worlds/ folder with .wld and backup files.

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

## Updates

Set TERRARIA_FORCE_UPDATE to true and recreate the container, or use the update command described in [Ops](/guides/ops/).

## Health check

The container reports healthy while the Terraria server is running.
