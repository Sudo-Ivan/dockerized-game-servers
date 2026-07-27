---
title: Sons Of The Forest
description: Sons Of The Forest dedicated server (Windows binary via Wine).
---

Compose path: sons-of-the-forest. Image: sons-of-the-forest.

Downloads the dedicated server tool (Steam App 2465200) via SteamCMD and runs `SonsOfTheForestDS.exe` under Wine. All UDP: 8766 (game), 27016 (query), 9700 (BlobSync). Data volume: `sons-of-the-forest/data` mounted at `/opt/sotf` (includes `.wine` and `userdata`).

## Behavior

`dedicatedserver.cfg` (JSON) is generated under `sons-of-the-forest/data/userdata/` from the environment variables below on first start, and left alone afterward. Edit it directly for settings not exposed as env vars (for example `GameSettings` or `CustomGameModeSettings`). `ownerswhitelist.txt` is created empty in the same directory: add one SteamID per line to grant in-game admin.

## Environment

| Variable | Purpose |
| --- | --- |
| `SOTF_SERVER_NAME` | Name shown in the server list |
| `SOTF_MAX_PLAYERS` | Player cap, 1-8 (default 8) |
| `SOTF_PASSWORD` | Join password, empty for open |
| `SOTF_LAN_ONLY` | Set `true` to hide from the public list (also skips the port-reachability self-test) |
| `SOTF_SAVE_SLOT`, `SOTF_SAVE_MODE` | `new` or `continue`; `continue` creates the slot if missing |
| `SOTF_GAME_MODE` | `normal`, `hard`, `hardsurvival`, `peaceful`, or `custom` |
| `SOTF_SAVE_INTERVAL` | Autosave interval in seconds (default 600) |
| `SOTF_FORCE_UPDATE` | Set `true` to reinstall on next start |

## Docker run

```bash
docker run -d --name sons-of-the-forest --restart unless-stopped --init \
  -p 8766:8766/udp -p 27016:27016/udp -p 9700:9700/udp \
  -v "$PWD/sons-of-the-forest/data:/opt/sotf" \
  -e SOTF_SERVER_NAME="My SOTF Server" \
  {{IMAGE_PREFIX}}/sons-of-the-forest:latest
```

Allocate at least 6 GB RAM. First start can take several minutes to install through Wine.
