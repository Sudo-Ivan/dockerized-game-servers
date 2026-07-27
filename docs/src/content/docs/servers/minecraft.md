---
title: Minecraft
description: Fabric, Vanilla, and Forge dedicated servers.
---

Three flavors share minecraft-base (Temurin JRE on Alpine).

| Flavor | Compose | Image |
| --- | --- | --- |
| Fabric | minecraft/fabric | minecraft-fabric |
| Vanilla | minecraft/vanilla | minecraft-vanilla |
| Forge | minecraft/forge | minecraft-forge |

:::note[Requirements]
- Set `EULA=true`
- Persist `./data` for world and config
- Publish TCP and UDP **25565** by default
:::

## Compose

```bash
docker compose -f minecraft/fabric/docker-compose.yml up
```

Replace fabric with vanilla or forge as needed.

## Docker run

Fabric:

```bash
docker run -d --name fabric --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/fabric/data:/data" \
  -e EULA=true \
  {{IMAGE_PREFIX}}/minecraft-fabric:latest
```

Vanilla:

```bash
docker run -d --name vanilla --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/vanilla/data:/data" \
  -e EULA=true \
  {{IMAGE_PREFIX}}/minecraft-vanilla:latest
```

Forge:

```bash
docker run -d --name forge --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/forge/data:/data" \
  -e EULA=true \
  {{IMAGE_PREFIX}}/minecraft-forge:latest
```

## Versioned builds

Manual workflow build-minecraft can publish tags for a chosen Minecraft version. See [CI](/reference/ci/).
