---
title: Home
description: Docker images and compose files for dedicated game servers.
template: splash
editUrl: false
lastUpdated: false
hero:
  title: Dockerized Game Servers
  tagline: Compose files and GHCR images for 50+ dedicated servers, including Minecraft, Valheim, Palworld, and DayZ.
  actions:
    - text: Quick start
      link: /guides/quick-start/
      icon: right-arrow
    - text: Browse all servers
      link: /reference/servers/
      variant: minimal
---

Each game has a folder under `dockerized/` with a Dockerfile, compose file, and a `data/` volume for saves and config. Published images live on GHCR. Set `IMAGE_OWNER` to your fork if you publish your own builds.

## Compared to a manual install

- Same compose layout for every game: `docker compose -f dockerized/<game>/docker-compose.yml up`
- Saves and configs stay on disk in `./data`, or in game-specific paths (Arma 3 splits server, configs, and profiles)
- `./tools/gs` backs up, restores, and updates most servers from the host
- Runs on any machine with Docker Engine, including a VPS

License is 0BSD. Fork it, self-host the docs, publish your own images.

## Popular servers

| Game | Guide |
| --- | --- |
| Minecraft (Vanilla, Fabric, Forge, NeoForge) | [Guide](servers/minecraft/) |
| Valheim | [Guide](servers/valheim/) |
| Palworld | [Guide](servers/palworld/) |
| 7 Days to Die | [Guide](servers/7-days-to-die/) |
| Project Zomboid | [Guide](servers/project-zomboid/) |
| DayZ | [Guide](servers/dayz/) |
| Terraria | [Guide](servers/terraria/) |
| Factorio | [Guide](servers/factorio/) |

[All servers](reference/servers/) lists every compose path and image name.

## Browser generators

The [Tools](tools/) page builds `server.properties`, Arma 3 `server.cfg`, and docker run or compose snippets in the browser. Nothing is uploaded.

## Getting a server running

1. Pick a game from [All servers](reference/servers/).
2. Copy the compose command from that game's guide.
3. Run it. Friends connect to your public IP on the ports listed on the guide page.

Full walkthrough: [Quick start](guides/quick-start/).

## Images and CI

First-party images share bases under `dockerized/bases/`: `minecraft-base` (Java), `steam-base` (SteamCMD), and `runtime-base` (Debian slim for non-Steam binaries). See [Images](reference/images/) for GHCR names and [CI](reference/ci/) for build and publish workflows.
