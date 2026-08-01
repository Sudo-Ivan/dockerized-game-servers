---
title: 'Quake 3: Arena'
description: Quake 3 Arena dedicated server built from the LinuxGSM 1.32c archive.
---

This image ships with the game server files built in. On first run they are copied into your data folder. You must own Quake 3 Arena.

:::note[Before you start]
- You must own Quake 3 Arena
- Keep a data folder for the server install and server.cfg
- Open UDP port 27960 (or the port you set with Q3_PORT, on both host and container)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27960 | UDP | Game traffic (Q3_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| Q3_IP | 0.0.0.0 | Bind address |
| Q3_PORT | 27960 | Game UDP port, applied on every start |
| Q3_STARTMAP | q3dm17 | Map loaded at boot, applied on every start |
| Q3_HOSTNAME | Quake 3 Arena Server | Server browser name, written into server.cfg only when that file is first created |
| Q3_EXTRA_ARGS | (empty) | Extra launch flags appended to the start command |

There is no max-players setting. The game default (20) applies unless you set sv_maxclients through Q3_EXTRA_ARGS or server.cfg. Q3_IP, Q3_PORT, and Q3_STARTMAP take effect on the next restart. Q3_HOSTNAME only matters when server.cfg is generated for the first time.

## Data folder

Your data folder mounts to /opt/quake3 inside the container. On first start (or if key files are missing), the container copies the built-in server files into that folder.

server.cfg is created once if it does not exist:

```text
set sv_hostname "<Q3_HOSTNAME>"
set g_allowvote 1
```

There is no rcon password in the generated config, so remote console is disabled until you add one. Edit quake3/data/server.cfg on the host with the container stopped to set an rcon password or other options. Your edits persist because an existing server.cfg is never overwritten.

Punkbuster is disabled (sv_punkbuster 0) and com_hunkMegs is fixed at 32.

## Updates

There is no one-command update for this server. Use [backup and restore](../guides/ops/) to protect your data. To pick up a newer game archive, change the build settings in the Dockerfile and rebuild the image.

## Health check

The container reports healthy while the game server process is running. Startup gets a 120 second grace period.

## Compose

```bash
docker compose -f quake3/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name quake3 --restart unless-stopped --init \
  -p 27960:27960/udp \
  -v "$PWD/quake3/data:/opt/quake3" \
  -e Q3_PORT=27960 \
  -e Q3_STARTMAP=q3dm17 \
  -e Q3_HOSTNAME="Quake 3 Arena Server" \
  {{IMAGE_PREFIX}}/quake3:latest
```
