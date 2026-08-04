---
title: Barotrauma
description: Barotrauma dedicated server via SteamCMD, App 1026340.
---

On first start the container downloads the Barotrauma dedicated server (Steam app 1026340) into your data folder, then launches the native Linux DedicatedServer binary.

:::note[Before you start]
- Open UDP ports 27015 and 27016
- Keep a data folder for the installed server, saves, and config
- Give the container at least 4 GB of RAM
- No Steam account is needed. The server installs anonymously through SteamCMD
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | UDP | Main game port |
| 27016 | UDP | Secondary game port |

Barotrauma uses UDP only for gameplay. Do not publish TCP on these ports.

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used during the install step |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard code |
| BAROTRAUMA_APP_ID | 1026340 | Steam app ID to install |
| BAROTRAUMA_FORCE_UPDATE | false | Re-download the server from Steam on next start |
| BAROTRAUMA_EXTRA_ARGS | (empty) | Extra command-line flags added to the server launch |

See [Quick start](/guides/quick-start/) if you need to log in with a real Steam account for the install step.

## Data folder

Your data folder mounts to /opt/barotrauma inside the container. It holds the installed DedicatedServer binary and server config created on first run.

| Path | Purpose |
| --- | --- |
| DedicatedServer | Server binary, installed by SteamCMD |
| serversettings.xml | Main server settings. Edit on the host after first start |
| Data/ | Saves, logs, and mod content |

## Compose

```bash
docker compose -f dockerized/barotrauma/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name barotrauma --restart unless-stopped --init \
  -p 27015:27015/udp -p 27016:27016/udp \
  -v "$PWD/dockerized/barotrauma/data:/opt/barotrauma" \
  {{IMAGE_PREFIX}}/barotrauma:latest
```

## Updates

Set BAROTRAUMA_FORCE_UPDATE to true and recreate the container, or use the update command described in [Ops](/guides/ops/).

## Health check

The container reports healthy while the Barotrauma server is running. Startup gets a 600 second grace period.
