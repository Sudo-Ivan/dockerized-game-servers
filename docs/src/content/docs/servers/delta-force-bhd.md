---
title: Delta Force Black Hawk Down
description: Delta Force Black Hawk Down multiplayer host via Wine, BYO game files.
---

There is no official Steam dedicated server for Delta Force: Black Hawk Down. This image runs the Windows game binary you supply under Wine with a virtual display for headless hosting.

:::note[Before you start]
- Copy your owned Windows game files into the data folder so dfbhd.exe exists at the root
- Open UDP port 3568
- You must supply the game from a disc install or Steam library backup you own
- Community multiplayer may need external NovaHQ heartbeat tools (for example HawkSync) outside this container
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 3568 | UDP | Default multiplayer port |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| BHD_EXTRA_ARGS | (empty) | Extra arguments passed to the game after launch |

Wine prefix and paths are fixed inside the image.

## Data folder

Your data folder mounts at /opt/dfbhd inside the container.

| Path | Purpose |
| --- | --- |
| dfbhd.exe | Required Windows game binary. Copy this in before first start |
| Game data files | Maps, assets, and other files from your owned install |
| .wine/ | Wine prefix, created on first start |

## Updates

There is no Steam download or auto-update path. Replace game files in the data folder when you upgrade your install.

## Health check

The container reports healthy while the game process is running. Startup gets a 300 second grace period.

## Compose

```bash
docker compose -f dockerized/delta-force-bhd/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name delta-force-bhd --restart unless-stopped --init \
  -p 3568:3568/udp \
  -v "$PWD/dockerized/delta-force-bhd/data:/opt/dfbhd" \
  -e BHD_EXTRA_ARGS="" \
  {{IMAGE_PREFIX}}/delta-force-bhd:latest
```
