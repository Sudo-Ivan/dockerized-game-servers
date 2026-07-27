---
title: Call of Duty
description: Call of Duty dedicated server (LinuxGSM bundle).
---

Compose path: `cod`. Image: `cod`.

Linux dedicated server files seed from the image into `cod/data`. Comply with Activision licensing.

## Ports

UDP **28960** (`COD_PORT`).

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `COD_PORT` | `28960` | Game port |
| `COD_MAXPLAYERS` | `20` | Player cap |
| `COD_STARTMAP` | `mp_neuville` | First map |
| `COD_HOSTNAME` | `Call of Duty Server` | Browser name |
| `COD_EXTRA_ARGS` | empty | Extra `+` arguments |

`server.cfg` is created on first start if missing.

## Compose

```bash
docker compose -f cod/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cod --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/cod/data:/opt/cod" \
  {{IMAGE_PREFIX}}/cod:latest
```
