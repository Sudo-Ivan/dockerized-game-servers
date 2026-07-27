---
title: Palworld
description: Palworld dedicated server via SteamCMD.
---

Compose path: palworld. Image: palworld.

## Behavior

Downloads the Linux dedicated server (Steam App 2394010) on first start. World and settings appear under `palworld/data/Pal/Saved/` after the first run.

- Game: UDP 8211 (`PALWORLD_PORT`)
- Set `PALWORLD_PLAYERS` for the player cap passed to `PalServer.sh`
- Allocate at least 8 GB container memory for stable runs
- Updates: `PALWORLD_FORCE_UPDATE=true` or `./tools/gs update palworld`

Edit `Pal/Saved/Config/LinuxServer/PalWorldSettings.ini` in the data volume for server name, passwords, and rates.

## Compose

```bash
docker compose -f palworld/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name palworld --restart unless-stopped --init \
  -p 8211:8211/udp \
  -v "$PWD/palworld/data:/opt/palworld" \
  {{IMAGE_PREFIX}}/palworld:latest
```
