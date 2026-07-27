---
title: Home
description: Dockerized dedicated game servers with small images and compose files.
template: splash
editUrl: false
lastUpdated: false
hero:
  title: Dockerized Game Servers
  tagline: Small container images and Compose files for dedicated game servers.
  actions:
    - text: Quick start
      link: /guides/quick-start/
      icon: right-arrow
    - text: All servers
      link: /reference/servers/
      variant: minimal
---

Published images live on GHCR at `{{IMAGE_PREFIX}}/`. Set `IMAGE_OWNER` when you fork and publish your own packages.

- Compose-first workflows with optional local builds
- Shared bases for Minecraft (Java), SteamCMD, and glibc runtimes
- Static documentation that works without JavaScript, plus optional search

## Shared bases

- **minecraft-base**: Temurin JRE on Alpine
- **steam-base**: SteamCMD on Arch Linux
- **runtime-base**: Debian slim for non-Steam, non-Java servers

## Learn more

1. [Quick start](guides/quick-start/) to run a server with Compose or Docker.
2. [All servers](reference/servers/) for compose paths, image names, and doc links.
3. [Images](reference/images/) and [CI](reference/ci/) when you build or publish.
