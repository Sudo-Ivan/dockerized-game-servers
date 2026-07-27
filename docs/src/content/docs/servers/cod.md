---
title: Call of Duty
description: Call of Duty (2003) dedicated server (LinuxGSM archive).
---

Compose path: cod. Image: cod.

Linux dedicated files from [LinuxGSM](http://linuxgsm.download/CallOfDuty/). You must own Call of Duty. Data volume `cod/data` maps to `/opt/cod`.

## Defaults

- UDP 28960 (`COD_PORT`)
- Map `mp_neuville` (`COD_STARTMAP`)
- `COD_MAXPLAYERS`, `COD_HOSTNAME`, `COD_EXTRA_ARGS`

Only one container should bind host UDP 28960 unless you change `COD_PORT` and compose ports.

## Docker run

```bash
docker run -d --name cod --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/cod/data:/opt/cod" \
  {{IMAGE_PREFIX}}/cod:latest
```

Server config: `cod/data/server.cfg` (a default is created on first start).
