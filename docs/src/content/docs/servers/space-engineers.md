---
title: Space Engineers
description: Space Engineers dedicated server (Windows build via Wine).
steamAppId: "298740"
---

Compose path: `space-engineers`. Image: `space-engineers`.

Steam App **298740** (Windows dedicated server) runs under Wine in this image. First start downloads server files into the data volume and can take several minutes.

## Volumes

Persist these host paths (see compose):

- `space-engineers/data/dedicated` — dedicated server install root
- `space-engineers/data/instances` — per-instance configs (default instance name `Default`)
- `space-engineers/data/plugins` — optional plugins

Default config file: `space-engineers/data/instances/Default/SpaceEngineers-Dedicated.cfg`. Edit after the first successful start.

## Ports and networking

- UDP **27016** — game port (default)
- Set `SE_PUBLIC_IP` when the container cannot infer a reachable public address for the dedicated config

## Updates

Set `SE_FORCE_UPDATE=true` on a one-off run or in compose when you want SteamCMD to refresh the dedicated install.

## Compose

```bash
docker compose -f space-engineers/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name space-engineers --restart unless-stopped --init \
  -p 27016:27016/udp \
  -v "$PWD/space-engineers/data/dedicated:/opt/spaceengineers/dedicated" \
  -v "$PWD/space-engineers/data/instances:/opt/spaceengineers/instances" \
  -v "$PWD/space-engineers/data/plugins:/opt/spaceengineers/plugins" \
  -e SE_PUBLIC_IP=203.0.113.10 \
  {{IMAGE_PREFIX}}/space-engineers:latest
```

Wine and .NET prerequisites are baked into the image. Rebuild `steam-base` when updating shared Steam install logic.
