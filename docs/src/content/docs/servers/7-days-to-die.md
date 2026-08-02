---
title: 7 Days to Die
description: 7 Days to Die dedicated server via SteamCMD
---

On first start the container downloads the 7 Days to Die Linux dedicated server (Steam app 294420) into your data folder. It writes a default serverconfig.xml the first time that file is missing.

Before every start the container also writes steam_appid.txt with the game's client Steam app ID (251570). The server binary needs this file on disk even though the container installed the dedicated server app (294420).

:::note[Before you start]
- Keep a data folder for the installed server, world, and config
- Open TCP and UDP port 26900, plus UDP ports 26901 through 26903
- Give the container at least 6 GB of RAM
- No Steam account is needed. The server installs anonymously through SteamCMD
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 26900 | TCP | Main game port (ServerPort in serverconfig.xml) |
| 26900 | UDP | Main game port (ServerPort in serverconfig.xml) |
| 26901-26903 | UDP | Additional game data channels used by the engine |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| CONFIG_FILE | serverconfig.xml | Config file name or path. Relative names resolve under /opt/7dtd |
| SEVENDTD_EXTRA_ARGS | (empty) | Extra command-line flags added after -configfile= |
| SEVENDTD_FORCE_UPDATE | false | Re-download the server from Steam on next start |
| SEVENDTD_APP_ID | 294420 | Steam app ID to install |
| STEAM_USERNAME | anonymous | Steam login used during the install step |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard dockerized/code |

See [Quick start](/guides/quick-start/) if you need to log in with a real Steam account for the install step.

## First-start config

The container only writes the file at CONFIG_FILE when it does not already exist, with these defaults:

| Setting | Default value |
| --- | --- |
| ServerName | 7 Days to Die Server |
| ServerPort | 26900 |
| ServerVisibility | 2 |
| ServerPassword | empty |
| ServerMaxPlayerCount | 8 |
| GameWorld | Navezgane |
| GameName | Dedicated |
| GameDifficulty | 2 |
| ServerDisabledNetworkProtocols | SteamNetworking |

None of these settings have their own environment variable. Edit dockerized/7-days-to-die/data/serverconfig.xml (or whatever CONFIG_FILE points to) on the host, then restart the container. CONFIG_FILE is mainly useful for keeping more than one hand-edited config in the same data folder.

If startserver.sh exists in the install, the container uses that instead of launching the server binary directly. It passes the same -configfile= and SEVENDTD_EXTRA_ARGS either way.

## Data folder

Your data folder mounts to /opt/7dtd inside the container. It holds the installed server binary, serverconfig.xml, steam_appid.txt, and the world saves and logs the game creates.

## Compose

```bash
docker compose -f dockerized/7-days-to-die/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name 7-days-to-die --restart unless-stopped --init \
  -p 26900:26900/tcp -p 26900:26900/udp \
  -p 26901-26903:26901-26903/udp \
  -v "$PWD/dockerized/7-days-to-die/data:/opt/7dtd" \
  {{IMAGE_PREFIX}}/7-days-to-die:latest
```

## Updates

Set SEVENDTD_FORCE_UPDATE to true and recreate the container, or use the update command described in [Ops](/guides/ops/).

## Health check

The container reports healthy while the 7 Days to Die server is running.
