---
title: Battlefield Vietnam
description: Battlefield Vietnam dedicated server built from the LinuxGSM v1.21 archive.
---

This image ships with the game server files built in. On first run they are copied into your data folder. You must own Battlefield Vietnam.

:::note[Before you start]
- You must own Battlefield Vietnam
- Keep a data folder for the server install and any config you edit
- Open UDP ports 4755 and 27900
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 4755 | UDP | Game traffic (fixed, no setting to change it) |
| 27900 | UDP | Query and status port (fixed) |

Neither port can be changed with an environment variable.

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| BFV_EXTRA_ARGS | (empty) | Extra flags appended to the start command |

This is the only setting the container reads. There are no hostname, map, or player-count options. Everything else comes from config files inside the data folder or from flags you add through BFV_EXTRA_ARGS.

## Data folder

Your data folder mounts to /opt/bfv inside the container. On first start (or if key files are missing), the container copies the built-in server files into that folder and marks the copy as complete. After that it leaves the folder alone.

There is no generated server.cfg. Hostname, map rotation, player count, and rcon all live in config files inside the copied tree. Edit them on the host with the container stopped.

Do not delete the completion marker or start script unless you want to wipe your config changes and start from the built-in copy again.

## Updates

There is no one-command update for this server. Use [backup and restore](../guides/ops/) to protect your data. To pick up a newer game archive, change the build settings in the Dockerfile and rebuild the image.

## Health check

The container reports healthy while the game server process is running. Startup gets a 180 second grace period.

## Compose

```bash
docker compose -f bfv/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name bfv --restart unless-stopped --init \
  -p 4755:4755/udp -p 27900:27900/udp \
  -v "$PWD/bfv/data:/opt/bfv" \
  -e BFV_EXTRA_ARGS="" \
  {{IMAGE_PREFIX}}/bfv:latest
```
