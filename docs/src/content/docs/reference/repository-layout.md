---
title: Repository layout
description: Top-level directories in this repository.
---

When you clone this repo, game server Dockerfiles, compose files, and data volumes live under `dockerized/`. Shared repo infrastructure (`ci/`, `tools/`, `docs/`) stays at the repository root. Other non-dockerized content may appear at the root over time as the monorepo grows.

For day-to-day hosting you mostly touch one game folder under `dockerized/` (compose file and data volumes) and optionally the `tools/` scripts for backup and updates.

```text
ci/              POSIX CI scripts (repo-meta, server-catalog, image-matrix, checks)
tools/           host ops CLI (gs backup restore update)
docs/            Starlight site (this documentation)
eggs/            Pterodactyl egg JSON (optional)
dockerized/
  bases/           shared Docker bases (minecraft, steam, runtime)
  trivy.yaml       Trivy scan config for Dockerfiles
  minecraft/       Fabric, Vanilla, Forge, NeoForge
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
  enshrouded/       Enshrouded (Wine)
  palworld/         Palworld
  starbound/        Starbound
  satisfactory/    Satisfactory (native Linux)
  longvinter/       Longvinter
  barotrauma/      Barotrauma
  unturned/        Unturned
  vein/            VEIN (Wine)
  v-rising/        V Rising (Wine)
  windrose/        Windrose (Wine)
  tf2/             Team Fortress 2
  cs2/             Counter-Strike 2
  dod-source/      Day of Defeat: Source
  dont-starve-together/ Don't Starve Together (native Linux)
  gmod/            Garry's Mod
  delta-force-bhd/ Delta Force: Black Hawk Down (Wine, BYO game files)
  openmohaa/       OpenMoHAA (BYO game assets)
  arma/arma-3/     Arma 3
  arma/reforger/   Arma Reforger
  dayz/            DayZ
  hytale/          external image compose
  stardew-valley/  JunimoServer (external sdvd/* images)
  azerothcore/     AzerothCore WotLK (external acore/* images)
backups/         local gs backup archives (gitignored)
```

Image names and GHCR paths resolve from your git remote or from GITHUB_REPOSITORY (see ci/repo-meta.sh). The list of runnable servers, their compose files, volumes, and update settings lives in one shared catalog that the gs tool and CI both read.

This project is licensed under 0BSD. See [License](/reference/license/) for the full text.
