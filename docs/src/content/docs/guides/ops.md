---
title: Ops
description: Backup, restore, update, and healthchecks for game servers.
---

Host tooling lives under `tools/gs` and reads the shared server catalog at `ci/server-catalog.sh`. Compose image names use `IMAGE_OWNER` from `ci/repo-meta.sh`.

## List servers

```bash
./tools/gs list
```

## Backup

Stops the container, archives catalog volume directories, then starts again:

```bash
export IMAGE_OWNER="$(./ci/repo-meta.sh | sed -n 's/^IMAGE_OWNER=//p')"
./tools/gs backup core-keeper
```

Archives default to `backups/<game>/<timestamp>.tar.gz`. Override with a path argument or `GS_BACKUP_DIR`.

## Restore

```bash
./tools/gs restore core-keeper backups/core-keeper/20260727-120000.tar.gz
```

## Update

One-shot recreate with the catalog `update_envs` set to `true` (compose defaults stay false via `${VAR:-false}`):

```bash
./tools/gs update factorio
./tools/gs update core-keeper --backup
```

Games without update envs (for example Arma 3) cannot use `gs update`.

## Healthchecks

First-party images define `HEALTHCHECK` and a `/healthcheck.sh` probe. Compose mirrors the same check.

```bash
docker compose -f core-keeper/docker-compose.yml ps
docker inspect --format '{{.State.Health.Status}}' core-keeper
```

Probe kinds come from the catalog:

- `tcp`: Minecraft listen port (default 25565)
- `process`: dedicated server process is running
- `gameid`: Core Keeper process plus non-empty `GameID.txt`
