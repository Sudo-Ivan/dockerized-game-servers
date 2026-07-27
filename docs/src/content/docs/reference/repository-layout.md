---
title: Repository layout
description: Top-level directories in this repository.
---

```text
bases/           shared Docker bases
ci/              POSIX CI scripts (repo-meta, server-catalog, image-matrix, checks)
tools/           host ops CLI (gs backup restore update)
docs/            Starlight site (this documentation)
minecraft/       Fabric, Vanilla, Forge
valheim/         Vanilla and Plus
ground-branch/   Ground Branch
core-keeper/     Core Keeper
factorio/         Factorio
arma/arma-3/     Arma 3
hytale/          external image compose
backups/         local gs backup archives (gitignored)
```

Identity and GHCR paths resolve from git remote or `GITHUB_REPOSITORY` via `ci/repo-meta.sh`. Runnable servers and their volumes or update envs live in `ci/server-catalog.sh`.

License: 0BSD
