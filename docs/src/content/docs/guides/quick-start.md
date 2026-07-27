---
title: Quick start
description: Run a game server with Docker Compose or docker run.
---

## Compose

Set IMAGE_OWNER to your GitHub owner/repo (lowercase), then start:

```bash
export IMAGE_OWNER="$(./ci/repo-meta.sh | sed -n 's/^IMAGE_OWNER=//p')"
docker compose -f minecraft/fabric/docker-compose.yml up
```

Build locally:

```bash
docker compose -f minecraft/fabric/docker-compose.yml up --build
```

Compose files set image to GHCR via IMAGE_OWNER and keep a build section for local rebuilds. pull_policy missing uses a local image when present, otherwise pulls.

Swap the compose path for any other server under the matching directory.

## Docker run

Image prefix: {{IMAGE_PREFIX}}

Examples live on each server page. A typical Minecraft Fabric run looks like this:

```bash
docker run -d --name fabric --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/fabric/data:/data" \
  -e EULA=true \
  {{IMAGE_PREFIX}}/minecraft-fabric:latest
```

## Minecraft

Accept the EULA with EULA=true. World and config live in each server's ./data volume.

## Steam games

Many titles allow anonymous SteamCMD. Arma 3 usually needs a Steam account that owns the server files. Set Valheim SERVER_PASS with -e or a .env file next to compose.
