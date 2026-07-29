---
title: Core Keeper
description: Core Keeper dedicated server via SteamCMD with Steam Datagram Relay by default.
---

Compose path: `core-keeper`. Image: `core-keeper`.

The entrypoint installs the dedicated server with SteamCMD (both the Steamworks Common Redistributables App and the Core Keeper server App), starts a headless Xvfb display since the server binary expects one even in dedicated mode, then launches `CoreKeeperServer`. By default the server uses Steam Datagram Relay (SDR) for networking and needs no published ports, direct connect mode is available by setting `SERVER_PORT`.

:::note[Requirements]
- Persist `./data` for the installed server, world data, and logs
- No ports need publishing in the default SDR mode, only open UDP if you set `SERVER_PORT` for direct connect
- Read the container logs (or `GameID.txt`) for the Game ID players use to connect over SDR
:::

## Networking modes

In SDR mode (the default), leave `SERVER_IP` and `SERVER_PORT` empty. Steam relays the connection and clients connect using the Game ID rather than an IP and port. When the session is ready, `docker logs` prints a colored Game ID line followed by:

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

For direct connect instead of SDR, set `SERVER_PORT` (and optionally `SERVER_IP`) and publish UDP **27015** and **27016** on the host. The shipped compose file keeps its `ports:` block commented out for this reason.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | SteamCMD login for the install step |
| `STEAM_PASSWORD` | (empty) | Password for `STEAM_USERNAME` when not anonymous |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code for the login above |
| `CK_APP_ID` | `1963720` | Steam App ID for the Core Keeper dedicated server |
| `CK_STEAMWORKS_APP_ID` | `1007` | Steamworks Common Redistributables App ID, installed alongside the server |
| `CK_FORCE_UPDATE` | `false` | Re-run `app_update` for both App IDs above on next start |
| `WORLD_INDEX` | `0` | `-world`, world slot index |
| `WORLD_NAME` | `Core Keeper Server` | `-worldname`, shown in the server browser and Game ID output |
| `WORLD_SEED` | (empty) | `-worldseed`, only used when generating a new world |
| `HASHED_WORLD_SEED` | (empty) | `-hashedworldseed`, alternate seed form accepted by the game |
| `WORLD_MODE` | `0` | `-worldmode`, world mode index used by the game |
| `GAME_ID` | (empty) | `-gameid`, forces a specific Game ID instead of letting Steam assign one |
| `MAX_PLAYERS` | `10` | `-maxplayers` |
| `SEASON` | (empty) | `-season`, seasonal event identifier |
| `SERVER_IP` | (empty) | `-ip`, bind address for direct connect mode |
| `SERVER_PORT` | (empty) | `-port`, enables direct connect mode when set |
| `PASSWORD` | (empty) | `-password`, join password |
| `ACTIVATE_CONTENT` | (empty) | `-activatecontent`, enables specific optional content |
| `ACTIVATE_ALL_CONTENT` | `false` | Adds `-activateallcontent` when `true` |
| `ALLOW_ONLY_PLATFORM` | (empty) | `-allowonlyplatform`, restricts connecting clients to a platform |
| `CK_EXTRA_ARGS` | (empty) | Extra arguments appended verbatim to the launch command, space-separated |
| `CK_HEALTH_SKIP_PROCESS` | `0` | Read only by `healthcheck.sh`, set to `1` to skip the process check and rely on `GameID.txt` alone |

## Data volume and file layout

Mount `core-keeper/data` at `/opt/corekeeper`. Two paths live under it:

| Path | Purpose |
| --- | --- |
| `server/` | SteamCMD-installed server binary, `logs/<timestamp>.log`, and `GameID.txt` / `GameInfo.txt` |
| `data/` | World save data, passed to the game with `-datapath` |

`GameID.txt` and `GameInfo.txt` are deleted and recreated on every start, do not treat them as persistent state.

## Update

`CK_FORCE_UPDATE=true` forces a reinstall on the next recreate. See [Ops](/guides/ops/) for `./tools/gs update core-keeper` and backups.

## Healthcheck

Catalog kind: `gameid`. `healthcheck.sh` requires both a running `CoreKeeperServer` process and a non-empty `server/GameID.txt`, the specific combination this healthcheck kind exists for. The 300 second start period covers the SteamCMD install plus the time Steam takes to hand back a Game ID over SDR. Set `CK_HEALTH_SKIP_PROCESS=1` to check only the `GameID.txt` condition.

## Compose

```bash
docker compose -f core-keeper/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name core-keeper --restart unless-stopped --init \
  -v "$PWD/core-keeper/data:/opt/corekeeper" \
  -e WORLD_NAME="Core Keeper Server" \
  -e MAX_PLAYERS=10 \
  {{IMAGE_PREFIX}}/core-keeper:latest
```

For direct connect, add `-p 27015:27015/udp -e SERVER_PORT=27015` (or any UDP port you choose).

The shipped compose file caps the container at 4096 MB of memory.
