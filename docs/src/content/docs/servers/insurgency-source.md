---
title: Insurgency Source
description: Insurgency (2014) Source dedicated server via SteamCMD.
---

Compose path: insurgency-source. Image: insurgency-source.

## Behavior

Downloads the Linux dedicated server (Steam App 237410) on first start. Data volume: `insurgency-source/data` mounted at `/opt/insurgency-source`.

- Game: TCP and UDP 27015, UDP 27016 (`INS_SOURCE_CLIENT_PORT`)
- Default map: `ministry` (`INS_SOURCE_STARTMAP`)
- Game config under `insurgency-source/data/insurgency/cfg/` after first run
- Updates: `INS_SOURCE_FORCE_UPDATE=true` or `./tools/gs update insurgency-source`

SteamCMD may require an account that owns the game for some installs. Set `STEAM_USERNAME`, `STEAM_PASSWORD`, and optional `STEAM_GUARD_CODE` in compose when anonymous login fails.

## Compose

```bash
docker compose -f insurgency-source/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name insurgency-source --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27016:27016/udp \
  -v "$PWD/insurgency-source/data:/opt/insurgency-source" \
  {{IMAGE_PREFIX}}/insurgency-source:latest
```
