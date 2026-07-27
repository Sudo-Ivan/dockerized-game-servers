---
title: Call of Duty 4
description: Call of Duty 4 dedicated server via CoD4x, built from the LinuxGSM archive.
---

Compose path: cod4. Image: cod4.

Built on the shared [runtime-base](/reference/images/) image. The Dockerfile bakes the LinuxGSM-hosted `cod4x18_lnxded` archive (CoD4x, `cod4x18_dedrun` binary) into the image as a seed, then copies that seed into the data volume the first time the container runs. You must own Call of Duty 4.

:::note[Requirements]
- You must own Call of Duty 4
- Persist `./data` for the server install and `server.cfg`
- Publish UDP **28960** (or your chosen `COD4_PORT`, both host and container side)
- Allocate at least 2 GB RAM for the container (the shipped compose file sets `mem_limit: 2048M`)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 28960 | UDP | Game traffic, `COD4_PORT` |

If you run more than one Call of Duty family server (cod, cod2, codwaw, cod4 all default to 28960/udp) on one host, change `COD4_PORT` and the matching compose/`-p` mapping so they do not collide.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `COD4_IP` | `0.0.0.0` | Bind address (`net_ip`) |
| `COD4_PORT` | `28960` | Game UDP port (`net_port`), applied on every start |
| `COD4_MAXPLAYERS` | `32` | Max clients (`sv_maxclients`), applied on every start |
| `COD4_STARTMAP` | `mp_crossfire` | Map loaded at boot (`+map`), applied on every start |
| `COD4_HOSTNAME` | `Call of Duty 4 Server` | Server browser name, written into `server.cfg` **only when the file is first created** |
| `COD4_EXTRA_ARGS` | (empty) | Extra `+set`/`+`-style flags appended to the launch command |

`COD4_IP`, `COD4_PORT`, `COD4_MAXPLAYERS`, and `COD4_STARTMAP` are passed on the command line every time the container starts, so changing them takes effect immediately on the next restart. `COD4_HOSTNAME` only affects a freshly generated `server.cfg`, changing it later has no effect until you delete `server.cfg` (or edit the `sv_hostname` line yourself).

The launcher always adds `sv_authorizemode -1`, the CoD4x equivalent of LAN-style auth, and `sv_punkbuster 0`. It also sets both `fs_basepath` and `fs_homepath` to the data directory, which the other games in this family do not do.

## Data volume

The data volume mounts to `/opt/cod4`. On first start (or whenever `.lgsm-seed-complete` or `cod4x18_dedrun` is missing from the volume), the entrypoint wipes anything already in the volume except `.gitkeep` and copies the baked-in seed over it.

`server.cfg` is generated once, only if it does not already exist, with:

```text
set sv_hostname "<COD4_HOSTNAME>"
set rcon_password "changeme"
```

Unlike cod, cod2, and codwaw, this generated config does not set `g_allowvote`. The rcon password is always `changeme` on a freshly generated config and there is no env var to set it. Edit `cod4/data/server.cfg` on the host (with the container stopped) to change the rcon password or add other server cvars, your edits persist across restarts since the entrypoint never rewrites an existing `server.cfg`.

## Updates

`ci/server-catalog.sh` lists no update env var for `cod4`, so `./tools/gs update cod4` is not available. See [Ops](../guides/ops/) for backup and restore, which do work for this server since it has a normal `data` volume. To pick up a newer archive you have to change the `LGSM_URL`/`LGSM_MD5` build args in the Dockerfile and rebuild the image.

## Healthcheck

`process` kind: the container is healthy while a `cod4x18_dedrun` process is running (`pgrep -f cod4x18_dedrun`). `start_period` is 120 seconds.

## Compose

```bash
docker compose -f cod4/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cod4 --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/cod4/data:/opt/cod4" \
  -e COD4_PORT=28960 \
  -e COD4_MAXPLAYERS=32 \
  -e COD4_STARTMAP=mp_crossfire \
  -e COD4_HOSTNAME="Call of Duty 4 Server" \
  {{IMAGE_PREFIX}}/cod4:latest
```
