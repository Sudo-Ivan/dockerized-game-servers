---
title: Hytale
description: Hytale dedicated server via the external deinfreu/hytale-server image, not built by this repository.
---

This stack runs a Hytale dedicated server using the third-party deinfreu/hytale-server image. There is no Dockerfile or server binary built in this repository. The compose file pulls the upstream image as-is.

:::note[Before you start]
- Keep a data folder for the server
- Bind mount /etc/machine-id read-only into the container. The upstream image expects it
- Open UDP port 5520
- There is no local build, no update tooling, and no health check. Everything comes from the upstream image
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 5520 | UDP | Game port (SERVER_PORT) |

## Settings

These are the variables wired in hytale/docker-compose.yml. The upstream image may support more. Check its [Docker Hub page](https://hub.docker.com/r/deinfreu/hytale-server) for anything not listed here.

| Setting | Default | What it does |
| --- | --- | --- |
| SERVER_IP | 0.0.0.0 | Bind address for the game port |
| SERVER_PORT | 5520 | Game UDP port |
| PROD | FALSE | Upstream production-mode flag |
| DEBUG | FALSE | Upstream debug logging flag |
| TZ | Europe/Amsterdam | Container timezone |

## Data folder

Mount hytale/data at /home/container. The internal file layout is controlled entirely by the upstream image.

## Updates

./tools/gs update hytale is not available. Pull a newer tag and recreate the container instead:

```bash
docker compose -f hytale/docker-compose.yml pull
docker compose -f hytale/docker-compose.yml up -d
```

./tools/gs backup hytale and restore do work since the catalog lists a data volume. See [Ops](/guides/ops/).

## Compose

```bash
docker compose -f hytale/docker-compose.yml up -d
```

The compose file also sets tty and stdin_open so you can attach an interactive console with docker attach hytale-server. Detach with Ctrl-p Ctrl-q (do not use Ctrl-c, which would stop the server).

## Docker run

```bash
docker run -d --name hytale-server --restart unless-stopped --init \
  -p 5520:5520/udp \
  -v "$PWD/hytale/data:/home/container" \
  -v /etc/machine-id:/etc/machine-id:ro \
  -e SERVER_IP=0.0.0.0 \
  -e SERVER_PORT=5520 \
  -e PROD=FALSE \
  -e DEBUG=FALSE \
  -e TZ=Europe/Amsterdam \
  deinfreu/hytale-server:latest
```
