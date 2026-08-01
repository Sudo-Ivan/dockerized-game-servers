---
title: Ops
description: Backup, restore, update, and healthchecks for game servers.
---

The gs command in tools/ helps with backups, restores, and game updates on the host. It knows which servers this repo supports and which compose file to use for each one. Compose image names use IMAGE_OWNER from ci/repo-meta.sh.

## List servers

```bash
./tools/gs list
```

## Backup

Stops the container, archives the game's data folders, then starts it again:

```bash
export IMAGE_OWNER="$(./ci/repo-meta.sh | sed -n 's/^IMAGE_OWNER=//p')"
./tools/gs backup core-keeper
```

Archives go to backups/<game>/<timestamp>.tar.gz by default. Pass a path as the second argument or set GS_BACKUP_DIR to change that.

## Restore

```bash
./tools/gs restore core-keeper backups/core-keeper/20260727-120000.tar.gz
```

## Update

Recreates the container once with update flags set to true (compose defaults stay false):

```bash
./tools/gs update factorio
./tools/gs update core-keeper --backup
```

Games without update flags (for example Arma 3) cannot use gs update.

## Health checks

First-party images run a health check script. Compose mirrors the same check.

```bash
docker compose -f core-keeper/docker-compose.yml ps
docker inspect --format '{{.State.Health.Status}}' core-keeper
```

Check types used by different games:

- tcp: Minecraft listen port (default 25565)
- process: dedicated server process is running
- gameid: Core Keeper process plus a non-empty GameID.txt file
