---
title: Valheim
description: Valheim and Valheim Plus dedicated servers.
---

| Variant | Compose folder | Image name |
| --- | --- | --- |
| Vanilla | dockerized/valheim/vanilla | valheim |
| Plus | dockerized/valheim/plus | valheim-plus |

:::note[Before you start]
- Set a join password (SERVER_PASS via -e or a .env file next to compose)
- Keep a data folder for your world (mounted at /opt/valheim in the container)
- Open UDP ports 2456 through 2458
:::

## Settings

Common options for vanilla and Plus unless noted:

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login for install and updates |
| STEAM_PASSWORD | (empty) | Password for STEAM_USERNAME, unused when anonymous |
| STEAM_GUARD_CODE | (empty) | Steam Guard code, unused when anonymous |
| SERVER_NAME | Valheim Server (Valheim Plus Server for Plus) | Public server name |
| SERVER_PORT | 2456 | Game port (publish UDP 2456-2458) |
| WORLD_NAME | Dedicated | Save name under the data folder |
| SERVER_PASS | changeme in compose (secret in the image alone) | Join password. Set a real value. |
| SERVER_PUBLIC | 1 | List on the public server browser |
| SERVER_LOGINTOKEN | (empty) | Optional [Steam Game Server Login Token](https://steamcommunity.com/dev/managegameservers). Adds crossplay when set. |
| VALHEIM_FORCE_UPDATE | false | Set true to force a Steam reinstall. Same flag ./tools/gs update valheim sets. |

Valheim Plus only:

| Setting | Default | What it does |
| --- | --- | --- |
| VALHEIM_PLUS_VERSION | 0.9.17.1 | ValheimPlus release to install |
| VALHEIM_PLUS_FORCE_INSTALL | false | Reinstall Plus even if the version marker matches. Used by ./tools/gs update valheim-plus with VALHEIM_FORCE_UPDATE. |
| VALHEIM_PLUS_URL | GitHub release URL for VALHEIM_PLUS_VERSION | Override the Plus archive download URL |

World and config files live under dockerized/valheim/<variant>/data/ on the host after first start.

## Health check

Both images check that the valheim_server process is running. There is no port probe. See [Ops](/guides/ops/) for checking status and for backup, restore, and update.

## Compose

```bash
docker compose -f dockerized/valheim/vanilla/docker-compose.yml up -d
```

Use dockerized/valheim/plus/docker-compose.yml for Valheim Plus.

## Docker run

Valheim:

```bash
docker run -d --name valheim --restart unless-stopped --init \
  -p 2456-2458:2456-2458/udp \
  -v "$PWD/dockerized/valheim/vanilla/data:/opt/valheim" \
  -e SERVER_PASS=changeme \
  {{IMAGE_PREFIX}}/valheim:latest
```

Valheim Plus:

```bash
docker run -d --name valheim-plus --restart unless-stopped --init \
  -p 2456-2458:2456-2458/udp \
  -v "$PWD/dockerized/valheim/plus/data:/opt/valheim" \
  -e SERVER_PASS=changeme \
  {{IMAGE_PREFIX}}/valheim-plus:latest
```

## See also

- [All servers](/reference/servers/) for compose paths and image names
- [Images](/reference/images/) for the shared steam-base image
- [Ops](/guides/ops/) for backup, restore, and update with ./tools/gs
