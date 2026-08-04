---
title: Starbound
description: Starbound dedicated server via SteamCMD
---

On first start the container downloads the Starbound dedicated server (Steam app 211820) into your data folder. It writes a default starbound_server.config the first time that file is missing.

:::note[Before you start]
- Keep a data folder for the installed server, universe, and player data
- Open TCP port 21025
- No Steam account is needed. The server installs anonymously through SteamCMD
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 21025 | TCP | Game port (STARBOUND_PORT). Also used as steamPort in the generated config |

rconPort 21026 is written into the generated config bound to 127.0.0.1 only, and it is not published by compose. Map it yourself and change rconBindAddress in starbound_server.config if you want remote RCON.

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STARBOUND_PORT | 21025 | Game port. Only takes effect while writing the config the first time |
| STARBOUND_BIND | 0.0.0.0 | Bind address for gameServerBindAddress and steamBindAddress. First-write only |
| STARBOUND_EXTRA_ARGS | (empty) | Extra command-line flags added to the server launch |
| STARBOUND_FORCE_UPDATE | false | Re-download the server from Steam on next start |
| STARBOUND_APP_ID | 211820 | Steam app ID to install |
| STEAM_USERNAME | anonymous | Steam login used during the install step |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard code |

See [Quick start](/guides/quick-start/) if you need to log in with a real Steam account for the install step.

## First-start config

The container only writes starbound_server.config when the file does not already exist, using this template:

| Setting | Default value |
| --- | --- |
| gameServerPort / steamPort | STARBOUND_PORT (21025) |
| gameServerBindAddress / steamBindAddress | STARBOUND_BIND (0.0.0.0) |
| gameServerPassword | empty |
| maxPlayers | 8 |
| rconPort / rconBindAddress | 21026 / 127.0.0.1 |
| rconPassword | empty |
| allowAdminCommands | false |
| allowAnonymousConnections | true |
| serverName / serverDescription | Starbound Server / Starbound dedicated server |

STARBOUND_PORT and STARBOUND_BIND only affect this first write. After that, edit dockerized/starbound/data/starbound_server.config on the host for server name, password, RCON, admin list, and every other Starbound setting. The running server also rewrites this file as it operates.

## Data folder

Your data folder mounts to /opt/starbound inside the container. It holds the installed server binary, starbound_server.config, and everything under storage/ (universe, player, and world data) once Starbound creates it.

## Compose

```bash
docker compose -f dockerized/starbound/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name starbound --restart unless-stopped --init \
  -p 21025:21025/tcp \
  -v "$PWD/dockerized/starbound/data:/opt/starbound" \
  {{IMAGE_PREFIX}}/starbound:latest
```

## Updates

Set STARBOUND_FORCE_UPDATE to true and recreate the container, or use the update command described in [Ops](/guides/ops/).

## Health check

The container reports healthy while the Starbound server is running.
