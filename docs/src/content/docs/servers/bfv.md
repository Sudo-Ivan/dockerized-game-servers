---
title: Battlefield Vietnam
description: Battlefield Vietnam dedicated server (LinuxGSM bundle).
---

Compose path: `bfv`. Image: `bfv`.

Linux dedicated files seed into `bfv/data` from the image on first start. Comply with EA licensing for Battlefield Vietnam.

## Ports

- UDP **4755** (game)
- UDP **27900** (query)

## Configuration

| Variable | Purpose |
| --- | --- |
| `BFV_EXTRA_ARGS` | Extra `+` arguments for the dedicated binary |

## Compose

```bash
docker compose -f bfv/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name bfv --restart unless-stopped --init \
  -p 4755:4755/udp -p 27900:27900/udp \
  -v "$PWD/bfv/data:/opt/bfv" \
  {{IMAGE_PREFIX}}/bfv:latest
```
