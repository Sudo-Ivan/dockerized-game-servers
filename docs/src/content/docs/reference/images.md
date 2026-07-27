---
title: Images
description: Published GHCR images and how to pull them.
---

Prefix: {{IMAGE_PREFIX}}

| Name | Notes |
| --- | --- |
| minecraft-base | Shared Minecraft runtime |
| steam-base | Shared SteamCMD runtime (Arch) |
| runtime-base | Shared Debian slim runtime (non-Steam, non-Java) |
| minecraft-fabric | Fabric |
| minecraft-vanilla | Vanilla |
| minecraft-forge | Forge |
| valheim | Valheim dedicated |
| valheim-plus | Valheim Plus |
| ground-branch | Ground Branch (Wine) |
| core-keeper | Core Keeper dedicated |
| factorio | Factorio dedicated |
| 7-days-to-die | 7 Days to Die dedicated |
| project-zomboid | Project Zomboid dedicated |
| terraria | Terraria dedicated |
| l4d2 | Left 4 Dead 2 dedicated |
| palworld | Palworld dedicated |
| starbound | Starbound dedicated |
| openmohaa | OpenMoHAA (bring your own MOHAA assets) |
| arma-3 | Arma 3 dedicated |

```bash
docker pull {{IMAGE_PREFIX}}/minecraft-fabric:latest
```

After the first publish, set GHCR package visibility to public if the repo is public.
