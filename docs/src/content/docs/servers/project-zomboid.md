---
title: Project Zomboid
description: Project Zomboid dedicated server via SteamCMD (App 380870).
---

On first start the container downloads the Project Zomboid Linux dedicated server through SteamCMD. Anonymous SteamCMD can download and run the server without a Steam account. You only need a real Steam login if you want the install step to authenticate as a specific user.

:::note[Before you start]
- Set PZ_ADMIN_PASSWORD before first start. This becomes the server admin password. The default is changeme
- Keep a data folder for the installed server, saves, and .ini configs
- Open UDP ports 16261 and 16262
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 16261 | UDP | Main game port |
| 16262 | UDP | Steam query and direct connect port |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used during the install step |
| STEAM_PASSWORD | (empty) | Password for STEAM_USERNAME when not anonymous |
| STEAM_GUARD_CODE | (empty) | Steam Guard code for the login above |
| PZ_APP_ID | 380870 | Steam app ID for the dedicated server |
| PZ_FORCE_UPDATE | false | Re-download the server from Steam on next start |
| PZ_SERVER_NAME | servertest | Server profile name. Controls the .ini file and save folder |
| PZ_ADMIN_PASSWORD | changeme | Admin password, passed on every start |
| PZ_NO_STEAM | false | Adds -nosteam for GOG installs or non-Steam clients |
| PZ_EXTRA_ARGS | (empty) | Extra launch arguments, space-separated |

The included docker-compose.yml reads STEAM_USERNAME, STEAM_PASSWORD, STEAM_GUARD_CODE, PZ_FORCE_UPDATE, and PZ_ADMIN_PASSWORD from your shell or a .env file. PZ_SERVER_NAME, PZ_NO_STEAM, and PZ_EXTRA_ARGS are fixed in that file. Edit project-zomboid/docker-compose.yml to change them, or use docker run -e instead.

## Data folder and file layout

Mount project-zomboid/data at /opt/zomboid. Two paths live under it:

| Path | Purpose |
| --- | --- |
| server/ | SteamCMD-installed server binaries and start-server.sh |
| home/Zomboid/ | Saves, server .ini files, and logs |

The active config is home/Zomboid/Server/PZ_SERVER_NAME.ini, created on first start. Stop the container before editing it by hand.

## Updates

Set PZ_FORCE_UPDATE to true and recreate the container, or use the update command described in [Ops](/guides/ops/).

## Health check

The container reports healthy while the Project Zomboid server is running. Startup gets a 600 second grace period to cover the first SteamCMD download.

## Compose

```bash
export PZ_ADMIN_PASSWORD=changeme
docker compose -f project-zomboid/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name project-zomboid --restart unless-stopped --init \
  -p 16261:16261/udp -p 16262:16262/udp \
  -v "$PWD/project-zomboid/data:/opt/zomboid" \
  -e STEAM_USERNAME=anonymous \
  -e PZ_ADMIN_PASSWORD=changeme \
  -e PZ_SERVER_NAME=servertest \
  {{IMAGE_PREFIX}}/project-zomboid:latest
```

Give the container at least 4 GB of RAM. The included compose file caps memory at 6144 MB.
