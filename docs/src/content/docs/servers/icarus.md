---
title: Icarus
description: Icarus dedicated server (Windows binary via Wine).
---

Compose path: icarus. Image: icarus.

## Behavior

Downloads the Windows dedicated server (Steam App 2089300) via SteamCMD and runs it under Wine. Data volume: `icarus/data` mounted at `/opt/icarus` (includes game files and `.wine`).

- Game: UDP 17777 (`ICARUS_PORT`)
- Query: UDP 27015 (`ICARUS_QUERY_PORT`)
- Default mode: `Prospect` (`ICARUS_GAME_MODE`)
- Updates: `ICARUS_FORCE_UPDATE=true` or `./tools/gs update icarus`
- Allocate at least 8 GB RAM

## Docker run

```bash
docker run -d --name icarus --restart unless-stopped --init \
  -p 17777:17777/udp -p 27015:27015/udp \
  -v "$PWD/icarus/data:/opt/icarus" \
  -e ICARUS_SESSION_NAME="My Prospect" \
  -e ICARUS_GAME_MODE=Prospect \
  {{IMAGE_PREFIX}}/icarus:latest
```

## Environment

| Variable | Purpose |
| --- | --- |
| `ICARUS_GAME_MODE` | `Prospect`, `Outpost`, or `OpenWorld` |
| `ICARUS_SESSION_NAME` | Session name shown to players |
| `ICARUS_MAX_PLAYERS` | Player cap (default 8) |
| `ICARUS_ADMIN_PASSWORD` | Admin password when supported by mode |
| `ICARUS_EXTRA_ARGS` | Extra flags passed to the server binary |

Only one service on the host should bind UDP 27015 unless you change `ICARUS_QUERY_PORT` and the published port mapping.
