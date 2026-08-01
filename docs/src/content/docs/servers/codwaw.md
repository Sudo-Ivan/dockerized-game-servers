---
title: 'Call of Duty: World at War'
description: Call of Duty World at War dedicated server built from the LinuxGSM 1.7 archive.
---

This image ships with the game server files built in. On first run they are copied into your data folder. You must own Call of Duty: World at War.

:::note[Before you start]
- You must own Call of Duty: World at War
- Keep a data folder for the server install and server.cfg (about 8 GB after the first copy)
- Open UDP port 28960 (or the port you set with CODWAW_PORT, on both host and container)
- Give the container at least 2 GB RAM (the shipped compose file sets 2048M)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 28960 | UDP | Game traffic (CODWAW_PORT) |

If you run more than one Call of Duty family server on one host (cod, cod2, codwaw, and cod4 all default to 28960), change CODWAW_PORT and the matching port mapping so they do not collide.

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| CODWAW_IP | 0.0.0.0 | Bind address |
| CODWAW_PORT | 28960 | Game UDP port, applied on every start |
| CODWAW_MAXPLAYERS | 20 | Max players, applied on every start |
| CODWAW_STARTMAP | mp_castle | Map loaded at boot, applied on every start |
| CODWAW_HOSTNAME | Call of Duty: World at War Server | Server browser name, written into server.cfg only when that file is first created |
| CODWAW_EXTRA_ARGS | (empty) | Extra launch flags appended to the start command |

CODWAW_IP, CODWAW_PORT, CODWAW_MAXPLAYERS, and CODWAW_STARTMAP take effect on the next restart. CODWAW_HOSTNAME only matters when server.cfg is generated for the first time. To change the name later, edit server.cfg or delete it and let the container recreate it.

## Data folder

Your data folder mounts to /opt/codwaw inside the container. On first start (or if key files are missing), the container copies the built-in server files into that folder.

server.cfg is created once if it does not exist:

```text
set sv_hostname "<CODWAW_HOSTNAME>"
set rcon_password "changeme"
set g_allowvote 1
```

The default rcon password is changeme and there is no setting to change it at create time. Edit codwaw/data/server.cfg on the host with the container stopped to change the rcon password, voting, or other options. Your edits persist because an existing server.cfg is never overwritten.

Punkbuster is disabled (sv_punkbuster 0) and com_hunkMegs is fixed at 128.

## Updates

There is no one-command update for this server. Use [backup and restore](../guides/ops/) to protect your data. To pick up a newer game archive, change the build settings in the Dockerfile and rebuild the image.

## Health check

The container reports healthy while the game server process is running. Startup gets a 120 second grace period.

## Compose

```bash
docker compose -f codwaw/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name codwaw --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/codwaw/data:/opt/codwaw" \
  -e CODWAW_PORT=28960 \
  -e CODWAW_MAXPLAYERS=20 \
  -e CODWAW_STARTMAP=mp_castle \
  -e CODWAW_HOSTNAME="Call of Duty: World at War Server" \
  {{IMAGE_PREFIX}}/codwaw:latest
```
