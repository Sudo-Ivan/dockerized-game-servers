---
title: Call of Duty
description: Call of Duty (2003) dedicated server built from the LinuxGSM 1.5b archive.
---

This image ships with the game server files built in. On first run they are copied into your data folder. You must own Call of Duty.

:::note[Before you start]
- You must own Call of Duty
- Keep a data folder for the server install and server.cfg
- Open UDP port 28960 (or the port you set with COD_PORT, on both host and container)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 28960 | UDP | Game traffic (COD_PORT) |

If you run more than one Call of Duty family server on one host (cod, cod2, codwaw, and cod4 all default to 28960), change COD_PORT and the matching port mapping so they do not collide.

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| COD_IP | 0.0.0.0 | Bind address |
| COD_PORT | 28960 | Game UDP port, applied on every start |
| COD_MAXPLAYERS | 20 | Max players, applied on every start |
| COD_STARTMAP | mp_neuville | Map loaded at boot, applied on every start |
| COD_HOSTNAME | Call of Duty Server | Server browser name, written into server.cfg only when that file is first created |
| COD_EXTRA_ARGS | (empty) | Extra launch flags appended to the start command |

COD_IP, COD_PORT, COD_MAXPLAYERS, and COD_STARTMAP take effect on the next restart. COD_HOSTNAME only matters when server.cfg is generated for the first time. To change the name later, edit server.cfg or delete it and let the container recreate it.

## Data folder

Your data folder mounts to /opt/cod inside the container. On first start (or if key files are missing), the container copies the built-in server files into that folder.

server.cfg is created once if it does not exist:

```text
set sv_hostname "<COD_HOSTNAME>"
set rcon_password "changeme"
set g_allowvote 1
```

The default rcon password is changeme and there is no setting to change it at create time. Edit cod/data/server.cfg on the host with the container stopped to change the rcon password, voting, or other options. Your edits persist because an existing server.cfg is never overwritten.

Punkbuster is disabled (sv_punkbuster 0) because Punkbuster master servers for this game are no longer available.

## Updates

There is no one-command update for this server. Use [backup and restore](../guides/ops/) to protect your data. To pick up a newer game archive, change the build settings in the Dockerfile and rebuild the image.

## Health check

The container reports healthy while the game server process is running. Startup gets a 120 second grace period.

## Compose

```bash
docker compose -f cod/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cod --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/cod/data:/opt/cod" \
  -e COD_PORT=28960 \
  -e COD_MAXPLAYERS=20 \
  -e COD_STARTMAP=mp_neuville \
  -e COD_HOSTNAME="Call of Duty Server" \
  {{IMAGE_PREFIX}}/cod:latest
```
