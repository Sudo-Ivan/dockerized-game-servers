---
title: 'Quake 3: Arena'
description: Quake 3 Arena dedicated server built from the LinuxGSM 1.32c archive.
---

Compose path: quake3. Image: quake3.

Built on the shared [runtime-base](/reference/images/) image. The Dockerfile bakes the LinuxGSM-hosted `quake3-1.32c-x86-full-linux` archive into the image as a seed, then copies that seed into the data volume the first time the container runs. You must own Quake 3 Arena.

:::note[Requirements]
- You must own Quake 3 Arena
- Persist `./data` for the server install and `server.cfg`
- Publish UDP **27960** (or your chosen `Q3_PORT`, both host and container side)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27960 | UDP | Game traffic, `Q3_PORT` |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `Q3_IP` | `0.0.0.0` | Bind address (`net_ip`) |
| `Q3_PORT` | `27960` | Game UDP port (`net_port`), applied on every start |
| `Q3_STARTMAP` | `q3dm17` | Map loaded at boot (`+map`), applied on every start |
| `Q3_HOSTNAME` | `Quake 3 Arena Server` | Server browser name, written into `server.cfg` **only when the file is first created** |
| `Q3_EXTRA_ARGS` | (empty) | Extra `+set`/`+`-style flags appended to the launch command |

There is no `Q3_MAXPLAYERS` variable, id Tech 3's own `sv_maxclients` default (20) applies unless you set it yourself through `Q3_EXTRA_ARGS` or `server.cfg`. `Q3_IP`, `Q3_PORT`, and `Q3_STARTMAP` are passed on the command line every time the container starts. `Q3_HOSTNAME` only affects a freshly generated `server.cfg`, changing it later has no effect until you delete `server.cfg` (or edit the `sv_hostname` line yourself).

## Data volume

The data volume mounts to `/opt/quake3`. On first start (or whenever `.lgsm-seed-complete` or `q3ded` is missing from the volume), the entrypoint wipes anything already in the volume except `.gitkeep` and copies the baked-in seed over it.

`server.cfg` is generated once, only if it does not already exist, with:

```text
set sv_hostname "<Q3_HOSTNAME>"
set g_allowvote 1
```

There is no `rcon_password` line in the generated config, so remote console is disabled until you add one yourself. Edit `quake3/data/server.cfg` on the host (with the container stopped) to set an rcon password or add other server cvars, your edits persist across restarts since the entrypoint never rewrites an existing `server.cfg`.

Punkbuster is force-disabled (`sv_punkbuster 0`) and `com_hunkMegs` is fixed at 32.

## Updates

`ci/server-catalog.sh` lists no update env var for `quake3`, so `./tools/gs update quake3` is not available. See [Ops](../guides/ops/) for backup and restore, which do work for this server since it has a normal `data` volume. To pick up a newer archive you have to change the `LGSM_URL`/`LGSM_MD5` build args in the Dockerfile and rebuild the image.

## Healthcheck

`process` kind: the container is healthy while a `q3ded` process is running (`pgrep -f q3ded`). `start_period` is 120 seconds.

## Compose

```bash
docker compose -f quake3/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name quake3 --restart unless-stopped --init \
  -p 27960:27960/udp \
  -v "$PWD/quake3/data:/opt/quake3" \
  -e Q3_PORT=27960 \
  -e Q3_STARTMAP=q3dm17 \
  -e Q3_HOSTNAME="Quake 3 Arena Server" \
  {{IMAGE_PREFIX}}/quake3:latest
```
