---
title: OpenMoHAA
description: OpenMoHAA dedicated server, requires your own Medal of Honor Allied Assault game assets.
---

[OpenMoHAA](https://github.com/openmoh/openmohaa) is an open re-implementation of the Medal of Honor: Allied Assault dedicated server. The image bundles the server binary from an upstream release, but not the game's data files. You must own Allied Assault and copy the PK3 files into the data folder yourself.

:::note[Before you start]
- Keep a data folder for game assets, config, and mods
- Copy main/Pak*.pk3 (and mainta/, maintt/ for expansions) from your owned install before first start
- Open UDP port 12203 for game traffic and UDP 12300 for GameSpy queries
:::

## Game data (required)

Copy folders from your owned install into openmohaa/data/:

```text
openmohaa/data/
  main/     Pak*.pk3 from Allied Assault (required)
  mainta/   pak*.pk3 from Spearhead (optional)
  maintt/   pak*.pk3 from Breakthrough (optional)
  home/     per-user overrides, mods, and the generated server config
```

sound/ and video/ are not needed for a dedicated server. On every start the container checks for .pk3 files in main/, mainta/, and maintt/ and exits with an error if none are found. Custom PK3s can go under home/main, home/mainta, or home/maintt. See the [upstream server container docs](https://github.com/openmoh/openmohaa/tree/main/container/server) and [docs.openmohaa.org](https://docs.openmohaa.org/).

If home/main/settings/server.cfg is missing, the container writes a minimal default:

```text
set sv_hostname "OpenMoHAA Server"
set sv_maxclients 16
set g_gametype 0
map mohdm1
```

Edit that file for hostname, map rotation, and game rules. The container only writes it once and never overwrites an existing one.

## Tuning the server

The generated file only sets three options. Everything else is a normal console variable you add with set, one per line, or exec a second file from inside it. Useful ones beyond the default:

| Option | What it does |
| --- | --- |
| g_password | Password required to join, leave empty for a public server |
| sv_privateclients / sv_privatepassword | Reserve slots behind a separate password for admins or VIPs |
| rconpassword | Enables remote console admin commands |
| sv_netoptimize | Reduces bandwidth and makes wallhacking harder |
| net_enabled | 1 IPv4 only, 2 IPv6 only, 3 both |
| sv_maxRate / sv_minRate | Per-client bandwidth caps |
| fraglimit / timelimit / roundlimit | Match end conditions |
| sv_maplist | Map rotation list |
| g_navigation_legacy 1 | Enables bot navigation on stock maps with the mp-navigation pk3 |

IP bans persist in serverbans.dat and are managed with banuser, banip, and rehashbans. The full option list is in [OpenMoHAA's docs](https://docs.openmohaa.org/).

Changes to server.cfg only take effect on restart.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 12203 | UDP | Game port (MOH_GAME_PORT) |
| 12300 | UDP | GameSpy query port (MOH_GAMESPY_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| OPENMOHAA_VERSION | v0.82.1 | Upstream release tag to download |
| OPENMOHAA_FORCE_UPDATE | false | Re-download the server binary even if the version already matches |
| MOH_GAME_PORT | 12203 | Game UDP port |
| MOH_GAMESPY_PORT | 12300 | GameSpy query UDP port |
| MOH_TARGET_GAME | 0 | Base game slot (0 for Allied Assault) |
| MOH_SERVER_CFG | server.cfg | Config filename under home/main/settings/ |
| MOH_EXTRA_ARGS | (empty) | Extra console arguments appended on start |

Any arguments you append to the container command in compose are added after MOH_EXTRA_ARGS.

## Data folder

Your data folder mounts at /usr/local/share/mohaa. This single folder holds both the game assets you provide and the server's writable state:

| Path | Purpose |
| --- | --- |
| main/, mainta/, maintt/ | Your PK3 game assets (required) |
| home/main/settings/server.cfg | Server config, auto-created once if missing |
| home/ | Save state, logs, and mod overrides written by the server |

## Updates

Set OPENMOHAA_FORCE_UPDATE to true to re-download the server binary on the next recreate. You can also run ./tools/gs update openmohaa. See [Ops](/guides/ops/). This only updates the server binary. Your PK3 game assets are yours to manage and are never touched.

## Health check

The container sends a UDP status query to the game port and checks for a valid response. Startup gets a 60 second grace period.

## Compose

```bash
docker compose -f openmohaa/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name openmohaa --restart unless-stopped --init \
  -p 12203:12203/udp -p 12300:12300/udp \
  -v "$PWD/openmohaa/data:/usr/local/share/mohaa" \
  {{IMAGE_PREFIX}}/openmohaa:latest
```

Populate openmohaa/data/main (and expansion folders if needed) before starting. Otherwise the container exits immediately. The shipped compose file caps memory at 2048 MB.
