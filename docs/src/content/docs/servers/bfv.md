---
title: Battlefield Vietnam
description: Battlefield Vietnam dedicated server (LinuxGSM archive).
---

Compose path: bfv. Image: bfv.

Server files come from the [LinuxGSM Battlefield Vietnam archive](http://linuxgsm.download/BattlefieldVietnam/). You must own the game. First start seeds `bfv/data` at `/opt/bfv`.

## Ports and volume

- UDP 4755 (game) and UDP 27900 (query, LGSM default)
- Data: `bfv/data`
- Extra args: `BFV_EXTRA_ARGS`

## Docker run

```bash
docker run -d --name bfv --restart unless-stopped --init \
  -p 4755:4755/udp -p 27900:27900/udp \
  -v "$PWD/bfv/data:/opt/bfv" \
  {{IMAGE_PREFIX}}/bfv:latest
```
