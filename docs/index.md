---
title: Home
description: Container images and compose files for dedicated game servers, built for Podman.
---

# Poderized Game Servers

Dedicated game servers as OCI container images with compose files, built and run with Podman. Every game has a folder under `poderized/` with a Containerfile, a compose file, and a data volume for saves and config. Published images live on GHCR. Set `IMAGE_OWNER` to your fork if you publish your own builds.

New here? [Quick start](guides/quick-start.md) walks through your first server. [All servers](reference/servers.md) lists every game with its compose path and image name.

## Compared to a manual install

- Same compose layout for every game: `podman compose -f poderized/<game>/compose.yml up`
- Saves and configs stay on disk in `./data`, or in game-specific paths (Arma 3 splits server, configs, and profiles)
- `./tools/gs` backs up, restores, and updates most servers from the host
- Runs on any machine with Podman, including a VPS

## Popular servers

| Game | Guide |
| --- | --- |
| Minecraft (Vanilla, Fabric, Forge, NeoForge) | [Guide](servers/minecraft.md) |
| Valheim | [Guide](servers/valheim.md) |
| Palworld | [Guide](servers/palworld.md) |
| 7 Days to Die | [Guide](servers/7-days-to-die.md) |
| Project Zomboid | [Guide](servers/project-zomboid.md) |
| DayZ | [Guide](servers/dayz.md) |
| Terraria | [Guide](servers/terraria.md) |
| Factorio | [Guide](servers/factorio.md) |

## Browser generators

The [Tools](tools/index.md) page builds `server.properties`, Arma 3 `server.cfg`, and podman run or compose snippets in the browser. Nothing is uploaded.

## Getting a server running

1. Pick a game from [All servers](reference/servers.md).
2. Copy the compose command from that game's guide.
3. Run it. Friends connect to your public IP on the ports listed on the guide page.

Full walkthrough: [Quick start](guides/quick-start.md).

## Images and CI

First-party images share bases under `poderized/bases/`: `minecraft-base` (Java), `steam-base` (SteamCMD), and `runtime-base` (Debian slim for non-Steam binaries). See [Images](reference/images.md) for GHCR names and [CI](reference/ci.md) for build and publish workflows.

License is 0BSD. Fork it, self-host the docs, publish your own images.
