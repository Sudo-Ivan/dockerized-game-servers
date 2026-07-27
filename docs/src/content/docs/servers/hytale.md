---
title: Hytale
description: Hytale dedicated server via the external deinfreu/hytale-server image, not built by this repository.
---

Compose path: `hytale`. Container: `hytale-server`. Image: `deinfreu/hytale-server:latest`.

This is the only stack in the repository with no local build. There is no `Dockerfile`, `entrypoint.sh`, or `healthcheck.sh` under `hytale/`, only a `docker-compose.yml` that pulls a third-party image. The catalog marks this server `first_party=0`, so most of the tooling documented on [Ops](/guides/ops/) and [Quick start](/guides/quick-start/) behaves differently here, read the notes below before assuming parity with the first-party servers on this site.

:::note[Requirements]
- Persist `./data` at `/home/container`
- Bind mount `/etc/machine-id` read-only into the container, the upstream image expects it
- Publish UDP **5520**
- No local build, no update tooling, and no healthcheck, everything comes from the upstream image
:::

## First-party vs external

Everything in the compose file's `environment:` block is exactly what the upstream `deinfreu/hytale-server` image expects, this repository does not build, patch, or validate it:

- No `Dockerfile` exists here, and `hytale/docker-compose.yml` has no `build:` section, so `docker compose up --build` has nothing to build
- No `HEALTHCHECK`. The catalog lists the healthcheck kind as `none`, and `docker inspect` reports no health status for this container
- No update environment variable is registered in `ci/server-catalog.sh` (it lists `-` for `update_envs`), so `./tools/gs update hytale` fails with an explicit "no update_envs" error. Update by pulling a new tag instead
- `./tools/gs backup hytale` and `./tools/gs restore hytale <archive>` still work, since the catalog does list a `data` volume for this server and the backup/restore commands only need a volume list, not a first-party build

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 5520 | UDP | Game port (`SERVER_PORT`) |

## Environment

These are the variables already wired in `hytale/docker-compose.yml`. The upstream image may support more, check its [Docker Hub page](https://hub.docker.com/r/deinfreu/hytale-server) for anything not listed here.

| Variable | Default | Purpose |
| --- | --- | --- |
| `SERVER_IP` | `0.0.0.0` | Bind address for the game port |
| `SERVER_PORT` | `5520` | Game UDP port |
| `PROD` | `FALSE` | Upstream production-mode flag |
| `DEBUG` | `FALSE` | Upstream debug logging flag |
| `TZ` | `Europe/Amsterdam` | Container timezone |

## Data volume

Mount `hytale/data` at `/home/container`. This repository does not document an internal file layout for that path since the server binary and its data format are entirely controlled by the upstream image.

## Compose

```bash
docker compose -f hytale/docker-compose.yml up -d
```

The compose file also sets `tty: true` and `stdin_open: true`, so you can attach an interactive console with `docker attach hytale-server` (detach with `Ctrl-p Ctrl-q`, do not use `Ctrl-c`, which would stop the server).

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

## Updates

Pull a newer tag and recreate the container, there is no version pin or force-update variable for this stack:

```bash
docker compose -f hytale/docker-compose.yml pull
docker compose -f hytale/docker-compose.yml up -d
```
