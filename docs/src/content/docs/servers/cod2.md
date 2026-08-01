---
title: Call of Duty 2
description: Call of Duty 2 dedicated server built from the LinuxGSM 1.3 archive.
---

This image ships with the game server files built in. On first run they are copied into your data folder. You must own Call of Duty 2.

:::note[Before you start]
- You must own Call of Duty 2
- Keep a data folder for the server install and server.cfg (several GB after the first copy)
- Open UDP port 28960 (or the port you set with COD2_PORT, on both host and container)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 28960 | UDP | Game traffic (COD2_PORT) |

If you run more than one Call of Duty family server on one host (cod, cod2, codwaw, and cod4 all default to 28960), change COD2_PORT and the matching port mapping so they do not collide.

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| COD2_IP | 0.0.0.0 | Bind address |
| COD2_PORT | 28960 | Game UDP port, applied on every start |
| COD2_MAXPLAYERS | 20 | Max players, applied on every start |
| COD2_STARTMAP | mp_leningrad | Map loaded at boot, applied on every start |
| COD2_HOSTNAME | Call of Duty 2 Server | Server browser name, written into server.cfg only when that file is first created |
| COD2_EXTRA_ARGS | (empty) | Extra launch flags appended to the start command |

COD2_IP, COD2_PORT, COD2_MAXPLAYERS, and COD2_STARTMAP take effect on the next restart. COD2_HOSTNAME only matters when server.cfg is generated for the first time. To change the name later, edit server.cfg or delete it and let the container recreate it.

## Data folder

Your data folder mounts to /opt/cod2 inside the container. On first start (or if key files are missing), the container copies the built-in server files into that folder.

server.cfg is created once if it does not exist:

```text
set sv_hostname "<COD2_HOSTNAME>"
set rcon_password "changeme"
set g_allowvote 1
```

The default rcon password is changeme and there is no setting to change it at create time. Edit cod2/data/server.cfg on the host with the container stopped to change the rcon password, voting, or other options. Your edits persist because an existing server.cfg is never overwritten.

Punkbuster is disabled (sv_punkbuster 0).

## Updates

There is no one-command update for this server. Use [backup and restore](../guides/ops/) to protect your data. To pick up a newer game archive, change the build settings in the Dockerfile and rebuild the image.

## Health check

The container reports healthy while the game server process is running. Startup gets a 120 second grace period.

## Compose

```bash
docker compose -f cod2/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cod2 --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/cod2/data:/opt/cod2" \
  -e COD2_PORT=28960 \
  -e COD2_MAXPLAYERS=20 \
  -e COD2_STARTMAP=mp_leningrad \
  -e COD2_HOSTNAME="Call of Duty 2 Server" \
  {{IMAGE_PREFIX}}/cod2:latest
```
