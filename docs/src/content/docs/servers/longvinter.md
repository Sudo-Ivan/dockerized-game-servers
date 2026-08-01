---
title: Longvinter
description: Longvinter dedicated server via SteamCMD
---

On first start the container downloads the Longvinter dedicated server (Steam app 1639880) into your data folder. It writes a default Game.ini the first time that file is missing.

:::note[Before you start]
- Keep a data folder for the installed server and Longvinter/Saved/ world data
- Open UDP port 7777 for the game
- Give the container at least 4 GB of RAM
- No Steam account is needed. The server installs anonymously through SteamCMD
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7777 | UDP | Game port (LONGVINTER_PORT). Required for players to join |

Longvinter uses UDP only for gameplay. Do not publish TCP 7777.

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| LONGVINTER_PORT | 7777 | Game port, passed as -GamePort= on every start |
| LONGVINTER_SERVER_NAME | Longvinter Server | ServerName in Game.ini. First-write only |
| LONGVINTER_SERVER_MOTD | Welcome to Longvinter! | ServerMOTD in Game.ini. First-write only |
| LONGVINTER_MAX_PLAYERS | 32 | MaxPlayers in Game.ini. First-write only |
| LONGVINTER_PASSWORD | (empty) | Join password in Game.ini. First-write only |
| LONGVINTER_COMMUNITY_WEBSITE | discord.gg/longvinter | CommunityWebsite in Game.ini. First-write only |
| LONGVINTER_ADMIN_STEAM_ID | (empty) | Space-separated EOS IDs for AdminSteamID. First-write only |
| LONGVINTER_PVP | true | PVP in Game.ini. First-write only |
| LONGVINTER_TENT_DECAY | true | TentDecay in Game.ini. First-write only |
| LONGVINTER_MAX_TENTS | 3 | MaxTents in Game.ini. First-write only |
| LONGVINTER_RESTART_TIME_24H | 6 | Scheduled restart hour (RestartTime24h). First-write only |
| LONGVINTER_SAVE_BACKUPS | true | SaveBackups in Game.ini. First-write only |
| LONGVINTER_EXTRA_ARGS | (empty) | Extra command-line flags added after -GamePort= |
| LONGVINTER_FORCE_UPDATE | false | Re-download the server from Steam on next start |
| LONGVINTER_APP_ID | 1639880 | Steam app ID to install |
| STEAM_USERNAME | anonymous | Steam login used during the install step |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard code |

See [Quick start](/guides/quick-start/) if you need to log in with a real Steam account for the install step.

LONGVINTER_PORT is passed on every launch. The other LONGVINTER_* settings that map to Game.ini only apply when the container creates that file on first start. After that, edit longvinter/data/Longvinter/Saved/Config/LinuxServer/Game.ini on the host for server name, PvP, admins, and every other Longvinter setting. See the [Longvinter server configuration wiki](https://wiki.longvinter.com/server/configuration) for the full option list.

## Data folder

Your data folder mounts to /opt/longvinter inside the container. It holds the installed server launcher and binaries, plus everything under Longvinter/Saved/ (world saves, Game.ini, logs) once Longvinter creates it.

## Compose

```bash
docker compose -f longvinter/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name longvinter --restart unless-stopped --init \
  -p 7777:7777/udp \
  -v "$PWD/longvinter/data:/opt/longvinter" \
  {{IMAGE_PREFIX}}/longvinter:latest
```

## Updates

Set LONGVINTER_FORCE_UPDATE to true and recreate the container, or use the update command described in [Ops](/guides/ops/).

## Health check

The container reports healthy while the Longvinter server is running. The check accepts either shipping binary name used across different builds.
