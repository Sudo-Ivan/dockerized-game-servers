---
title: Vintage Story
description: Vintage Story dedicated server downloaded from the official CDN.
iconFit: contain
---

On first start the container downloads the official Linux server package from [cdn.vintagestory.at](https://cdn.vintagestory.at/) and runs it with .NET 10. Vintage Story 1.22 and later require .NET 10. No Steam account is required. The server writes `serverconfig.json`, world saves, and mod folders under your data volume on first launch.

:::note[Before you start]
- Mount `dockerized/vintage-story/data` for `serverconfig.json`, `Saves/`, `Mods/`, and other persistent files
- Open TCP and UDP port 42420 (Vintage Story 1.20+ uses both)
- Changing `VS_VERSION` triggers a server reinstall. Set `VS_FORCE_UPDATE=true` to reinstall the same version again
- Stop the server before editing `serverconfig.json`. Most changes need a restart to apply
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 42420 | TCP | Game port (PORT) |
| 42420 | UDP | Game port (PORT, required on 1.20+) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| VS_VERSION | 1.22.6 | Server version used in the download URL |
| VS_BRANCH | stable | Release branch in the download URL (`stable` or `unstable`) |
| VS_DOWNLOAD_URL | https://cdn.vintagestory.at/gamefiles/${VS_BRANCH}/vs_server_linux-x64_${VS_VERSION}.tar.gz | Override the download URL directly. Ignores VS_VERSION and VS_BRANCH when set |
| VS_FORCE_UPDATE | false | Force a reinstall even if the installed version already matches VS_VERSION |
| SERVER_NAME | Vintage Story Server | Server name (used when creating serverconfig.json on first start) |
| SERVER_DESCRIPTION | Vintage Story dedicated server | Public listing description (first start only) |
| SERVER_MOTD | Welcome {0}, may you survive well and prosper | Join message (first start only) |
| SERVER_PASSWORD | (empty) | Join password. Leave empty for an open server |
| MAX_PLAYERS | 16 | Player cap (MAX_CLIENTS) |
| PORT | 42420 | Game TCP and UDP port |
| BIND | 0.0.0.0 | Bind address |
| ADVERTISE_SERVER | false | List on the public master server |
| VS_EXTRA_ARGS | (empty) | Extra arguments passed to VintagestoryServer.dll, space-separated |

Environment variables for name, MOTD, password, and advertise apply only when `serverconfig.json` does not exist yet. After the first run, edit `serverconfig.json` directly.

Grant yourself admin rights with `/op <playername>` in the server console, or set `"StartupCommands": "/op <playername>"` in `serverconfig.json` before the first start. See the [Vintage Story multiplayer guide](https://wiki.vintagestory.at/Setting_up_a_Multiplayer_Server).

## Data folder and file layout

Mount `dockerized/vintage-story/data` at `/opt/vintage-story/data` (`--dataPath`). Typical paths:

| Path | Purpose |
| --- | --- |
| serverconfig.json | Main server settings. Created on first start |
| Saves/ | World saves |
| Mods/ | Drop mod `.zip` files here while the server is stopped |
| Logs/ | Server log files |
| Playerdata/ | Player data |

Server binaries are installed under `/opt/vintage-story/server` inside the container and are replaced when you change `VS_VERSION` or set `VS_FORCE_UPDATE`.

## Updates

Set `VS_FORCE_UPDATE` to `true` and recreate the container, or change `VS_VERSION` to trigger a reinstall. See [Ops](/guides/ops/) for the update command and backup tips.

## Health check

The container reports healthy while the Vintage Story server process is running. Startup gets a 300 second grace period for the first download.

## Compose

```bash
docker compose -f dockerized/vintage-story/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name vintage-story --restart unless-stopped --init \
  -p 42420:42420/tcp -p 42420:42420/udp \
  -v "$PWD/dockerized/vintage-story/data:/opt/vintage-story/data" \
  {{IMAGE_PREFIX}}/vintage-story:latest
```

The included compose file caps the container at 6144 MB of memory. Vintage Story recommends about 1 GB base RAM plus 300 MB per connected player.
