---
title: Call of Duty 4
description: Call of Duty 4 dedicated server via CoD4x (LinuxGSM archive).
---

Compose path: cod4. Image: cod4.

Uses the [CoD4x LinuxGSM archive](http://linuxgsm.download/CallOfDuty4/) (`cod4x18_dedrun`). You must own Call of Duty 4. Data: `cod4/data` at `/opt/cod4`.

## Defaults

- UDP 28960 (`COD4_PORT`)
- Map `mp_crossfire` (`COD4_STARTMAP`)
- `COD4_MAXPLAYERS`, `COD4_HOSTNAME`, `COD4_EXTRA_ARGS`
- Runs with `sv_authorizemode -1` for LAN-style auth (same idea as LGSM)

## Docker run

```bash
docker run -d --name cod4 --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/cod4/data:/opt/cod4" \
  {{IMAGE_PREFIX}}/cod4:latest
```
