---
title: Arma 3
description: Arma 3 dedicated server with SteamCMD and workshop preset sync.
---

Compose path: `arma/arma-3`. Image: `arma-3`.

Arma 3 dedicated server files (Steam App **233780**) usually require a Steam account that owns the server DLC, not anonymous SteamCMD. Set `STEAM_USERNAME`, `STEAM_PASSWORD`, and `STEAM_GUARD_CODE` when Steam Guard prompts during login.

## Volumes

| Host path | Container path | Purpose |
| --- | --- | --- |
| `arma/arma-3/server` | `/home/arma3/server` | Game binaries, workshop downloads, optional mod preset |
| `arma/arma-3/configs` | `/home/arma3/configs` | `server.cfg` and mission paths |
| `arma/arma-3/profiles` | `/home/arma3/profiles` | Server profile (`-name=server`) |
| `arma/arma-3/cache` | `/home/arma3/cache` | SteamCMD download cache |

The entrypoint runs `arma3server_x64` with `-config=/home/arma3/configs/server.cfg`, UDP port **2302**, and `-profiles=/home/arma3/profiles`.

`ci/server-catalog.sh` lists `server`, `configs`, and `profiles` as the backup volumes for `./tools/gs backup arma-3`, `cache` is left out since it only holds the SteamCMD/workshop download cache and regenerates on the next sync. Arma 3 has no `update_envs` entry, so `./tools/gs update arma-3` is not available, see [Ops](/guides/ops/) for what does work.

## Ports

Publish UDP **2302-2306** (game and Steam query).

## Workshop preset (HTML)

Place an Arma 3 Launcher **HTML preset** on the server volume so the container can download mods from the Steam CDN at startup:

1. In Arma 3 Launcher, select mods, then export or save the mod list as HTML.
2. Copy that file to `arma/arma-3/server/modlist.html` (default path).
3. Start the container. The entrypoint parses workshop IDs from `filedetails/?id=…` links, downloads each mod under `server/workshop/<id>`, copies `.bikey` files into `server/keys`, and builds the `-mod=@id;@id;…` list.

Override the preset path with `MODLIST_FILE` if you keep the HTML elsewhere under `/home/arma3/server`.

:::note[Steam login for workshop]
Workshop sync uses the same `STEAM_USERNAME` / `STEAM_PASSWORD` as the server install. Anonymous login cannot download subscribed workshop items.
:::

## Extra mod lists

| Variable | Purpose |
| --- | --- |
| `CDLC` | Semicolon-separated Creator DLC mod folders (for example `@CSLA`) |
| `EXTRA_MODS` | Additional `-mod` tokens appended after workshop sync |
| `MODLIST_FILE` | Path to HTML preset (default `/home/arma3/server/modlist.html`) |

## server.cfg

Create `arma/arma-3/configs/server.cfg` before first start. Minimal example:

```cfg
hostname = "My Arma 3 Server";
password = "";
passwordAdmin = "changeme";
serverTime = "SystemTime";
maxPlayers = 32;
```

Point `template` / mission classes at missions you install under the server directory. The stock entrypoint uses `-world=empty` and `-filePatching` so unpacked missions and mods on the volume are visible to the server.

## Compose

```bash
export STEAM_USERNAME=youruser
export STEAM_PASSWORD=yourpass
docker compose -f arma/arma-3/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name arma3 --restart unless-stopped --init \
  -p 2302-2306:2302-2306/udp \
  -v "$PWD/arma/arma-3/server:/home/arma3/server" \
  -v "$PWD/arma/arma-3/configs:/home/arma3/configs" \
  -v "$PWD/arma/arma-3/profiles:/home/arma3/profiles" \
  -v "$PWD/arma/arma-3/cache:/home/arma3/cache" \
  -e STEAM_USERNAME=youruser \
  -e STEAM_PASSWORD=yourpass \
  -e MODLIST_FILE=/home/arma3/server/modlist.html \
  {{IMAGE_PREFIX}}/arma-3:latest
```

## Workshop CDN tuning

The Steam CDN client (`arma/arma-3/api/`) reads these for large mod lists, all set in `docker-compose.yml`:

| Variable | Default | Purpose |
| --- | --- | --- |
| `ARMA_DOWNLOAD_MAX_WORKERS` | `4` | Parallel CDN download workers |
| `ARMA_DOWNLOAD_CHUNK_SIZE` | `4194304` | Bytes per download chunk (4 MiB) |
| `ARMA_DOWNLOAD_PROGRESS_INTERVAL` | `60` | Seconds between download progress log lines |
| `ARMA_CDN_CLIENT_RETRIES` | `3` | Retries for a failed CDN client connection |
| `ARMA_CDN_CLIENT_BASE_DELAY` | `1.5` | Base backoff seconds between CDN client retries |
| `ARMA_CDN_OP_RETRIES` | `3` | Retries for a failed CDN manifest or file operation |
| `ARMA_CDN_OP_BASE_DELAY` | `1.5` | Base backoff seconds between CDN operation retries |

`ARMA_APP_ID` (default `233780`) overrides the Steam App ID used for both the server install and the workshop sync, only useful for testing against a different depot.

## See also

- [All servers](/reference/servers/) for the compose path and image name
- [Ops](/guides/ops/) for `./tools/gs backup` and `restore`
