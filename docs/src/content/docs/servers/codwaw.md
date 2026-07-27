---
title: 'Call of Duty: World at War'
description: Call of Duty World at War dedicated server built from the LinuxGSM 1.7 archive.
---

Compose path: codwaw. Image: codwaw.

Built on the shared [runtime-base](/reference/images/) image. The Dockerfile bakes the LinuxGSM-hosted `codwaw-lnxded-1.7-full` archive into the image as a seed, then copies that seed into the data volume the first time the container runs. You must own Call of Duty: World at War.

:::note[Requirements]
- You must own Call of Duty: World at War
- Persist `./data` for the server install and `server.cfg` (about 8 GB after seeding)
- Publish UDP **28960** (or your chosen `CODWAW_PORT`, both host and container side)
- Allocate at least 2 GB RAM for the container (the shipped compose file sets `mem_limit: 2048M`)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 28960 | UDP | Game traffic, `CODWAW_PORT` |

If you run more than one Call of Duty family server (cod, cod2, codwaw, cod4 all default to 28960/udp) on one host, change `CODWAW_PORT` and the matching compose/`-p` mapping so they do not collide.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `CODWAW_IP` | `0.0.0.0` | Bind address (`net_ip`) |
| `CODWAW_PORT` | `28960` | Game UDP port (`net_port`), applied on every start |
| `CODWAW_MAXPLAYERS` | `20` | Max clients (`sv_maxclients`), applied on every start |
| `CODWAW_STARTMAP` | `mp_castle` | Map loaded at boot (`+map`), applied on every start |
| `CODWAW_HOSTNAME` | `Call of Duty: World at War Server` | Server browser name, written into `server.cfg` **only when the file is first created** |
| `CODWAW_EXTRA_ARGS` | (empty) | Extra `+set`/`+`-style flags appended to the launch command |

`CODWAW_IP`, `CODWAW_PORT`, `CODWAW_MAXPLAYERS`, and `CODWAW_STARTMAP` are passed on the command line every time the container starts, so changing them takes effect immediately on the next restart. `CODWAW_HOSTNAME` only affects a freshly generated `server.cfg`, changing it later has no effect until you delete `server.cfg` (or edit the `sv_hostname` line yourself).

## Data volume

The data volume mounts to `/opt/codwaw`. On first start (or whenever `.lgsm-seed-complete` or `codwaw_lnxded` is missing from the volume), the entrypoint wipes anything already in the volume except `.gitkeep` and copies the baked-in seed over it.

`server.cfg` is generated once, only if it does not already exist, with:

```text
set sv_hostname "<CODWAW_HOSTNAME>"
set rcon_password "changeme"
set g_allowvote 1
```

The rcon password is always `changeme` on a freshly generated config and there is no env var to set it. Edit `codwaw/data/server.cfg` on the host (with the container stopped) to change the rcon password, the vote setting, or add other server cvars, your edits persist across restarts since the entrypoint never rewrites an existing `server.cfg`.

Punkbuster is force-disabled (`sv_punkbuster 0`) and `com_hunkMegs` is fixed at 128.

## Updates

`ci/server-catalog.sh` lists no update env var for `codwaw`, so `./tools/gs update codwaw` is not available. See [Ops](../guides/ops/) for backup and restore, which do work for this server since it has a normal `data` volume. To pick up a newer archive you have to change the `LGSM_URL`/`LGSM_MD5` build args in the Dockerfile and rebuild the image.

## Healthcheck

`process` kind: the container is healthy while a `codwaw_lnxded` process is running (`pgrep -f codwaw_lnxded`). `start_period` is 120 seconds.

## Compose

```bash
docker compose -f codwaw/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name codwaw --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/codwaw/data:/opt/codwaw" \
  -e CODWAW_PORT=28960 \
  -e CODWAW_MAXPLAYERS=20 \
  -e CODWAW_STARTMAP=mp_castle \
  -e CODWAW_HOSTNAME="Call of Duty: World at War Server" \
  {{IMAGE_PREFIX}}/codwaw:latest
```
