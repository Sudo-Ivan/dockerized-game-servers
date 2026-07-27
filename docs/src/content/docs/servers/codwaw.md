---
title: Call of Duty World at War
description: Call of Duty World at War dedicated server (LinuxGSM bundle).
---

Compose path: `codwaw`. Image: `codwaw`.

Seeds dedicated files into `codwaw/data` on first start.

## Ports

UDP **28960** (default game port in compose).

## Configuration

`CODWAW_PORT`, `CODWAW_MAXPLAYERS`, `CODWAW_STARTMAP`, `CODWAW_HOSTNAME`, `CODWAW_EXTRA_ARGS`.

## Compose

```bash
docker compose -f codwaw/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name codwaw --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/codwaw/data:/opt/codwaw" \
  {{IMAGE_PREFIX}}/codwaw:latest
```
