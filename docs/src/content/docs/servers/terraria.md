---
title: Terraria
description: Terraria official dedicated server via SteamCMD.
---

Compose path: terraria. Image: terraria.

## Behavior

Downloads the dedicated server (Steam App 105600) on first start. Worlds and `serverconfig.txt` live under `terraria/data` at `/opt/terraria`.

- Game: TCP 7777 (default, set `SERVER_PORT` to change)
- First start writes `serverconfig.txt` if missing
- Updates: `TERRARIA_FORCE_UPDATE=true` or `./tools/gs update terraria`

## Docker run

```bash
docker run -d --name terraria --restart unless-stopped --init \
  -p 7777:7777/tcp \
  -v "$PWD/terraria/data:/opt/terraria" \
  {{IMAGE_PREFIX}}/terraria:latest
```
