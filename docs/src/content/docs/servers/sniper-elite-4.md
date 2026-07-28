---
title: Sniper Elite 4
description: Sniper Elite 4 dedicated server (Windows binary via Wine).
---

Compose path: `sniper-elite-4`. Image: `sniper-elite-4`.

Downloads the dedicated server tool (Steam App **568880**) with SteamCMD and runs `SniperElite4_Dedicated.exe` under Wine. Sniper Elite 4 itself is Steam App **312660**, written to `steam_appid.txt`. Anonymous SteamCMD (the default) downloads App 568880. If the install fails, or the server does not list publicly, set `STEAM_USERNAME` and `STEAM_PASSWORD` for an account entitled to Sniper Elite 4.

:::note[Requirements]
- Persist `sniper-elite-4/data` at `/opt/se4`
- Publish UDP **27000** (auth), UDP **27005** (game), TCP **27010** (lobby), and UDP **27015** (update)
- First start downloads through SteamCMD and initializes a Wine prefix, which takes noticeably longer than later restarts
- `mem_limit` is set to 2048M in compose, the lightest Wine-based game covered under Servers
- Starts as root and self-heals `sniper-elite-4/data` ownership on every start, see Permissions below
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27000 (`SE4_AUTH_PORT`) | UDP | Authentication |
| 27005 (`SE4_GAME_PORT`) | UDP | Game traffic |
| 27010 (`SE4_LOBBY_PORT`) | TCP | Lobby |
| 27015 (`SE4_UPDATE_PORT`) | UDP | Update channel |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | SteamCMD login |
| `STEAM_PASSWORD` | empty | SteamCMD password |
| `STEAM_GUARD_CODE` | empty | Steam Guard code if prompted |
| `SE4_APP_ID` | `568880` | Dedicated server tool SteamCMD app id |
| `SE4_STEAM_APP_ID` | `312660` | Sniper Elite 4's own Steam app id, written to `steam_appid.txt` |
| `SE4_FORCE_UPDATE` | `false` | Set `true` to reinstall on next start |
| `SE4_AUTH_PORT` | `27000` | `Server.AuthPort` in `server.cfg` |
| `SE4_GAME_PORT` | `27005` | `Server.GamePort` in `server.cfg` |
| `SE4_LOBBY_PORT` | `27010` | `Server.LobbyPort` in `server.cfg` |
| `SE4_UPDATE_PORT` | `27015` | `Server.UpdatePort` in `server.cfg` |
| `SE4_SERVER_NAME` | `Sniper Elite 4 Server` | `Server.Name` in `server.cfg` |
| `SE4_MAX_PLAYERS` | `12` | `Settings.MaxPlayers` in `server.cfg` |
| `SE4_MAP_ROTATION` | `VILLAGE:DM,RIVIERA:DM,COMPOUND:DM,RAILYARD:DM,DOCKYARD:DM` | Comma-separated `MAP:MODE` pairs, one `MapRotation.AddMap` line per pair |
| `SE4_EXTRA_ARGS` | empty | Extra flags appended to the launch command |

## Data volume

`sniper-elite-4/data` mounts at `/opt/se4`.

| Path | Purpose |
| --- | --- |
| `server.cfg` | Generated once from the environment variables above, then left alone. Ends with a `Server.Host` line, which is required for the process to actually start hosting |
| `.wine/` | Wine prefix (`WINEPREFIX`), created on first start |
| `steam_appid.txt` | Rewritten every start with `SE4_STEAM_APP_ID` |

Edit `server.cfg` directly for settings beyond map rotation and player count. If SteamCMD lays the depot out under a nested `steamapps/common/<name>` folder instead of the volume root, the entrypoint detects it and moves the files up into `/opt/se4` on first start.

## Tuning the server (server.cfg)

Stop the container, edit `sniper-elite-4/data/server.cfg`, and start it again, `SniperElite4_Dedicated.exe` reads the file once at launch via `-exec`. Useful lines beyond what the environment variables above generate:

| Setting | Purpose |
| --- | --- |
| `Server.MoTD "<text>"` | Message of the day shown to joining players |
| `Server.AddTimedText "<text>"` plus `Server.TimedTextInterval <minutes>` | Repeats a chat message on a timer, one `AddTimedText` line per message |
| `Rcon.Password "<password>"` | Enables remote admin commands, combine with `Rcon.Port` and `Rcon.Listen` if you need remote RCON access |
| `Settings.DefaultScoreLimit` / `Settings.DefaultTimeLimit` | Per-round score and time limits |
| `Settings.MaxLatency <ms>` | Kicks players above a ping threshold, commented out by default upstream |
| `Lobby.StartTimer <seconds>` | How long the pre-match lobby waits before starting |
| `exec Preset_Hardcore.cfg` (or another `Preset_*.cfg` shipped with the dedicated server tool) | Applies a bundled ruleset on top of your own settings, add the `exec` line before `Server.Host` |

`Server.Host` has to stay the last line in the file since it is what actually starts hosting, anything appended after it is ignored. Running more than one instance on the same host needs a fully distinct port set per instance (`SE4_AUTH_PORT`, `SE4_GAME_PORT`, `SE4_LOBBY_PORT`, `SE4_UPDATE_PORT`) and a separate data volume.

## Permissions

The container starts as root, `docker-entrypoint.sh` creates `/opt/se4`, chowns it to `se4` (UID 1000), then drops privileges via `runuser` before running `entrypoint.sh`, so a fresh or root-owned host `sniper-elite-4/data` directory is fixed up automatically on every start.

## Updates

Set `SE4_FORCE_UPDATE=true` to reinstall on the next start, or run `./tools/gs update sniper-elite-4` from the [Ops](../guides/ops/) guide.

## Healthcheck

Process check (`pgrep -f SniperElite4_Dedicated`), 300 second start period.

## Compose

```bash
docker compose -f sniper-elite-4/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name sniper-elite-4 --restart unless-stopped --init \
  -p 27000:27000/udp -p 27005:27005/udp -p 27010:27010/tcp -p 27015:27015/udp \
  -v "$PWD/sniper-elite-4/data:/opt/se4" \
  -e SE4_SERVER_NAME="My SE4 Server" \
  {{IMAGE_PREFIX}}/sniper-elite-4:latest
```
