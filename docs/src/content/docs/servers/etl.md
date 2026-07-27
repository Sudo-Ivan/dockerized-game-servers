---
title: 'ET: Legacy'
description: ET Legacy dedicated server (GameServerManagers etlserver-build).
---

Compose path: etl. Image: etl.

Bundle from [GameServerManagers etlserver-build](https://github.com/GameServerManagers/etlserver-build). You must own Wolfenstein Enemy Territory. Volume `etl/data` at `/opt/etl`.

## Defaults

- UDP 27960 game (`ETL_PORT`), 27961 status (expose both in compose)
- Map `oasis` (`ETL_STARTMAP`)
- Gametype `4` objective (`ETL_GAMETYPE`)
- `ETL_MAXPLAYERS`, `ETL_HOSTNAME`, `ETL_EXTRA_ARGS`
- `ETL_FORCE_UPDATE=true` re-downloads the bundle into the data volume

## Docker run

```bash
docker run -d --name etl --restart unless-stopped --init \
  -p 27960:27960/udp -p 27961:27961/udp \
  -v "$PWD/etl/data:/opt/etl" \
  {{IMAGE_PREFIX}}/etl:latest
```
