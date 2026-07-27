---
title: Factorio
description: Factorio dedicated headless server.
---

Compose path: factorio. Image: factorio.

## Behavior

Downloads the official headless package from factorio.com. FACTORIO_VERSION defaults to stable. Creates saves/SAVE_NAME.zip on first start and writes config/server-settings.json if missing.

- Game traffic: UDP 34197
- RCON: set RCON_PASSWORD to enable RCON on TCP 27015
- Edit settings under factorio/data/config/ after the first run

## Docker run

```bash
docker run -d --name factorio --restart unless-stopped --init \
  -p 34197:34197/udp -p 27015:27015/tcp \
  -v "$PWD/factorio/data:/opt/factorio" \
  -e RCON_PASSWORD=changeme \
  {{IMAGE_PREFIX}}/factorio:latest
```
