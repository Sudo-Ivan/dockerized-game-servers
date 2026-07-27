---
title: Home
description: Run a game server for you and your friends in one command, no manual installs.
template: splash
editUrl: false
lastUpdated: false
hero:
  title: Dockerized Game Servers
  tagline: Run a dedicated server for you and your friends in one command. Minecraft, Valheim, Palworld, DayZ, and 30+ more.
  actions:
    - text: Quick start
      link: /guides/quick-start/
      icon: right-arrow
    - text: Browse all servers
      link: /reference/servers/
      variant: minimal
---

Want to host your own game server without fighting SteamCMD, missing libraries, or a wiki page from five years ago? Pick a game, copy one command, and you have a server running. Everything needed to download and run the actual game server software is already packaged up for you.

## Why this instead of doing it by hand

- **One command to start.** Every server uses the same `docker compose up` or `docker run` pattern, so learning one game's setup gets you most of the way to every other one.
- **You keep your data.** Worlds, saves, and configs live in a folder on your machine (`./data` next to each server), so updating or restarting the container never wipes progress.
- **Updates and backups without guesswork.** A single [ops tool](guides/ops/) can back up, restore, and update most servers with one command each.
- **Runs anywhere Docker runs.** Your own PC, a home server, or a cheap VPS, no subscription and no vendor lock-in.
- **Free and open.** Everything here is 0BSD licensed. Fork it, self-host it, publish your own copies.

## Popular picks

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

Those are just the familiar names. See [All servers](reference/servers/) for the full list, over 35 games and counting.

## No terminal? No problem

The [Tools](tools/) page has browser-based generators that build a `server.properties`, `server.cfg`, or a ready-to-paste `docker run` command for you, no command line knowledge required to get started.

## How it works, in three steps

1. Pick a game from [All servers](reference/servers/).
2. Copy the `docker compose` command from that game's guide.
3. Run it. Your friends connect using your address and the port shown on the same page.

Full walkthrough: [Quick start](guides/quick-start/).

## Curious how it is built

Every image is small on purpose and shares a handful of common bases (a Java runtime for Minecraft, SteamCMD for Steam-downloaded games, a slim Linux runtime for everything else) so they are easy to keep secure and up to date. That side of things lives in [Images](reference/images/) and [CI](reference/ci/) if you want to build your own copies or contribute.
