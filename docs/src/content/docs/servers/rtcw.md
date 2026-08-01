---
title: Return to Castle Wolfenstein
description: Return to Castle Wolfenstein dedicated server built from the LinuxGSM ioRTCW archive.
---

This image ships with the game server files built in. On first run they are copied into your data folder. You must own Return to Castle Wolfenstein.

:::note[Before you start]
- You must own Return to Castle Wolfenstein
- Keep a data folder for the server install and main/server.cfg
- Open UDP port 27960 (or the port you set with RTCW_PORT, on both host and container)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27960 | UDP | Game traffic (RTCW_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| RTCW_IP | 0.0.0.0 | Bind address |
| RTCW_PORT | 27960 | Game UDP port, applied on every start |
| RTCW_MAXPLAYERS | 32 | Max players, written into server.cfg only when that file is first created |
| RTCW_STARTMAP | mp_beach | Map loaded at boot, applied on every start |
| RTCW_HOSTNAME | Return to Castle Wolfenstein Server | Server browser name, written into server.cfg only when that file is first created |
| RTCW_EXTRA_ARGS | (empty) | Extra launch flags appended to the start command |

Unlike the Call of Duty guides here, max players is not passed on the command line. RTCW_MAXPLAYERS only matters when main/server.cfg is generated for the first time. The same applies to RTCW_HOSTNAME. RTCW_IP, RTCW_PORT, and RTCW_STARTMAP take effect on every start.

## Data folder

Your data folder mounts to /opt/rtcw inside the container. On first start (or if key files are missing), the container copies the built-in server files into that folder.

main/server.cfg is created once if it does not exist:

```text
set sv_hostname "<RTCW_HOSTNAME>"
set rcon_password "changeme"
set g_allowvote 1
set sv_maxclients <RTCW_MAXPLAYERS>
```

The default rcon password is changeme. Edit rtcw/data/main/server.cfg on the host with the container stopped to change the rcon password, max clients, or other options. Your edits persist because an existing server.cfg is never overwritten.

The copied tree also includes a Punkbuster folder from the ioRTCW release. Punkbuster is disabled at launch (sv_punkbuster 0).

## Updates

There is no one-command update for this server. Use [backup and restore](../guides/ops/) to protect your data. To pick up a newer game archive, change the build settings in the Dockerfile and rebuild the image.

## Health check

The container reports healthy while the game server process is running. Startup gets a 120 second grace period.

## Compose

```bash
docker compose -f rtcw/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name rtcw --restart unless-stopped --init \
  -p 27960:27960/udp \
  -v "$PWD/rtcw/data:/opt/rtcw" \
  -e RTCW_PORT=27960 \
  -e RTCW_MAXPLAYERS=32 \
  -e RTCW_STARTMAP=mp_beach \
  -e RTCW_HOSTNAME="Return to Castle Wolfenstein Server" \
  {{IMAGE_PREFIX}}/rtcw:latest
```
