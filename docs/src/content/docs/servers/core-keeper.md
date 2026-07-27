---
title: Core Keeper
description: Core Keeper dedicated server with Steam Datagram Relay.
---

Compose path: core-keeper. Image: core-keeper.

## Defaults

Defaults to Steam Datagram Relay (SDR). No published ports are required. World data lives under core-keeper/data/.

When the session is ready, `docker logs` prints a colored **Game ID** line and:

```text
Status: server is up and ready for players!
```

Example:

```bash
docker logs core-keeper
```

Fallback if you need the file directly:

```bash
docker exec -it core-keeper cat /opt/corekeeper/server/GameID.txt
```

For direct connect, set SERVER_PORT and publish that UDP port.

Force a Steam reinstall on next recreate with `CK_FORCE_UPDATE=true` (or `./tools/gs update core-keeper`). See [Ops](../guides/ops/).

## Compose

```bash
docker compose -f core-keeper/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name core-keeper --restart unless-stopped --init \
  -v "$PWD/core-keeper/data:/opt/corekeeper" \
  {{IMAGE_PREFIX}}/core-keeper:latest
```
