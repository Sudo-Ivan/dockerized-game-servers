---
title: OpenMoHAA
description: Medal of Honor Allied Assault dedicated server (OpenMoHAA).
---

Compose path: openmohaa. Image: openmohaa.

[OpenMoHAA](https://github.com/openmoh/openmohaa) is an open re-implementation of Medal of Honor: Allied Assault. The container ships the Linux dedicated binary from upstream releases. **You must provide your own licensed game assets** (PK3 files from Allied Assault and any expansions you host). The image does not include EA game data.

## Game data (required)

Mount `openmohaa/data` at `/usr/local/share/mohaa` and copy folders from your owned install:

```text
openmohaa/data/
  main/     Pak*.pk3 from Allied Assault
  mainta/   pak*.pk3 from Spearhead (optional unless you run expansion content)
  maintt/   pak*.pk3 from Breakthrough (optional unless you run expansion content)
  home/     per-user overrides and mods (optional)
```

`sound` and `video` directories are not required for a dedicated server. Custom PK3s can go under `home/main`, `home/mainta`, or `home/maintt` as described in the [upstream server container docs](https://github.com/openmoh/openmohaa/tree/main/container/server).

On first start, if `home/main/settings/server.cfg` is missing, the entrypoint writes a small default config. Edit that file for hostname, map rotation, and game rules. Upstream server notes: [docs.openmohaa.org](https://docs.openmohaa.org/).

## Ports and volume

- UDP 12203 game port (`MOH_GAME_PORT`)
- UDP 12300 GameSpy port (`MOH_GAMESPY_PORT`)
- Data volume: `openmohaa/data` mounted at `/usr/local/share/mohaa`

`OPENMOHAA_VERSION` defaults to `v0.82.1`. Set `OPENMOHAA_FORCE_UPDATE=true` to re-download the binary on start. `MOH_TARGET_GAME` selects the base game slot (default `0` for Allied Assault). Extra console arguments: `MOH_EXTRA_ARGS`.

## Docker run

```bash
docker run -d --name openmohaa --restart unless-stopped --init \
  -p 12203:12203/udp -p 12300:12300/udp \
  -v "$PWD/openmohaa/data:/usr/local/share/mohaa" \
  {{IMAGE_PREFIX}}/openmohaa:latest
```

Populate `openmohaa/data/main` (and expansion folders as needed) **before** the server can stay healthy.
