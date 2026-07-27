---
title: Return to Castle Wolfenstein
description: Return to Castle Wolfenstein dedicated server built from the LinuxGSM ioRTCW archive.
---

Compose path: rtcw. Image: rtcw.

Built on the shared [runtime-base](/reference/images/) image. The Dockerfile bakes the LinuxGSM-hosted `iortcw-1.51c-x86_64-server-linux` archive into the image as a seed, then copies that seed into the data volume the first time the container runs. You must own Return to Castle Wolfenstein.

:::note[Requirements]
- You must own Return to Castle Wolfenstein
- Persist `./data` for the server install and `main/server.cfg`
- Publish UDP **27960** (or your chosen `RTCW_PORT`, both host and container side)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27960 | UDP | Game traffic, `RTCW_PORT` |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `RTCW_IP` | `0.0.0.0` | Bind address (`net_ip`) |
| `RTCW_PORT` | `27960` | Game UDP port (`net_port`), applied on every start |
| `RTCW_MAXPLAYERS` | `32` | Max clients (`sv_maxclients`), written into `server.cfg` **only when the file is first created** |
| `RTCW_STARTMAP` | `mp_beach` | Map loaded at boot (`+map`), applied on every start |
| `RTCW_HOSTNAME` | `Return to Castle Wolfenstein Server` | Server browser name, written into `server.cfg` **only when the file is first created** |
| `RTCW_EXTRA_ARGS` | (empty) | Extra `+set`/`+`-style flags appended to the launch command |

Unlike the Call of Duty family, RTCW's launch command never passes `sv_maxclients` on the command line, so `RTCW_MAXPLAYERS` only takes effect the first time `main/server.cfg` is generated. Changing it afterward does nothing until you delete `main/server.cfg` (or edit the `sv_maxclients` line yourself). The same is true for `RTCW_HOSTNAME`. `RTCW_IP`, `RTCW_PORT`, and `RTCW_STARTMAP` are applied every start since they are passed directly on the command line.

## Data volume

The data volume mounts to `/opt/rtcw`. On first start (or whenever `.lgsm-seed-complete` or `iowolfded.x86_64` is missing from the volume), the entrypoint wipes anything already in the volume except `.gitkeep` and copies the baked-in seed over it.

`main/server.cfg` is generated once, only if it does not already exist, with:

```text
set sv_hostname "<RTCW_HOSTNAME>"
set rcon_password "changeme"
set g_allowvote 1
set sv_maxclients <RTCW_MAXPLAYERS>
```

The rcon password is always `changeme` on a freshly generated config and there is no env var to set it. Edit `rtcw/data/main/server.cfg` on the host (with the container stopped) to change the rcon password, max clients, or add other server cvars, your edits persist across restarts since the entrypoint never rewrites an existing `server.cfg`.

The seeded tree also carries a `pb/` Punkbuster directory and `Docs/` from the ioRTCW release, both are inert unless you wire Punkbuster up yourself, the launch command sets `sv_punkbuster 0`.

## Updates

`ci/server-catalog.sh` lists no update env var for `rtcw`, so `./tools/gs update rtcw` is not available. See [Ops](../guides/ops/) for backup and restore, which do work for this server since it has a normal `data` volume. To pick up a newer archive you have to change the `LGSM_URL`/`LGSM_MD5` build args in the Dockerfile and rebuild the image.

## Healthcheck

`process` kind: the container is healthy while a process matching `iowolfded` is running (`pgrep -f iowolfded`). `start_period` is 120 seconds.

## Compose

```bash
docker compose -f rtcw/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name rtcw --restart unless-stopped --init \
  -p 27960:27960/udp \
  -v "$PWD/rtcw/data:/opt/rtcw" \
  -e RTCW_PORT=27960 \
  -e RTCW_MAXPLAYERS=32 \
  -e RTCW_STARTMAP=mp_beach \
  -e RTCW_HOSTNAME="Return to Castle Wolfenstein Server" \
  {{IMAGE_PREFIX}}/rtcw:latest
```
