---
title: Quick start
description: Run a game server with Docker Compose or docker run.
---

## Prerequisites

- Docker Engine with the Compose plugin (`docker compose`, not the old `docker-compose`)
- A clone of this repository, since compose files and per-server `./data` folders live in it
- For Wine-based images (Ground Branch, Space Engineers, Icarus, Sons Of The Forest, Sniper Elite 4), enough CPU and RAM headroom, these run a Windows binary under Wine and are heavier than native Linux builds

## 1. Pick a server

Every runnable server has a compose path and image name in [All servers](/reference/servers/). Each also has its own guide under **Servers** with the exact ports, volumes, and environment variables for that game.

## 2. Set IMAGE_OWNER

Compose files reference `ghcr.io/${IMAGE_OWNER}/<image>:latest`. `IMAGE_OWNER` is your GitHub `owner/repo`, lowercased, and it comes from `ci/repo-meta.sh` (it reads `GITHUB_REPOSITORY` if set, otherwise your git remote):

```bash
export IMAGE_OWNER="$(./ci/repo-meta.sh | sed -n 's/^IMAGE_OWNER=//p')"
```

Set this once per shell session before running compose commands below. If you only build and run locally and never pull from GHCR, any value works since `pull_policy: missing` (see below) will use the local image.

## 3. Run with Compose

```bash
docker compose -f minecraft/fabric/docker-compose.yml up
```

Swap the path for any other server, for example `valheim/vanilla/docker-compose.yml` or `core-keeper/docker-compose.yml`.

To build the image locally instead of pulling from GHCR:

```bash
docker compose -f minecraft/fabric/docker-compose.yml up --build
```

Every compose file sets `image` to the GHCR tag and also keeps a `build` section pointing at the local `Dockerfile`. With `pull_policy: missing`, compose uses an image already on disk (including one you built locally) before it tries to pull. To force a fresh pull, add `--pull always`.

## 4. Run with docker run instead

Compose is recommended since it keeps ports, volumes, healthchecks, and resource limits together, but a plain `docker run` works too. Each server guide has a ready-to-copy example. The general shape:

```bash
docker run -d --name <container> --restart unless-stopped --init \
  -p <port>:<port>/<proto> \
  -v "$PWD/<server>/data:/<data-path>" \
  -e <ENV_VAR>=<value> \
  {{IMAGE_PREFIX}}/<image>:latest
```

Image prefix: `{{IMAGE_PREFIX}}`

For example, Minecraft Fabric with no mods needs only the EULA flag:

```bash
docker run -d --name fabric --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/fabric/data:/data" \
  -e EULA=true \
  {{IMAGE_PREFIX}}/minecraft-fabric:latest
```

`-p host:container/proto` must match the ports listed on the server's guide, both TCP and UDP where the game needs both. `--init` reaps zombie processes from wrapper scripts and is set in every compose file too, keep it when you switch to `docker run`.

## Persistent data

Every server mounts a host folder to a data path inside the container, most use `./data` next to the compose file (check the compose file's `volumes:` section if you're unsure since a few games split state across more than one path, for example Arma 3 uses `server`, `configs`, and `profiles`). Stop the container before editing config files by hand, then start it again.

## Environment variables you will see repeatedly

These patterns show up across many servers, but not all, always check the server's own guide for the full list:

| Variable | Where it applies | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME`, `STEAM_PASSWORD`, `STEAM_GUARD_CODE` | Any SteamCMD-based image | Steam login for the download step. Defaults to anonymous. |
| `EULA` | Minecraft only | Must be `true` or the server refuses to start |
| `SERVER_PASS` / similar join password variables | Most Steam and Wine games | Join or admin password, game-specific name |
| `*_FORCE_UPDATE`, `*_FORCE_DOWNLOAD`, `*_FORCE_INSTALL` | Games with an update env in `ci/server-catalog.sh` | Forces a reinstall or redownload on next start, used by `./tools/gs update` |
| `PUID`, `PGID` | Minecraft only | Match container file ownership to a host user/group |

:::note[Steam login]
Anonymous SteamCMD downloads most dedicated server tools without a Steam account. A few games (Arma 3 is the common case) need an account that owns the server files. Set `STEAM_USERNAME` and `STEAM_PASSWORD`, and `STEAM_GUARD_CODE` if Steam Guard prompts for a code. Anonymous logins can also fail to list a server publicly for some titles, in which case set real credentials.
:::

## Ops: backup, restore, update, healthchecks

Covered on the [Ops](./ops/) page: `./tools/gs backup`, `./tools/gs restore`, `./tools/gs update`, and how healthchecks map to `docker inspect`.

## Next steps

- [All servers](/reference/servers/) for the full compose path and image table
- [Images](/reference/images/) for published GHCR image names
- [CI](/reference/ci/) for how images build and publish
