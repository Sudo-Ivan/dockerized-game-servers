---
title: Images
description: Published GHCR images and how to pull them.
---

Prefix: {{IMAGE_PREFIX}}

| Name | Notes |
| --- | --- |
| minecraft-base | Shared Minecraft runtime |
| steam-base | Shared SteamCMD runtime (Arch) |
| runtime-base | Shared Debian slim runtime (non-Steam, non-Java, LinuxGSM legacy libs) |
| minecraft-fabric | Fabric |
| minecraft-vanilla | Vanilla |
| minecraft-forge | Forge |
| minecraft-neoforge | NeoForge |
| valheim | Valheim dedicated |
| valheim-plus | Valheim Plus |
| ground-branch | Ground Branch (Wine) |
| space-engineers | Space Engineers (Wine) |
| core-keeper | Core Keeper dedicated |
| factorio | Factorio dedicated |
| 7-days-to-die | 7 Days to Die dedicated |
| project-zomboid | Project Zomboid dedicated |
| terraria | Terraria dedicated |
| l4d2 | Left 4 Dead 2 dedicated |
| insurgency-source | Insurgency (Source) dedicated |
| insurgency-sandstorm | Insurgency: Sandstorm dedicated |
| cs-source | Counter-Strike: Source dedicated |
| kf2 | Killing Floor 2 dedicated |
| icarus | Icarus dedicated (Wine) |
| the-forest | The Forest dedicated (native Linux) |
| sons-of-the-forest | Sons Of The Forest dedicated (Wine) |
| sniper-elite-4 | Sniper Elite 4 dedicated (Wine) |
| supertuxkart | SuperTuxKart dedicated (compiled from source) |
| bf1942 | Battlefield 1942 dedicated (LinuxGSM files) |
| bfv | Battlefield Vietnam dedicated (LinuxGSM files) |
| cod | Call of Duty dedicated (LinuxGSM files) |
| cod2 | Call of Duty 2 dedicated (LinuxGSM files) |
| codwaw | Call of Duty: World at War dedicated (LinuxGSM files) |
| cod4 | Call of Duty 4 dedicated (CoD4x / LinuxGSM files) |
| quake3 | Quake 3: Arena dedicated (LinuxGSM files) |
| rtcw | Return to Castle Wolfenstein dedicated (ioRTCW / LinuxGSM files) |
| etl | ET: Legacy dedicated (etlserver-build) |
| eco | Eco dedicated (Steam) |
| palworld | Palworld dedicated |
| starbound | Starbound dedicated |
| openmohaa | OpenMoHAA (bring your own MOHAA assets) |
| arma-3 | Arma 3 dedicated |
| arma-reforger | Arma Reforger dedicated |
| dayz | DayZ dedicated |

```bash
docker pull {{IMAGE_PREFIX}}/minecraft-fabric:latest
```

After the first publish, set GHCR package visibility to public if the repo is public.
