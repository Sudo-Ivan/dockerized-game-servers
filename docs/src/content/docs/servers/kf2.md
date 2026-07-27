---
title: Killing Floor 2
description: Killing Floor 2 dedicated server via SteamCMD.
---

Compose path: kf2. Image: kf2.

## Behavior

Downloads the Linux dedicated server (Steam App 232130) on first start. Data volume: `kf2/data` mounted at `/opt/kf2`.

- Game: UDP 7777 (`KF2_PORT`)
- Query: UDP 27015 (`KF2_QUERY_PORT`)
- Web admin: TCP 8080 (if enabled in server config)
- Steam: UDP 20560
- Default map: `kf-bioticslab` (`KF2_STARTMAP`)
- Server config: `kf2/data/KFGame/Config/PCServer-KFGame.ini`
- Updates: `KF2_FORCE_UPDATE=true` or `./tools/gs update kf2`

Do not run `validate` on routine manual SteamCMD updates if you rely on custom `PCServer-KFGame.ini` tweaks (see [KF2 wiki](https://wiki.killingfloor2.com/index.php?title=Dedicated_Server_(Killing_Floor_2))). This image validates on first install and when `KF2_FORCE_UPDATE=true`.

## Docker run

```bash
docker run -d --name kf2 --restart unless-stopped --init \
  -p 7777:7777/udp -p 27015:27015/udp -p 8080:8080/tcp -p 20560:20560/udp \
  -v "$PWD/kf2/data:/opt/kf2" \
  {{IMAGE_PREFIX}}/kf2:latest
```
