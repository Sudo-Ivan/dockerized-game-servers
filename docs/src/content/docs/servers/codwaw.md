---
title: 'Call of Duty: World at War'
description: Call of Duty World at War dedicated server (LinuxGSM archive).
---

Compose path: codwaw. Image: codwaw.

Files from [LinuxGSM CoD: WaW](http://linuxgsm.download/CallOfDutyWorldAtWar/). You must own the game. The data volume is large (about 8 GB after the first seed).

## Defaults

- UDP 28960 (`CODWAW_PORT`)
- Map `mp_castle` (`CODWAW_STARTMAP`)
- `CODWAW_MAXPLAYERS`, `CODWAW_HOSTNAME`, `CODWAW_EXTRA_ARGS`

Allocate at least 2 GB RAM for the container.

## Docker run

```bash
docker run -d --name codwaw --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/codwaw/data:/opt/codwaw" \
  {{IMAGE_PREFIX}}/codwaw:latest
```
