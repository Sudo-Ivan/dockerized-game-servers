---
title: Battlefield Vietnam
description: Battlefield Vietnam dedicated server built from the LinuxGSM v1.21 archive.
---

Compose path: bfv. Image: bfv.

Built on the shared [runtime-base](/reference/images/) image. The Dockerfile bakes the LinuxGSM-hosted `bfv_linded-v1.21-20041207_patch` archive into the image as a seed, then copies that seed into the data volume the first time the container runs. You must own Battlefield Vietnam.

:::note[Requirements]
- You must own Battlefield Vietnam
- Persist `./data` for the server install and any config you edit
- Publish UDP **4755** and UDP **27900**
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 4755 | UDP | Game traffic, fixed, not configurable by env var |
| 27900 | UDP | LinuxGSM's default query/status port, fixed |

Neither port has an environment variable override.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `BFV_EXTRA_ARGS` | (empty) | Extra flags appended to `./start.sh +statusMonitor 1 ...` |

This is the only variable the entrypoint reads. Battlefield Vietnam has no hostname, map, or player-count env vars, everything else comes from the config files inside the seeded data volume or from flags you add through `BFV_EXTRA_ARGS`.

## Data volume

The data volume mounts to `/opt/bfv`. On first start (or whenever `.lgsm-seed-complete` or `start.sh` is missing from the volume), the entrypoint wipes anything already in the volume except `.gitkeep` and copies the baked-in seed over it, then creates `.lgsm-seed-complete`. After that it leaves the volume alone.

There is no generated `server.cfg`. All server settings (hostname, map rotation, player count, rcon) live in the mod's own config files inside the seeded tree. Edit them directly on the host with the container stopped.

Because a reseed deletes everything already in the volume, do not delete `.lgsm-seed-complete` or `start.sh` unless you actually want to discard any config changes and start from the baked-in seed again.

## Updates

`ci/server-catalog.sh` lists no update env var for `bfv`, so `./tools/gs update bfv` is not available. See [Ops](../guides/ops/) for backup and restore, which do work for this server since it has a normal `data` volume. To pick up a newer archive you have to change the `LGSM_URL`/`LGSM_MD5` build args in the Dockerfile and rebuild the image.

## Healthcheck

`process` kind: the container is healthy while a process matching `bfv_linded`, `bfvietnam`, or `bfv_lnxded` is running. `start_period` is 180 seconds.

## Compose

```bash
docker compose -f bfv/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name bfv --restart unless-stopped --init \
  -p 4755:4755/udp -p 27900:27900/udp \
  -v "$PWD/bfv/data:/opt/bfv" \
  -e BFV_EXTRA_ARGS="" \
  {{IMAGE_PREFIX}}/bfv:latest
```
