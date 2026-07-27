---
title: Call of Duty 2
description: Call of Duty 2 dedicated server built from the LinuxGSM 1.3 archive.
---

Compose path: cod2. Image: cod2.

Built on the shared [runtime-base](/reference/images/) image. The Dockerfile bakes the LinuxGSM-hosted `cod2-lnxded-1.3-full` archive into the image as a seed, then copies that seed into the data volume the first time the container runs. You must own Call of Duty 2.

:::note[Requirements]
- You must own Call of Duty 2
- Persist `./data` for the server install and `server.cfg` (several GB after seeding)
- Publish UDP **28960** (or your chosen `COD2_PORT`, both host and container side)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 28960 | UDP | Game traffic, `COD2_PORT` |

If you run more than one Call of Duty family server (cod, cod2, codwaw, cod4 all default to 28960/udp) on one host, change `COD2_PORT` and the matching compose/`-p` mapping so they do not collide.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `COD2_IP` | `0.0.0.0` | Bind address (`net_ip`) |
| `COD2_PORT` | `28960` | Game UDP port (`net_port`), applied on every start |
| `COD2_MAXPLAYERS` | `20` | Max clients (`sv_maxclients`), applied on every start |
| `COD2_STARTMAP` | `mp_leningrad` | Map loaded at boot (`+map`), applied on every start |
| `COD2_HOSTNAME` | `Call of Duty 2 Server` | Server browser name, written into `server.cfg` **only when the file is first created** |
| `COD2_EXTRA_ARGS` | (empty) | Extra `+set`/`+`-style flags appended to the launch command |

`COD2_IP`, `COD2_PORT`, `COD2_MAXPLAYERS`, and `COD2_STARTMAP` are passed on the command line every time the container starts, so changing them takes effect immediately on the next restart. `COD2_HOSTNAME` only affects a freshly generated `server.cfg`, changing it later has no effect until you delete `server.cfg` (or edit the `sv_hostname` line yourself).

## Data volume

The data volume mounts to `/opt/cod2`. On first start (or whenever `.lgsm-seed-complete` or `cod2_lnxded` is missing from the volume), the entrypoint wipes anything already in the volume except `.gitkeep` and copies the baked-in seed over it.

`server.cfg` is generated once, only if it does not already exist, with:

```text
set sv_hostname "<COD2_HOSTNAME>"
set rcon_password "changeme"
set g_allowvote 1
```

The rcon password is always `changeme` on a freshly generated config and there is no env var to set it. Edit `cod2/data/server.cfg` on the host (with the container stopped) to change the rcon password, the vote setting, or add other server cvars, your edits persist across restarts since the entrypoint never rewrites an existing `server.cfg`.

Punkbuster is force-disabled (`sv_punkbuster 0`).

## Updates

`ci/server-catalog.sh` lists no update env var for `cod2`, so `./tools/gs update cod2` is not available. See [Ops](../guides/ops/) for backup and restore, which do work for this server since it has a normal `data` volume. To pick up a newer archive you have to change the `LGSM_URL`/`LGSM_MD5` build args in the Dockerfile and rebuild the image.

## Healthcheck

`process` kind: the container is healthy while a `cod2_lnxded` process is running (`pgrep -f cod2_lnxded`). `start_period` is 120 seconds.

## Compose

```bash
docker compose -f cod2/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cod2 --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/cod2/data:/opt/cod2" \
  -e COD2_PORT=28960 \
  -e COD2_MAXPLAYERS=20 \
  -e COD2_STARTMAP=mp_leningrad \
  -e COD2_HOSTNAME="Call of Duty 2 Server" \
  {{IMAGE_PREFIX}}/cod2:latest
```
