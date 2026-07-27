---
title: Project Zomboid
description: Project Zomboid dedicated server via SteamCMD.
---

Compose path: project-zomboid. Image: project-zomboid.

## Behavior

Downloads the Linux dedicated server (Steam App 380870) on first start. Server files are under `data/server`. Saves and `.ini` configs are under `data/home/Zomboid/` because `HOME` points at `data/home`.

- Game: UDP 16261 and 16262
- Set `PZ_ADMIN_PASSWORD` before first start (compose uses this for `-adminpassword` on first launch)
- `PZ_SERVER_NAME` selects the server profile (default `servertest`)
- GOG or non-Steam clients: set `PZ_NO_STEAM=true`
- Updates: `PZ_FORCE_UPDATE=true` or `./tools/gs update project-zomboid`

## Docker run

```bash
docker run -d --name project-zomboid --restart unless-stopped --init \
  -p 16261:16261/udp -p 16262:16262/udp \
  -v "$PWD/project-zomboid/data:/opt/zomboid" \
  -e PZ_ADMIN_PASSWORD=changeme \
  {{IMAGE_PREFIX}}/project-zomboid:latest
```
