---
title: All servers
description: Runnable servers from the repository catalog with compose paths and image names.
---

Runnable servers are defined in `ci/server-catalog.sh`. First-party images publish to `{{IMAGE_PREFIX}}/`. External stacks use their own image references in compose.

| Server | Compose path | Image name | Docs |
| --- | --- | --- | --- |
| Minecraft Fabric | minecraft/fabric | minecraft-fabric | [Guide](../servers/minecraft/) |
| Minecraft Vanilla | minecraft/vanilla | minecraft-vanilla | [Guide](../servers/minecraft/) |
| Minecraft Forge | minecraft/forge | minecraft-forge | [Guide](../servers/minecraft/) |
| Minecraft NeoForge | minecraft/neoforge | minecraft-neoforge | [Guide](../servers/minecraft/) |
| Valheim | valheim/vanilla | valheim | [Guide](../servers/valheim/) |
| Valheim Plus | valheim/plus | valheim-plus | [Guide](../servers/valheim/) |
| Ground Branch | ground-branch | ground-branch | [Guide](../servers/ground-branch/) |
| Space Engineers | space-engineers | space-engineers | [Guide](../servers/space-engineers/) |
| Core Keeper | core-keeper | core-keeper | [Guide](../servers/core-keeper/) |
| Factorio | factorio | factorio | [Guide](../servers/factorio/) |
| 7 Days to Die | 7-days-to-die | 7-days-to-die | [Guide](../servers/7-days-to-die/) |
| Project Zomboid | project-zomboid | project-zomboid | [Guide](../servers/project-zomboid/) |
| Terraria | terraria | terraria | [Guide](../servers/terraria/) |
| Left 4 Dead 2 | l4d2 | l4d2 | [Guide](../servers/l4d2/) |
| Insurgency (Source) | insurgency-source | insurgency-source | [Guide](../servers/insurgency-source/) |
| Insurgency: Sandstorm | insurgency-sandstorm | insurgency-sandstorm | [Guide](../servers/insurgency-sandstorm/) |
| Counter-Strike: Source | cs-source | cs-source | [Guide](../servers/cs-source/) |
| Killing Floor 2 | kf2 | kf2 | [Guide](../servers/kf2/) |
| Icarus | icarus | icarus | [Guide](../servers/icarus/) |
| The Forest | the-forest | the-forest | [Guide](../servers/the-forest/) |
| Sons Of The Forest | sons-of-the-forest | sons-of-the-forest | [Guide](../servers/sons-of-the-forest/) |
| Sniper Elite 4 | sniper-elite-4 | sniper-elite-4 | [Guide](../servers/sniper-elite-4/) |
| Battlefield 1942 | bf1942 | bf1942 | [Guide](../servers/bf1942/) |
| Battlefield Vietnam | bfv | bfv | [Guide](../servers/bfv/) |
| Call of Duty | cod | cod | [Guide](../servers/cod/) |
| Call of Duty 2 | cod2 | cod2 | [Guide](../servers/cod2/) |
| Call of Duty: World at War | codwaw | codwaw | [Guide](../servers/codwaw/) |
| Call of Duty 4 | cod4 | cod4 | [Guide](../servers/cod4/) |
| Quake III Arena | quake3 | quake3 | [Guide](../servers/quake3/) |
| Return to Castle Wolfenstein | rtcw | rtcw | [Guide](../servers/rtcw/) |
| ET: Legacy | etl | etl | [Guide](../servers/etl/) |
| Eco | eco | eco | [Guide](../servers/eco/) |
| Palworld | palworld | palworld | [Guide](../servers/palworld/) |
| Starbound | starbound | starbound | [Guide](../servers/starbound/) |
| OpenMoHAA | openmohaa | openmohaa | [Guide](../servers/openmohaa/) |
| Arma 3 | arma/arma-3 | arma-3 | [Guide](../servers/arma-3/) |
| Arma Reforger | arma/reforger | arma-reforger | [Guide](../servers/arma-reforger/) |
| DayZ | dayz | dayz | [Guide](../servers/dayz/) |
| Hytale | hytale | external (deinfreu/hytale-server) | [Guide](../servers/hytale/) |
| Stardew Valley | stardew-valley | external (JunimoServer sdvd/server) | [Guide](../servers/stardew-valley/) |

Servers without a guide page still ship compose files in the repository. Open the compose path for ports, volumes, and environment variables.

All first-party catalog servers have a guide under **Servers** in the sidebar.
