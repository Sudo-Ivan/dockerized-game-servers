---
title: Return to Castle Wolfenstein
description: Return to Castle Wolfenstein dedicated server (ioRTCW / LinuxGSM archive).
---

Compose path: rtcw. Image: rtcw.

Files from [LinuxGSM ioRTCW](http://linuxgsm.download/ReturnToCastleWolfenstein/). You must own Return to Castle Wolfenstein. Volume `rtcw/data` at `/opt/rtcw`.

## Defaults

- UDP 27960 (`RTCW_PORT`)
- Map `mp_beach` (`RTCW_STARTMAP`)
- `RTCW_MAXPLAYERS`, `RTCW_HOSTNAME`, `RTCW_EXTRA_ARGS`

## Docker run

```bash
docker run -d --name rtcw --restart unless-stopped --init \
  -p 27960:27960/udp \
  -v "$PWD/rtcw/data:/opt/rtcw" \
  {{IMAGE_PREFIX}}/rtcw:latest
```
