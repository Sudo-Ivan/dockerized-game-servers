---
title: Arma 3
description: Arma 3 dedicated server with SteamCMD and workshop preset sync.
---

This image installs the Arma 3 dedicated server through SteamCMD and can download workshop mods from an HTML preset at startup. SteamCMD needs a Steam account that owns the server DLC. Anonymous login does not work.

:::note[Before you start]
- Keep separate folders for server files, configs, profiles, and cache (see Data folders below)
- Open UDP ports 2302 through 2306
- Set STEAM_USERNAME, STEAM_PASSWORD, and STEAM_GUARD_CODE when Steam Guard prompts during login
- Create dockerized/arma/arma-3/configs/server.cfg before first start
:::

## Data folders

| Host path | Container path | Purpose |
| --- | --- | --- |
| dockerized/arma/arma-3/server | /home/arma3/server | Game binaries, workshop downloads, optional mod preset |
| dockerized/arma/arma-3/configs | /home/arma3/configs | server.cfg and mission paths |
| dockerized/arma/arma-3/profiles | /home/arma3/profiles | Server profile |
| dockerized/arma/arma-3/cache | /home/arma3/cache | SteamCMD download cache |

The server launches with -config pointing at configs/server.cfg, UDP port from ARMA_PORT (default 2302), and -profiles pointing at the profiles folder.

## Workshop preset (HTML)

Place an Arma 3 Launcher HTML preset on the server volume so the container can download mods from the Steam CDN at startup:

1. In Arma 3 Launcher, select mods, then export or save the mod list as HTML.
2. Copy that file to dockerized/arma/arma-3/server/modlist.html (default path).
3. Start the container. It parses workshop IDs from the HTML, downloads each mod, copies key files into server/keys, and builds the mod list.

Override the preset path with MODLIST_FILE if you keep the HTML elsewhere under the server folder.

:::note[Steam login for workshop]
Workshop sync uses the same STEAM_USERNAME and STEAM_PASSWORD as the server install. Anonymous login cannot download subscribed workshop items.
:::

## Extra mod settings

| Setting | What it does |
| --- | --- |
| CDLC | Semicolon-separated Creator DLC mod folders (for example @CSLA) |
| EXTRA_MODS | Additional mod tokens appended after workshop sync |
| MODLIST_FILE | Path to HTML preset (default /home/arma3/server/modlist.html) |

## server.cfg

Create dockerized/arma/arma-3/configs/server.cfg before first start. Minimal example:

```cfg
hostname = "My Arma 3 Server";
password = "";
passwordAdmin = "changeme";
serverTime = "SystemTime";
maxPlayers = 32;
```

Point template and mission classes at missions you install under the server directory. The server starts with -world from ARMA_WORLD (default empty) and -filePatching so unpacked missions and mods on the volume are visible.

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| ARMA_PORT | 2302 | UDP game port passed to -port |
| ARMA_WORLD | empty | World name passed to -world |
| ARMA_APP_ID | 233780 | Steam App ID for server install and workshop sync |
| ARMA_DOWNLOAD_MAX_WORKERS | 4 | Parallel CDN download workers |
| ARMA_DOWNLOAD_CHUNK_SIZE | 4194304 | Bytes per download chunk (4 MiB) |
| ARMA_DOWNLOAD_PROGRESS_INTERVAL | 60 | Seconds between download progress log lines |
| ARMA_CDN_CLIENT_RETRIES | 3 | Retries for a failed CDN client connection |
| ARMA_CDN_CLIENT_BASE_DELAY | 1.5 | Base backoff seconds between CDN client retries |
| ARMA_CDN_OP_RETRIES | 3 | Retries for a failed CDN manifest or file operation |
| ARMA_CDN_OP_BASE_DELAY | 1.5 | Base backoff seconds between CDN operation retries |

## Compose

```bash
export STEAM_USERNAME=youruser
export STEAM_PASSWORD=yourpass
docker compose -f dockerized/arma/arma-3/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name arma3 --restart unless-stopped --init \
  -p 2302-2306:2302-2306/udp \
  -v "$PWD/dockerized/arma/arma-3/server:/home/arma3/server" \
  -v "$PWD/dockerized/arma/arma-3/configs:/home/arma3/configs" \
  -v "$PWD/dockerized/arma/arma-3/profiles:/home/arma3/profiles" \
  -v "$PWD/dockerized/arma/arma-3/cache:/home/arma3/cache" \
  -e STEAM_USERNAME=youruser \
  -e STEAM_PASSWORD=yourpass \
  -e MODLIST_FILE=/home/arma3/server/modlist.html \
  {{IMAGE_PREFIX}}/arma-3:latest
```

## Backup and updates

`./tools/gs backup arma-3` archives server, configs, and profiles. The cache folder is skipped because it rebuilds on the next sync. `./tools/gs update arma-3` is not supported.

## See also

- [All servers](/reference/servers/) for compose paths and image names
- [Ops](/guides/ops/) for backup, restore, and which servers support update
