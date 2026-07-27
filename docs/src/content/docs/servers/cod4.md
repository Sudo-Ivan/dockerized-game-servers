---
title: Call of Duty 4
description: Call of Duty 4 dedicated server (CoD4x LinuxGSM bundle).
---

Compose path: `cod4`. Image: `cod4`.

CoD4x Linux dedicated binary seeds into `cod4/data` on first start.

## Ports

UDP **28960** (`COD4_PORT`).

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `COD4_PORT` | `28960` | Game port |
| `COD4_MAXPLAYERS` | `32` | Player cap |
| `COD4_STARTMAP` | `mp_crossfire` | First map |
| `COD4_HOSTNAME` | `Call of Duty 4 Server` | Browser name |

## Compose

```bash
docker compose -f cod4/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cod4 --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/cod4/data:/opt/cod4" \
  {{IMAGE_PREFIX}}/cod4:latest
```

Edit `cod4/data/server.cfg` after first start for rcon and rules.
