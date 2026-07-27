---
title: Valheim
description: Valheim and Valheim Plus dedicated servers.
---

| Variant | Compose | Image |
| --- | --- | --- |
| Vanilla | valheim/vanilla | valheim |
| Plus | valheim/plus | valheim-plus |

:::note[Requirements]
- Set `SERVER_PASS` (via `-e` or a `.env` next to compose)
- Persist data under `/opt/valheim` in the container
- Publish UDP **2456-2458**
:::

## Configuration

Common environment variables (vanilla and Plus unless noted):

| Variable | Default | Purpose |
| --- | --- | --- |
| `SERVER_NAME` | `Valheim Server` | Public server name |
| `SERVER_PORT` | `2456` | Game port (publish UDP 2456-2458) |
| `WORLD_NAME` | `Dedicated` | Save name under the data volume |
| `SERVER_PASS` | `secret` | Join password (set a real value) |
| `SERVER_PUBLIC` | `1` | List on public server browser |
| `SERVER_LOGINTOKEN` | empty | Optional [Steam Game Server Login Token](https://steamcommunity.com/dev/managegameservers) |
| `VALHEIM_FORCE_UPDATE` | `false` | Set `true` to force SteamCMD update |

Valheim Plus adds install/update env vars for the Plus package (see `valheim/plus/docker-compose.yml`).

World and config files live under `valheim/<variant>/data/` on the host after first start.

## Compose

```bash
docker compose -f valheim/vanilla/docker-compose.yml up -d
```

Use `valheim/plus/docker-compose.yml` for Valheim Plus.

## Docker run

Valheim:

```bash
docker run -d --name valheim --restart unless-stopped --init \
  -p 2456-2458:2456-2458/udp \
  -v "$PWD/valheim/vanilla/data:/opt/valheim" \
  -e SERVER_PASS=changeme \
  {{IMAGE_PREFIX}}/valheim:latest
```

Valheim Plus:

```bash
docker run -d --name valheim-plus --restart unless-stopped --init \
  -p 2456-2458:2456-2458/udp \
  -v "$PWD/valheim/plus/data:/opt/valheim" \
  -e SERVER_PASS=changeme \
  {{IMAGE_PREFIX}}/valheim-plus:latest
```
