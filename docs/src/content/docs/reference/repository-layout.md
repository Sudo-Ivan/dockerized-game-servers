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
palworld/         Palworld
starbound/        Starbound
openmohaa/       OpenMoHAA (BYO game assets)
arma/arma-3/     Arma 3
hytale/          external image compose
stardew-valley/  JunimoServer (external sdvd/* images)
backups/         local gs backup archives (gitignored)
```

Identity and GHCR paths resolve from git remote or `GITHUB_REPOSITORY` via `ci/repo-meta.sh`. Runnable servers and their volumes or update envs live in `ci/server-catalog.sh`.

License: 0BSD
