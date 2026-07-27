---
title: Call of Duty 2
description: Call of Duty 2 dedicated server (LinuxGSM archive).
---

Compose path: cod2. Image: cod2.

Files from [LinuxGSM Call of Duty 2](http://linuxgsm.download/CallOfDuty2/). You must own the game. Volume `cod2/data` at `/opt/cod2` (several GB after seeding).

## Defaults

- UDP 28960 (`COD2_PORT`)
- Map `mp_leningrad` (`COD2_STARTMAP`)
- `COD2_MAXPLAYERS`, `COD2_HOSTNAME`, `COD2_EXTRA_ARGS`

Change host and container ports if you run multiple CoD-family servers on one machine.

## Docker run

```bash
docker run -d --name cod2 --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/cod2/data:/opt/cod2" \
  {{IMAGE_PREFIX}}/cod2:latest
```
