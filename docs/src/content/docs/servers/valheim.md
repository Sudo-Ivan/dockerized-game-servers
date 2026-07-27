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
| `STEAM_USERNAME` | `anonymous` | SteamCMD login for the install/update step |
| `STEAM_PASSWORD` | empty | Password for `STEAM_USERNAME`, unused when anonymous |
| `STEAM_GUARD_CODE` | empty | Steam Guard code, unused when anonymous |
| `SERVER_NAME` | `Valheim Server` (`Valheim Plus Server` for Plus) | Public server name |
| `SERVER_PORT` | `2456` | Game port (publish UDP 2456-2458) |
| `WORLD_NAME` | `Dedicated` | Save name under the data volume |
| `SERVER_PASS` | `changeme` (compose default, image default is `secret`) | Join password, set a real value |
| `SERVER_PUBLIC` | `1` | List on public server browser |
| `SERVER_LOGINTOKEN` | empty | Optional [Steam Game Server Login Token](https://steamcommunity.com/dev/managegameservers), adds `-crossplay` when set |
| `VALHEIM_FORCE_UPDATE` | `false` | Set `true` to force SteamCMD reinstall, same var `./tools/gs update valheim` sets |

Valheim Plus only:

| Variable | Default | Purpose |
| --- | --- | --- |
| `VALHEIM_PLUS_VERSION` | `0.9.17.1` | ValheimPlus release tag to install |
| `VALHEIM_PLUS_FORCE_INSTALL` | `false` | Reinstall Plus even if the version marker matches, same var `./tools/gs update valheim-plus` sets alongside `VALHEIM_FORCE_UPDATE` |
| `VALHEIM_PLUS_URL` | `https://github.com/Grantapher/ValheimPlus/releases/download/<VALHEIM_PLUS_VERSION>/UnixServer.tar.gz` | Override the Plus archive download URL |

World and config files live under `valheim/<variant>/data/` on the host after first start.

## Healthcheck

Both images run a process healthcheck (`pgrep -f valheim_server`), there is no port probe. See [Ops](/guides/ops/) for `docker inspect --format '{{.State.Health.Status}}'` and for `./tools/gs backup` / `restore` / `update`.

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

## See also

- [All servers](/reference/servers/) for compose paths and image names
- [Images](/reference/images/) for the shared `steam-base` image
- [Ops](/guides/ops/) for `./tools/gs backup`, `restore`, and `update`
