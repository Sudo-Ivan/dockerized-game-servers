---
title: 'Quake 3: Arena'
description: Quake 3 Arena dedicated server (LinuxGSM archive).
---

Compose path: quake3. Image: quake3.

Files from [LinuxGSM Quake 3](http://linuxgsm.download/Quake3/). You must own Quake 3 Arena. Volume `quake3/data` at `/opt/quake3`.

## Defaults

- UDP 27960 (`Q3_PORT`)
- Map `q3dm17` (`Q3_STARTMAP`)
- `Q3_HOSTNAME`, `Q3_EXTRA_ARGS`

## Docker run

```bash
docker run -d --name quake3 --restart unless-stopped --init \
  -p 27960:27960/udp \
  -v "$PWD/quake3/data:/opt/quake3" \
  {{IMAGE_PREFIX}}/quake3:latest
```
