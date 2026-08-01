---
title: Delta Force Black Hawk Down
description: Delta Force Black Hawk Down multiplayer host via Wine, BYO game files.
---

Compose path: delta-force-bhd. Image: delta-force-bhd.

There is no official SteamCMD dedicated server for Delta Force: Black Hawk Down. This image runs the Windows `dfbhd.exe` you supply under Wine with Xvfb for headless hosting.

:::note[Requirements]
- Copy owned Windows game files into `./data` so `dfbhd.exe` exists at the volume root
- Publish UDP **3568**
- No SteamCMD install step, you must supply the game from a disc install or Steam library backup you own
- Community multiplayer may need external NovaHQ heartbeat tools (for example HawkSync) outside this container
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 3568 | UDP | Default multiplayer port for Delta Force: Black Hawk Down |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `BHD_EXTRA_ARGS` | (empty) | Extra arguments passed to `wine dfbhd.exe` after launch |

Wine prefix and paths are fixed inside the image (`WINEPREFIX=/opt/dfbhd/.wine`, `BHD_DIR=/opt/dfbhd`).

## Data volume

`./data` mounts to `/opt/dfbhd`.

| Path | Purpose |
| --- | --- |
| `dfbhd.exe` | Required Windows game binary, you must copy this in before first start |
| Game data files | Maps, assets, and other files from your owned install |
| `.wine/` | Wine prefix, created on first start |

## Compose

```bash
docker compose -f delta-force-bhd/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name delta-force-bhd --restart unless-stopped --init \
  -p 3568:3568/udp \
  -v "$PWD/delta-force-bhd/data:/opt/dfbhd" \
  -e BHD_EXTRA_ARGS="" \
  {{IMAGE_PREFIX}}/delta-force-bhd:latest
```

## Updating

There is no SteamCMD update path. Replace game files in `./data` when you upgrade your install. The healthcheck is a `process` probe for `dfbhd.exe` with a 300 second start period.
