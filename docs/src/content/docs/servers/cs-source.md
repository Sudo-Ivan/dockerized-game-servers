---
title: Counter-Strike Source
description: Counter-Strike Source dedicated server via SteamCMD.
---

Compose path: cs-source. Image: cs-source.

## Behavior

Downloads the Linux dedicated server (Steam App 232330) on first start. Data volume: `cs-source/data` mounted at `/opt/cs-source`.

- Game: TCP and UDP 27015, UDP 27005 (client)
- Default map: `de_dust2` (`CSS_STARTMAP`)
- Config under `cs-source/data/cstrike/cfg/` after first run
- Public listing: set `CSS_GSLT` (token from [Steam game server management](https://steamcommunity.com/dev/managegameservers), game ID 240)
- Updates: `CSS_FORCE_UPDATE=true` or `./tools/gs update cs-source`

Set `STEAM_USERNAME` / `STEAM_PASSWORD` when anonymous SteamCMD login fails.

## Compose

```bash
docker compose -f cs-source/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cs-source --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27005:27005/udp \
  -v "$PWD/cs-source/data:/opt/cs-source" \
  -e CSS_GSLT="your-gslt" \
  {{IMAGE_PREFIX}}/cs-source:latest
```
