---
title: Call of Duty
description: Call of Duty (2003) dedicated server built from the LinuxGSM 1.5b archive.
---

Compose path: cod. Image: cod.

Built on the shared [runtime-base](/reference/images/) image. The Dockerfile bakes the LinuxGSM-hosted `cod-lnxded-1.5b-full` archive into the image as a seed, then copies that seed into the data volume the first time the container runs. You must own Call of Duty.

:::note[Requirements]
- You must own Call of Duty
- Persist `./data` for the server install and `server.cfg`
- Publish UDP **28960** (or your chosen `COD_PORT`, both host and container side)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 28960 | UDP | Game traffic, `COD_PORT` |

If you run more than one Call of Duty family server (cod, cod2, codwaw, cod4 all default to 28960/udp) on one host, change `COD_PORT` and the matching compose/`-p` mapping so they do not collide.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `COD_IP` | `0.0.0.0` | Bind address (`net_ip`) |
| `COD_PORT` | `28960` | Game UDP port (`net_port`), applied on every start |
| `COD_MAXPLAYERS` | `20` | Max clients (`sv_maxclients`), applied on every start |
| `COD_STARTMAP` | `mp_neuville` | Map loaded at boot (`+map`), applied on every start |
| `COD_HOSTNAME` | `Call of Duty Server` | Server browser name, written into `server.cfg` **only when the file is first created** |
| `COD_EXTRA_ARGS` | (empty) | Extra `+set`/`+`-style flags appended to the launch command |

`COD_IP`, `COD_PORT`, `COD_MAXPLAYERS`, and `COD_STARTMAP` are passed on the command line every time the container starts, so changing them takes effect immediately on the next restart. `COD_HOSTNAME` only affects a freshly generated `server.cfg`, changing it later has no effect until you delete `server.cfg` (or edit the `sv_hostname` line yourself).

## Data volume

The data volume mounts to `/opt/cod`. On first start (or whenever `.lgsm-seed-complete` or `cod_lnxded` is missing from the volume), the entrypoint wipes anything already in the volume except `.gitkeep` and copies the baked-in seed over it.

`server.cfg` is generated once, only if it does not already exist, with:

```text
set sv_hostname "<COD_HOSTNAME>"
set rcon_password "changeme"
set g_allowvote 1
```

The rcon password is always `changeme` on a freshly generated config and there is no env var to set it. Edit `cod/data/server.cfg` on the host (with the container stopped) to change the rcon password, the vote setting, or add other server cvars, your edits persist across restarts since the entrypoint never rewrites an existing `server.cfg`.

Punkbuster is force-disabled (`sv_punkbuster 0`) since Punkbuster's master servers for this game are long gone.

## Updates

`ci/server-catalog.sh` lists no update env var for `cod`, so `./tools/gs update cod` is not available. See [Ops](../guides/ops/) for backup and restore, which do work for this server since it has a normal `data` volume. To pick up a newer archive you have to change the `LGSM_URL`/`LGSM_MD5` build args in the Dockerfile and rebuild the image.

## Healthcheck

`process` kind: the container is healthy while a `cod_lnxded` process is running (`pgrep -f cod_lnxded`). `start_period` is 120 seconds.

## Compose

```bash
docker compose -f cod/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name cod --restart unless-stopped --init \
  -p 28960:28960/udp \
  -v "$PWD/cod/data:/opt/cod" \
  -e COD_PORT=28960 \
  -e COD_MAXPLAYERS=20 \
  -e COD_STARTMAP=mp_neuville \
  -e COD_HOSTNAME="Call of Duty Server" \
  {{IMAGE_PREFIX}}/cod:latest
```
