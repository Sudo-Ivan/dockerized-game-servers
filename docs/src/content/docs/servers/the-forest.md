---
title: The Forest
description: The Forest dedicated server, a native Linux binary via SteamCMD with no Wine involved.
---

This image downloads and runs the native Linux dedicated server for The Forest through SteamCMD. There is no Wine and no Windows binary involved. Anonymous Steam login does not work. You need a Steam account that owns The Forest.

:::note[Before you start]
- Keep a data folder for the server install and saves
- Open TCP and UDP ports 8766, 27015, and 27016
- Set STEAM_USERNAME and STEAM_PASSWORD for an account that owns the game
- The compose file sets a 3 GB memory limit
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 8766 | TCP and UDP | Steam networking (FOREST_STEAM_PORT) |
| 27015 | TCP and UDP | Game traffic (FOREST_GAME_PORT) |
| 27016 | TCP and UDP | Server browser query (FOREST_QUERY_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used to download the server |
| STEAM_PASSWORD | (empty) | Steam password, required for this server |
| STEAM_GUARD_CODE | (empty) | Steam Guard dockerized/code if prompted during login |
| FOREST_APP_ID | 556450 | Steam app id, shared by the server and the game |
| FOREST_FORCE_UPDATE | false | Reinstall the server on next start |
| FOREST_IP | 0.0.0.0 | Bind address (-serverip) |
| FOREST_STEAM_PORT | 8766 | Steam port (-serversteamport) |
| FOREST_GAME_PORT | 27015 | Game port (-servergameport) |
| FOREST_QUERY_PORT | 27016 | Query port (-serverqueryport) |
| FOREST_SERVER_NAME | The Forest Dedicated Server | Server name (-servername) |
| FOREST_MAX_PLAYERS | 8 | Player cap (-serverplayers) |
| FOREST_PASSWORD | (empty) | Join password (-serverpassword), omitted when empty |
| FOREST_ADMIN_PASSWORD | (empty) | Admin password (-serverpassword_admin), omitted when empty |
| FOREST_STEAM_ACCOUNT | (empty) | Game Server Login Token (-serversteamaccount), omitted when empty |
| FOREST_DIFFICULTY | Normal | Peaceful, Normal, or Hard |
| FOREST_INIT_TYPE | Continue | New or Continue. Continue means restarts do not wipe the save |
| FOREST_SLOT | 1 | Save slot, 1 to 5 |
| FOREST_AUTOSAVE_INTERVAL | 15 | Autosave interval (-serverautosaveinterval) |
| FOREST_ENABLE_VAC | true | Adds -enableVAC when true |
| FOREST_EXTRA_ARGS | (empty) | Extra flags appended to the launch command |

## Data folder

Your data folder mounts at /opt/theforest inside the container.

| Path | Purpose |
| --- | --- |
| TheForestDedicatedServer and game files | Installed by SteamCMD |
| home/.config/unity3d/SKS/TheForestDedicatedServer/ds/ | Unity save games and server state |

The container sets HOME so Unity's config path lands inside the data folder. No config file is written. All settings above are launch arguments. If SteamCMD installs files under a nested steamapps/common folder, the container moves them up on first start.

The container fixes file ownership on the data folder automatically.

## Updates

Set FOREST_FORCE_UPDATE to true to reinstall on the next start. You can also run ./tools/gs update the-forest. See [Ops](/guides/ops/).

## Health check

The container reports healthy while The Forest server process is running. Startup gets a 300 second grace period.

## Compose

```bash
docker compose -f dockerized/the-forest/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name the-forest --restart unless-stopped --init \
  -p 8766:8766/tcp -p 8766:8766/udp \
  -p 27015:27015/tcp -p 27015:27015/udp \
  -p 27016:27016/tcp -p 27016:27016/udp \
  -v "$PWD/dockerized/the-forest/data:/opt/theforest" \
  -e FOREST_SERVER_NAME="My Forest Server" \
  {{IMAGE_PREFIX}}/the-forest:latest
```
