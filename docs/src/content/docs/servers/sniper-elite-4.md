---
title: Sniper Elite 4
description: Sniper Elite 4 dedicated server (Windows binary via Wine).
---

Compose path: sniper-elite-4. Image: sniper-elite-4.

Downloads the dedicated server tool (Steam App 568880) via SteamCMD and runs `bin/SniperElite4_Dedicated.exe` under Wine. UDP 27000 (auth), UDP 27005 (game), TCP 27010 (lobby), UDP 27015 (update).

## Behavior

`server.cfg` is generated in `sniper-elite-4/data/` from the environment variables below on first start, and left alone afterward. The generated file ends with `Server.Host`, which is required for the process to actually start hosting. Edit it directly for settings beyond map rotation and player count (admin/server passwords, per-preset gameplay rules, timed chat messages).

## Environment

| Variable | Purpose |
| --- | --- |
| `SE4_SERVER_NAME` | Name shown in the server browser |
| `SE4_MAX_PLAYERS` | Player cap (default 12) |
| `SE4_MAP_ROTATION` | Comma-separated `MAP:MODE` pairs, for example `VILLAGE:DM,RIVIERA:DM` |
| `SE4_AUTH_PORT`, `SE4_GAME_PORT`, `SE4_LOBBY_PORT`, `SE4_UPDATE_PORT` | Match `Server.AuthPort` / `Server.GamePort` / `Server.LobbyPort` / `Server.UpdatePort` in `server.cfg` |
| `SE4_FORCE_UPDATE` | Set `true` to reinstall on next start |

A Steam account entitled to Sniper Elite 4 may be required to join or list publicly; set `STEAM_USERNAME` / `STEAM_PASSWORD` (optional `STEAM_GUARD_CODE`) if anonymous install is not enough.

## Docker run

```bash
docker run -d --name sniper-elite-4 --restart unless-stopped --init \
  -p 27000:27000/udp -p 27005:27005/udp -p 27010:27010/tcp -p 27015:27015/udp \
  -v "$PWD/sniper-elite-4/data:/opt/se4" \
  -e SE4_SERVER_NAME="My SE4 Server" \
  {{IMAGE_PREFIX}}/sniper-elite-4:latest
```
