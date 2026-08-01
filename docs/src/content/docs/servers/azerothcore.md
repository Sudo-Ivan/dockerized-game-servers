---
title: AzerothCore
description: World of Warcraft 3.3.5a private server via pre-built acore/* Docker images.
---

Compose path: `azerothcore`. This stack uses [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk) images from [Docker Hub (`acore/*`)](https://hub.docker.com/u/acore), based on the upstream [acore-docker](https://github.com/azerothcore/acore-docker) compose. There is no `Dockerfile` in this repository.

[AzerothCore](https://www.azerothcore.org/) is an open-source World of Warcraft **3.3.5a (Wrath of the Lich King)** emulator. The compose file pulls pre-built server binaries, imports the SQL databases on first start, and populates map data from the `ac-wotlk-client-data` image. You still need a compatible game client to play, see [client setup](https://www.azerothcore.org/wiki/client-setup).

:::note[Requirements]
- First start downloads images and imports databases, allow several minutes
- Persist `./data` for MySQL, client data, logs, and config
- Publish TCP **3724** (auth) and **8085** (world). SOAP defaults to **7878**
- Allocate at least 4 GB RAM for `azerothcore-worldserver`
:::

This catalog entry is `first_party=0`, so `./tools/gs update azerothcore` is not available. Use `docker compose pull` instead. `./tools/gs backup azerothcore` and `restore` work against the `data/` tree.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 3724 | TCP | Auth server (`ACORE_AUTH_EXTERNAL_PORT`) |
| 8085 | TCP | World server (`ACORE_WORLD_EXTERNAL_PORT`) |
| 7878 | TCP | SOAP (`ACORE_SOAP_EXTERNAL_PORT`) |
| 8080 | TCP | phpMyAdmin (`ACORE_PHPMYADMIN_PORT`, `admin` profile only) |

MySQL stays on the internal `azerothcore` network and is not published by default.

## Volumes

All paths are under `azerothcore/data/` on the host:

| Mount | Container path | Purpose |
| --- | --- | --- |
| `mysql` | `/var/lib/mysql` | Auth, world, and characters databases |
| `client-data` | `/azerothcore/env/dist/data` | DBC, maps, vmaps, mmaps (populated by `azerothcore-client-data` on first start) |
| `logs` | `/azerothcore/env/dist/logs` | Auth and world server logs |
| `etc` | `/azerothcore/env/dist/etc` | Optional extracted `*.conf` overrides |
| `scripts/lua` | `/azerothcore/env/dist/bin/lua_scripts/scripts` | Eluna Lua scripts |

## Quick start

```bash
cd azerothcore
cp .env.example .env
# edit .env if you want a stronger ACORE_DB_ROOT_PASSWORD
docker compose up -d
docker compose logs -f azerothcore-worldserver
```

One-shot init containers (`azerothcore-client-data`, `azerothcore-db-import`) must finish before auth and world start. Watch logs until the worldserver is ready.

Create a game account in the worldserver console:

```bash
docker attach azerothcore-worldserver
```

At the `AC>` prompt:

```text
account create <username> <password>
account set gmlevel <username> 3 -1
```

Detach with `Ctrl-p Ctrl-q` (do not use `Ctrl-c`, which stops the server).

Point a **3.3.5a** client at your host (default realm port **8085**). See [AzerothCore client setup](https://www.azerothcore.org/wiki/client-setup).

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `ACORE_DB_ROOT_PASSWORD` | `acore` | MySQL root password, shared by all `AC_*_DATABASE_INFO` strings |
| `ACORE_IMAGE_TAG` | `master` | Tag for all `acore/ac-wotlk-*` images |
| `ACORE_AUTH_EXTERNAL_PORT` | `3724` | Host port for authserver |
| `ACORE_WORLD_EXTERNAL_PORT` | `8085` | Host port for worldserver |
| `ACORE_SOAP_EXTERNAL_PORT` | `7878` | Host port for SOAP |
| `ACORE_PHPMYADMIN_PORT` | `8080` | Host port when using the `admin` profile |
| `ACORE_DOCKER_USER` | `acore` | UID inside worldserver (upstream default) |

See `azerothcore/.env.example` for commented overrides.

## Optional phpMyAdmin

```bash
docker compose --profile admin up -d
```

Open `http://127.0.0.1:8080` (or your `ACORE_PHPMYADMIN_PORT`). Host: `azerothcore-database`, user: `root`, password: your `ACORE_DB_ROOT_PASSWORD`.

## Config overrides

To edit `worldserver.conf` or `authserver.conf` on the host:

```bash
docker compose cp azerothcore-worldserver:/azerothcore/env/dist/etc/worldserver.conf data/etc/
docker compose cp azerothcore-authserver:/azerothcore/env/dist/etc/authserver.conf data/etc/
```

Edit files under `data/etc/`, then restart auth and world. Upstream dist files: [worldserver.conf.dist](https://github.com/azerothcore/azerothcore-wotlk/blob/master/src/server/apps/worldserver/worldserver.conf.dist), [authserver.conf.dist](https://github.com/azerothcore/azerothcore-wotlk/blob/master/src/server/apps/authserver/authserver.conf.dist).

## Lua scripts

Drop Eluna scripts into `data/scripts/lua/`. The worldserver image ships with Eluna enabled. See [Eluna documentation](https://github.com/ElunaLuaEngine/Eluna/blob/master/README.md).

## Updates

```bash
cd azerothcore
docker compose down
docker compose pull
docker compose rm -s -v -f azerothcore-client-data
docker compose up -d
```

Recreating `azerothcore-client-data` refreshes bundled map data from the image. Skip `docker compose rm ... azerothcore-client-data` if you use custom extracted client data.

## Compose from repo root

```bash
docker compose -f azerothcore/docker-compose.yml up -d
```

## See also

- [AzerothCore installation guide](https://www.azerothcore.org/wiki/installation) (source build and other setup paths)
- [Install with Docker](https://www.azerothcore.org/wiki/install-with-docker) (upstream wiki)
- [acore-docker](https://github.com/azerothcore/acore-docker) (reference compose this stack is based on)
- [GM commands](https://www.azerothcore.org/wiki/GM-Commands)
- [All servers](/reference/servers/) for the compose path
- [Ops](/guides/ops/) for `./tools/gs backup` and `restore`
