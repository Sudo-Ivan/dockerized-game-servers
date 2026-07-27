---
title: The Forest
description: The Forest dedicated server (native Linux via SteamCMD).
---

Compose path: the-forest. Image: the-forest.

Steam App 556450 (native Linux dedicated server, no Wine required). UDP/TCP 8766 (Steam), 27015 (game), 27016 (query). Volume `the-forest/data` at `/opt/theforest`, including save data and the Unity config directory (`home/.config/unity3d/SKS/TheForestDedicatedServer/ds/`).

## Defaults

- `FOREST_SERVER_NAME`, `FOREST_MAX_PLAYERS` (default 8)
- `FOREST_DIFFICULTY`: `Peaceful`, `Normal`, or `Hard`
- `FOREST_INIT_TYPE`: `New` or `Continue` (default `Continue` so restarts do not wipe the save)
- `FOREST_SLOT` (1-5), `FOREST_AUTOSAVE_INTERVAL` (minutes)
- `FOREST_PASSWORD`, `FOREST_ADMIN_PASSWORD`, `FOREST_STEAM_ACCOUNT` (game server login token)
- `FOREST_ENABLE_VAC` (default `true`)
- Updates: `FOREST_FORCE_UPDATE=true`

## Docker run

```bash
docker run -d --name the-forest --restart unless-stopped --init \
  -p 8766:8766/tcp -p 8766:8766/udp \
  -p 27015:27015/tcp -p 27015:27015/udp \
  -p 27016:27016/tcp -p 27016:27016/udp \
  -v "$PWD/the-forest/data:/opt/theforest" \
  -e FOREST_SERVER_NAME="My Forest Server" \
  {{IMAGE_PREFIX}}/the-forest:latest
```
