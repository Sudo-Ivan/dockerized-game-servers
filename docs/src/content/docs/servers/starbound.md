---
title: Starbound
description: Starbound dedicated server via SteamCMD.
---

Compose path: starbound. Image: starbound.

## Behavior

Downloads the Linux dedicated server (Steam App 211820) on first start. Config and universe data live under `starbound/data`.

- Game: TCP 21025 (`STARBOUND_PORT`)
- Writes `starbound_server.config` on first start if missing
- Updates: `STARBOUND_FORCE_UPDATE=true` or `./tools/gs update starbound`

## Docker run

```bash
docker run -d --name starbound --restart unless-stopped --init \
  -p 21025:21025/tcp \
  -v "$PWD/starbound/data:/opt/starbound" \
  {{IMAGE_PREFIX}}/starbound:latest
```
