---
title: 7 Days to Die
description: 7 Days to Die dedicated server via SteamCMD.
---

Compose path: 7-days-to-die. Image: 7-days-to-die.

## Behavior

Downloads the Linux dedicated server (Steam App 294420) on first start. World and config live under `7-days-to-die/data` mounted at `/opt/7dtd`.

- Game: TCP and UDP 26900, UDP 26901-26903
- Default config: `serverconfig.xml` in the data volume (Steam updates may overwrite this file, use a custom name via `CONFIG_FILE` if you edit settings)
- Updates: set `SEVENDTD_FORCE_UPDATE=true` or run `./tools/gs update 7-days-to-die`

## Docker run

```bash
docker run -d --name 7-days-to-die --restart unless-stopped --init \
  -p 26900:26900/tcp -p 26900:26900/udp \
  -p 26901-26903:26901-26903/udp \
  -v "$PWD/7-days-to-die/data:/opt/7dtd" \
  {{IMAGE_PREFIX}}/7-days-to-die:latest
```
