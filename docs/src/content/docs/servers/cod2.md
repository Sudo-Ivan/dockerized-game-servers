---
title: Call of Duty 2
description: Call of Duty 2 dedicated server (LinuxGSM bundle).
---

Compose path: `cod2`. Image: `cod2`.

Seeds Linux dedicated files into `cod2/data` on first start.

## Ports

UDP **28960** (see compose for published port).

## Configuration

Same pattern as Call of Duty: `COD2_PORT`, `COD2_MAXPLAYERS`, `COD2_STARTMAP`, `COD2_HOSTNAME`, `COD2_EXTRA_ARGS`.

## Compose

```bash
docker compose -f cod2/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cod2 --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/cod2/data:/opt/cod2" \
  {{IMAGE_PREFIX}}/cod2:latest
```
