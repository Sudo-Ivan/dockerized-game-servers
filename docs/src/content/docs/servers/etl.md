---
title: 'ET: Legacy'
description: ET Legacy dedicated server built from the GameServerManagers etlserver-build bundle.
---

This image ships with an ET: Legacy server bundle built in. On first run the files are copied into your data folder. Wolfenstein: Enemy Territory was released as a free standalone game, so you do not need to own a copy. The bundle already includes the pak files the server needs.

:::note[Before you start]
- Keep a data folder for the server install and etmain/server.cfg
- Open UDP port 27960, and UDP 27961 if your tooling expects a second port (the server process only listens on ETL_PORT)
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27960 | UDP | Game traffic (ETL_PORT) |
| 27961 | UDP | Exposed for compatibility. The server process does not bind to this port. |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| ETL_IP | 0.0.0.0 | Bind address, applied on every start |
| ETL_PORT | 27960 | Game UDP port, applied on every start |
| ETL_MAXPLAYERS | 32 | Max players, written into server.cfg only when that file is first created |
| ETL_STARTMAP | oasis | Map loaded at boot, applied on every start |
| ETL_GAMETYPE | 4 | Game type (4 is Objective), written into server.cfg only when that file is first created |
| ETL_HOSTNAME | ET: Legacy Server | Server browser name, written into server.cfg only when that file is first created |
| ETL_EXTRA_ARGS | (empty) | Extra launch flags appended to the start command |
| ETL_FORCE_UPDATE | false | Re-downloads the server bundle and overwrites the entire data folder on next start |

ETL_IP, ETL_PORT, and ETL_STARTMAP take effect on every start. ETL_MAXPLAYERS, ETL_GAMETYPE, and ETL_HOSTNAME only matter when etmain/server.cfg is generated for the first time.

## Data folder

Your data folder mounts to /opt/etl inside the container. On first start (or if key files are missing), the container copies the built-in server files into that folder.

etmain/server.cfg is created once if it does not exist:

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

Both rcon and referee passwords default to changeme. Edit etl/data/etmain/server.cfg on the host with the container stopped to change them or any other option. Your edits persist because an existing server.cfg is never overwritten.

The copied tree also includes legacy mod assets, omni-bot files, and map rotation configs under etmain/ that you can edit directly.

## Updates

./tools/gs update etl works for this server. See [Ops](../guides/ops/). Setting ETL_FORCE_UPDATE to true re-downloads the bundle and overwrites the entire data folder, including server.cfg. Back up custom configs first if you use this.

## Health check

The container reports healthy while the game server process is running. Startup gets a 120 second grace period.

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
