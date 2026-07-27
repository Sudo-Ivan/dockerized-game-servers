---
title: DayZ
description: DayZ dedicated server via SteamCMD.
---

Compose path: dayz. Image: dayz.

Steam App **223350**. **You must use a Steam account that owns DayZ** (client App 221100). Anonymous SteamCMD cannot download the server depot.

## Defaults

- UDP **2302** through **2306** (`DAYZ_PORT` is the main game port)
- Config: `serverDZ.cfg` in the data volume (default Chernarus offline mission)
- Profiles: `profiles/`
- BattlEye: `battleye/` under the data volume
- Updates: `DAYZ_FORCE_UPDATE=true`
- Workshop mods: use `DAYZ_EXTRA_ARGS` (for example `-mod=@MyMod`) and install mods with SteamCMD `workshop_download_item 221100 <id>` on the host or extend your update flow

Set `STEAM_USERNAME`, `STEAM_PASSWORD`, and optional `STEAM_GUARD_CODE` in compose or `.env`.

## Docker run

```bash
docker run -d --name dayz --restart unless-stopped --init \
  -p 2302:2302/udp -p 2303:2303/udp -p 2304:2304/udp \
  -p 2305:2305/udp -p 2306:2306/udp \
  -v "$PWD/dayz/data:/opt/dayz" \
  -e STEAM_USERNAME="your_steam_user" \
  -e STEAM_PASSWORD="your_steam_password" \
  {{IMAGE_PREFIX}}/dayz:latest
```

Allocate at least 6 GB RAM for the container.
