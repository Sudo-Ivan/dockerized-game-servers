---
title: Core Keeper
description: Core Keeper dedicated server via SteamCMD with Steam Datagram Relay by default.
---

On first start the container downloads the Core Keeper dedicated server through SteamCMD, including the Steamworks redistributables the server needs. It starts a headless virtual display because the server binary expects one even in dedicated mode, then launches CoreKeeperServer.

By default the server uses Steam Datagram Relay (SDR) for networking and needs no published ports. Direct connect mode is available by setting SERVER_PORT.

:::note[Before you start]
- Keep a data folder for the installed server, world data, and logs
- No ports need to be published in the default SDR mode. Only open UDP if you set SERVER_PORT for direct connect
- Check the container logs (or GameID.txt) for the Game ID players use to connect over SDR
:::

## Networking modes

In SDR mode (the default), leave SERVER_IP and SERVER_PORT empty. Steam relays the connection and clients connect using the Game ID rather than an IP and port. When the session is ready, docker logs prints a colored Game ID line followed by:

```text
Status: server is up and ready for players!
```

```bash
docker logs core-keeper
```

If the container restarted before you copied the ID, read the file directly:

```bash
docker exec -it core-keeper cat /opt/corekeeper/server/GameID.txt
```

For direct connect instead of SDR, set SERVER_PORT (and optionally SERVER_IP) and publish UDP ports 27015 and 27016 on the host. The included compose file keeps its ports block commented out for this reason.

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used during the install step |
| STEAM_PASSWORD | (empty) | Password for STEAM_USERNAME when not anonymous |
| STEAM_GUARD_CODE | (empty) | Steam Guard dockerized/code for the login above |
| CK_APP_ID | 1963720 | Steam app ID for the Core Keeper dedicated server |
| CK_STEAMWORKS_APP_ID | 1007 | Steamworks Common Redistributables app ID, installed alongside the server |
| CK_FORCE_UPDATE | false | Re-download both app IDs from Steam on next start |
| WORLD_INDEX | 0 | World slot index (-world) |
| WORLD_NAME | Core Keeper Server | Name shown in the server browser and Game ID output (-worldname) |
| WORLD_SEED | (empty) | Seed used when generating a new world (-worldseed) |
| HASHED_WORLD_SEED | (empty) | Alternate seed form accepted by the game (-hashedworldseed) |
| WORLD_MODE | 0 | World mode index (-worldmode) |
| GAME_ID | (empty) | Forces a specific Game ID instead of letting Steam assign one (-gameid) |
| MAX_PLAYERS | 10 | Player cap (-maxplayers) |
| SEASON | (empty) | Seasonal event identifier (-season) |
| SERVER_IP | (empty) | Bind address for direct connect mode (-ip) |
| SERVER_PORT | (empty) | Enables direct connect mode when set (-port) |
| PASSWORD | (empty) | Join password (-password) |
| ACTIVATE_CONTENT | (empty) | Enables specific optional content (-activatecontent) |
| ACTIVATE_ALL_CONTENT | false | Adds -activateallcontent when true |
| ALLOW_ONLY_PLATFORM | (empty) | Restricts connecting clients to a platform (-allowonlyplatform) |
| CK_EXTRA_ARGS | (empty) | Extra launch arguments, space-separated |
| CK_HEALTH_SKIP_PROCESS | 0 | Set to 1 to skip the server-running check and rely on GameID.txt alone |

## Data folder and file layout

Mount dockerized/core-keeper/data at /opt/corekeeper. Two paths live under it:

| Path | Purpose |
| --- | --- |
| server/ | Installed server binary, logs, and GameID.txt / GameInfo.txt |
| data/ | World save data, passed to the game with -datapath |

GameID.txt and GameInfo.txt are deleted and recreated on every start. Do not treat them as persistent state.

## Updates

Set CK_FORCE_UPDATE to true and recreate the container, or use the update command described in [Ops](/guides/ops/).

## Health check

The container reports healthy when the Core Keeper server is running and GameID.txt contains a valid Game ID. Startup gets a 300 second grace period to cover the SteamCMD install and the time Steam takes to hand back a Game ID over SDR. Set CK_HEALTH_SKIP_PROCESS to 1 to check only GameID.txt.

## Compose

```bash
docker compose -f dockerized/core-keeper/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name core-keeper --restart unless-stopped --init \
  -v "$PWD/dockerized/core-keeper/data:/opt/corekeeper" \
  -e WORLD_NAME="Core Keeper Server" \
  -e MAX_PLAYERS=10 \
  {{IMAGE_PREFIX}}/core-keeper:latest
```

For direct connect, add -p 27015:27015/udp -e SERVER_PORT=27015 (or any UDP port you choose).

The included compose file caps the container at 4096 MB of memory.
