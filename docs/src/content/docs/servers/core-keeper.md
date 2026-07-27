---
title: Core Keeper
description: Core Keeper dedicated server with Steam Datagram Relay.
---

Compose path: core-keeper. Image: core-keeper.

## Defaults

Defaults to Steam Datagram Relay (SDR). No published ports are required. World data lives under core-keeper/data/.

After start, read the game ID:

```bash
docker exec -it core-keeper cat /opt/corekeeper/server/GameID.txt
```

For direct connect, set SERVER_PORT and publish that UDP port.

## Docker run

```bash
docker run -d --name core-keeper --restart unless-stopped --init \
  -v "$PWD/core-keeper/data:/opt/corekeeper" \
  {{IMAGE_PREFIX}}/core-keeper:latest
```
