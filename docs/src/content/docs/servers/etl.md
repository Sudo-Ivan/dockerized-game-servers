---
title: 'ET: Legacy'
description: ET Legacy dedicated server built from the GameServerManagers etlserver-build bundle.
---

Compose path: etl. Image: etl.

Built on the shared [runtime-base](/reference/images/) image. The Dockerfile bakes a bundle from [GameServerManagers etlserver-build](https://github.com/GameServerManagers/etlserver-build) (`etlegacy-latest-i386-et-260b`) into the image as a seed, then copies that seed into the data volume the first time the container runs. You must own Wolfenstein: Enemy Territory (ET: Legacy is a free, open-source engine rebuild but still expects the original game's assets in some setups, check the etlserver-build release notes for your target version).

:::note[Requirements]
- Persist `./data` for the server install and `etmain/server.cfg`
- Publish UDP **27960**, and UDP **27961** if you rely on tooling that expects a second port (the server process itself only listens on `ETL_PORT`)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27960 | UDP | Game traffic, `ETL_PORT` |
| 27961 | UDP | Exposed by the Dockerfile and compose file for compatibility, but the entrypoint never binds anything to it, `etlded` only listens on `ETL_PORT` |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `ETL_IP` | `0.0.0.0` | Bind address (`net_ip`), applied on every start |
| `ETL_PORT` | `27960` | Game UDP port (`net_port`), applied on every start |
| `ETL_MAXPLAYERS` | `32` | Max clients (`sv_maxclients`), written into `server.cfg` **only when the file is first created** |
| `ETL_STARTMAP` | `oasis` | Map loaded at boot (`+map`), applied on every start |
| `ETL_GAMETYPE` | `4` | Game type (`g_gametype`, `4` is Objective), written into `server.cfg` **only when the file is first created** |
| `ETL_HOSTNAME` | `ET: Legacy Server` | Server browser name, written into `server.cfg` **only when the file is first created** |
| `ETL_EXTRA_ARGS` | (empty) | Extra `+set`/`+`-style flags appended to the launch command |
| `ETL_FORCE_UPDATE` | `false` | Re-downloads the etlserver-build bundle and overwrites the entire data volume with it on next start |

`ETL_IP`, `ETL_PORT`, and `ETL_STARTMAP` are passed on the command line every time the container starts. `ETL_MAXPLAYERS`, `ETL_GAMETYPE`, and `ETL_HOSTNAME` only affect a freshly generated `server.cfg`, changing them later has no effect until you delete `etmain/server.cfg` (or edit the relevant line yourself).

## Data volume

The data volume mounts to `/opt/etl`. On first start (or whenever `.lgsm-seed-complete` or `etlded` is missing from the volume), the entrypoint wipes anything already in the volume except `.gitkeep` and copies the baked-in seed over it.

`etmain/server.cfg` is generated once, only if it does not already exist, with:

```text
set com_hunkMegs "56"
set sv_hostname "<ETL_HOSTNAME>"
set g_password ""
set sv_privateclients 0
set g_gametype <ETL_GAMETYPE>
set g_antilag 1
set sv_maxclients <ETL_MAXPLAYERS>
set rconpassword "changeme"
set refereePassword "changeme"
set g_allowvote 1
set net_port <ETL_PORT>
```

Both `rconpassword` and `refereePassword` are always `changeme` on a freshly generated config and there is no env var to set either. Edit `etl/data/etmain/server.cfg` on the host (with the container stopped) to change them or any other server cvar, your edits persist across restarts since the entrypoint never rewrites an existing `server.cfg`.

The seeded tree also ships `legacy/` (ET: Legacy mod assets, `legacy.cfg`, omni-bot files, Lua scripts for wolfadmin) and several rotation/cycle config files under `etmain/` (`mapvotecycle.cfg`, `campaigncycle.cfg`, `objectivecycle.cfg`, and so on) that you can edit directly.

## Updates

`ci/server-catalog.sh` lists `ETL_FORCE_UPDATE` as the update env var, so `./tools/gs update etl` works, see [Ops](../guides/ops/). Setting `ETL_FORCE_UPDATE=true` re-downloads the bundle from `ETL_BUNDLE_URL` and copies it over the entire data directory (`cp -a`), which overwrites `etmain/server.cfg` and any other file the bundle ships with, back up custom configs first if you use this.

## Healthcheck

`process` kind: the container is healthy while an `etlded` process is running (`pgrep -f etlded`). `start_period` is 120 seconds.

## Compose

```bash
docker compose -f etl/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name etl --restart unless-stopped --init \
  -p 27960:27960/udp -p 27961:27961/udp \
  -v "$PWD/etl/data:/opt/etl" \
  -e ETL_PORT=27960 \
  -e ETL_MAXPLAYERS=32 \
  -e ETL_STARTMAP=oasis \
  -e ETL_GAMETYPE=4 \
  -e ETL_HOSTNAME="ET: Legacy Server" \
  {{IMAGE_PREFIX}}/etl:latest
```
