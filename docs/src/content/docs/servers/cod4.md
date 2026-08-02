---
title: Call of Duty 4
description: Call of Duty 4 dedicated server via CoD4x, built from the LinuxGSM archive.
---

This image ships with a CoD4x game server built in. On first run the files are copied into your data folder. You must own Call of Duty 4.

:::note[Before you start]
- You must own Call of Duty 4
- Keep a data folder for the server install and server.cfg
- Open UDP port 28960 (or the port you set with COD4_PORT, on both host and container)
- Give the container at least 2 GB RAM (the shipped compose file sets 2048M)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 28960 | UDP | Game traffic (COD4_PORT) |

If you run more than one Call of Duty family server on one host (dockerized/cod, dockerized/cod2, dockerized/codwaw, and dockerized/cod4 all default to 28960), change COD4_PORT and the matching port mapping so they do not collide.

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| COD4_IP | 0.0.0.0 | Bind address |
| COD4_PORT | 28960 | Game UDP port, applied on every start |
| COD4_MAXPLAYERS | 32 | Max players, applied on every start |
| COD4_STARTMAP | mp_crossfire | Map loaded at boot, applied on every start |
| COD4_HOSTNAME | Call of Duty 4 Server | Server browser name, written into server.cfg only when that file is first created |
| COD4_EXTRA_ARGS | (empty) | Extra launch flags appended to the start command |

COD4_IP, COD4_PORT, COD4_MAXPLAYERS, and COD4_STARTMAP take effect on the next restart. COD4_HOSTNAME only matters when server.cfg is generated for the first time. To change the name later, edit server.cfg or delete it and let the container recreate it.

The launcher always sets LAN-style auth (sv_authorizemode -1), disables Punkbuster, and points both fs_basepath and fs_homepath at the data folder.

## Data folder

Your data folder mounts to /opt/cod4 inside the container. On first start (or if key files are missing), the container copies the built-in server files into that folder.

server.cfg is created once if it does not exist:

```text
set sv_hostname "<COD4_HOSTNAME>"
set rcon_password "changeme"
```

Unlike the other Call of Duty guides here, the generated config does not set g_allowvote. The default rcon password is changeme. Edit dockerized/cod4/data/server.cfg on the host with the container stopped to change the rcon password or add other options. Your edits persist because an existing server.cfg is never overwritten.

## Updates

There is no one-command update for this server. Use [backup and restore](../guides/ops/) to protect your data. To pick up a newer game archive, change the build settings in the Dockerfile and rebuild the image.

## Health check

The container reports healthy while the CoD4x server process is running. Startup gets a 120 second grace period.

## Compose

```bash
docker compose -f dockerized/cod4/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cod4 --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/dockerized/cod4/data:/opt/cod4" \
  -e COD4_PORT=28960 \
  -e COD4_MAXPLAYERS=32 \
  -e COD4_STARTMAP=mp_crossfire \
  -e COD4_HOSTNAME="Call of Duty 4 Server" \
  {{IMAGE_PREFIX}}/cod4:latest
```
