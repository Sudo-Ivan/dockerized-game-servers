---
title: Satisfactory
description: Satisfactory dedicated server via native Linux FactoryServer.sh
---

On first start the container downloads the Satisfactory Linux dedicated server (Steam app 1690800) into your data folder and launches it with FactoryServer.sh.

:::note[Before you start]
- Keep a data folder for the installed server and save data
- Open TCP and UDP port 7777 for game traffic and TCP port 8888 for the reliable channel
- Anonymous Steam login works for the dedicated server install
- The compose file sets an 8 GB memory limit. Give the host at least that much RAM
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7777 | TCP | Game port (SATISFACTORY_PORT) |
| 7777 | UDP | Game port (SATISFACTORY_PORT) |
| 8888 | TCP | Reliable port (SATISFACTORY_RELIABLE_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used during the install step |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard dockerized/code |
| SATISFACTORY_APP_ID | 1690800 | Steam app ID to install |
| SATISFACTORY_FORCE_UPDATE | false | Re-download the server from Steam on next start |
| SATISFACTORY_PORT | 7777 | Game TCP/UDP port, passed as -Port= |
| SATISFACTORY_RELIABLE_PORT | 8888 | Reliable TCP port, passed as -ReliablePort= |
| SATISFACTORY_EXTRA_ARGS | (empty) | Extra flags appended to FactoryServer.sh |

## Data folder

Your data folder mounts to /opt/satisfactory inside the container. It holds the installed server files and any saves the game creates after the first run.

If SteamCMD installs files under a nested steamapps/common folder, the container moves them up into /opt/satisfactory on first start.

## Compose

```bash
docker compose -f dockerized/satisfactory/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name satisfactory --restart unless-stopped --init \
  -p 7777:7777/tcp -p 7777:7777/udp -p 8888:8888/tcp \
  -v "$PWD/dockerized/satisfactory/data:/opt/satisfactory" \
  {{IMAGE_PREFIX}}/satisfactory:latest
```

## Updates

Set SATISFACTORY_FORCE_UPDATE to true and recreate the container, or use the update command described in [Ops](/guides/ops/).

## Health check

The container reports healthy while FactoryServer.sh or the FactoryServer-Linux-Shipping process is running. Startup gets a 900 second grace period.
