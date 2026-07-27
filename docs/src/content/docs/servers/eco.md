---
title: Eco
description: Eco dedicated server via SteamCMD.
steamAppId: "739590"
---

Compose path: `eco`. Image: `eco`.

Steam App **739590**. Downloads on first start into `eco/data`. Set `ECO_USER_TOKEN` from your Eco account.

## Ports

UDP **3000** and **3001**.

## Compose

```bash
export ECO_USER_TOKEN=your-token
docker compose -f eco/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name eco --restart unless-stopped --init \
  -p 3000:3000/udp -p 3001:3001/udp \
  -v "$PWD/eco/data:/opt/eco" \
  -e ECO_USER_TOKEN=your-token \
  {{IMAGE_PREFIX}}/eco:latest
```

Set `ECO_FORCE_UPDATE=true` to refresh the Steam install. Use `ECO_EXTRA_ARGS` for extra dedicated flags.
