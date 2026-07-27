---
title: Quake III Arena
description: Quake III Arena dedicated server (ioquake3-based).
iconFit: contain
---

Compose path: `quake3`. Image: `quake3`.

Legacy FPS dedicated server using the Linux binary seeded in the image. Persist `quake3/data` at `/opt/quake3` for configs and optional pk3 overrides.

## Ports

- UDP **27960** (`Q3_PORT`)

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `Q3_PORT` | `27960` | Game port |
| `Q3_STARTMAP` | `q3dm17` | Map loaded at startup |
| `Q3_HOSTNAME` | `Quake 3 Arena Server` | Server browser name |

The entrypoint writes `server.cfg` on first start if missing. Edit `quake3/data/server.cfg` for rcon, timelimit, and rotation.

## Compose

```bash
docker compose -f quake3/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name quake3 --restart unless-stopped --init \
  -p 27960:27960/udp \
  -v "$PWD/quake3/data:/opt/quake3" \
  {{IMAGE_PREFIX}}/quake3:latest
```
