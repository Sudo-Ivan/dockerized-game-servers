---
title: Repository layout
description: Top-level directories in this repository.
---

```text
bases/           shared Docker bases (minecraft, steam, runtime)
ci/              POSIX CI scripts (repo-meta, server-catalog, image-matrix, checks)
tools/           host ops CLI (gs backup restore update)
docs/            Starlight site (this documentation)
minecraft/       Fabric, Vanilla, Forge
valheim/         Vanilla and Plus
ground-branch/   Ground Branch
core-keeper/     Core Keeper
factorio/         Factorio
7-days-to-die/    7 Days to Die
project-zomboid/  Project Zomboid
terraria/         Terraria
l4d2/             Left 4 Dead 2
insurgency-source/   Insurgency (Source)
insurgency-sandstorm/ Insurgency: Sandstorm
cs-source/        Counter-Strike: Source
kf2/              Killing Floor 2
icarus/           Icarus (Wine)
the-forest/       The Forest (native Linux)
sons-of-the-forest/ Sons Of The Forest (Wine)
sniper-elite-4/   Sniper Elite 4 (Wine)
supertuxkart/     SuperTuxKart (compiled from source)
bf1942/           Battlefield 1942 (LinuxGSM)
bfv/              Battlefield Vietnam (LinuxGSM)
cod/              Call of Duty (LinuxGSM)
cod2/             Call of Duty 2 (LinuxGSM)
codwaw/           Call of Duty: World at War (LinuxGSM)
cod4/             Call of Duty 4 (LinuxGSM / CoD4x)
quake3/           Quake 3: Arena (LinuxGSM)
rtcw/             Return to Castle Wolfenstein (ioRTCW / LinuxGSM)
etl/              ET: Legacy (etlserver-build)
eco/              Eco (Steam)
palworld/         Palworld
starbound/        Starbound
openmohaa/       OpenMoHAA (BYO game assets)
arma/arma-3/     Arma 3
arma/reforger/   Arma Reforger
dayz/            DayZ
hytale/          external image compose
stardew-valley/  JunimoServer (external sdvd/* images)
backups/         local gs backup archives (gitignored)
```

Identity and GHCR paths resolve from git remote or `GITHUB_REPOSITORY` via `ci/repo-meta.sh`. Runnable servers and their volumes or update envs live in `ci/server-catalog.sh`.

License: 0BSD
