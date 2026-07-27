---
title: Overview
description: Dockerized dedicated game servers with small images and compose files.
---

Images publish to GHCR under {{IMAGE_PREFIX}}/.

This site is static HTML. Reading and navigation work without JavaScript. Fuzzy search is available when JavaScript is enabled.

## Servers

| Server | Compose path | Image name |
| --- | --- | --- |
| Minecraft Fabric | minecraft/fabric | minecraft-fabric |
| Minecraft Vanilla | minecraft/vanilla | minecraft-vanilla |
| Minecraft Forge | minecraft/forge | minecraft-forge |
| Valheim | valheim/vanilla | valheim |
| Valheim Plus | valheim/plus | valheim-plus |
| Ground Branch | ground-branch | ground-branch |
| Core Keeper | core-keeper | core-keeper |
| Factorio | factorio | factorio |
| OpenMoHAA | openmohaa | openmohaa |
| Arma 3 | arma/arma-3 | arma-3 |
| Hytale | hytale | external (deinfreu/hytale-server) |

## Shared bases

- minecraft-base: Temurin JRE on Alpine
- steam-base: SteamCMD on Arch Linux

## Next steps

1. Follow [Quick start](guides/quick-start/) to run a server with Compose or Docker.
2. Open the matching page under Servers for ports, volumes, and env notes.
3. See [Images](reference/images/) and [CI](reference/ci/) when you build or publish.
