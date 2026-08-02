---
title: Eco
description: Eco dedicated server via SteamCMD, requires a server registration token
---

On first start the container downloads the Eco dedicated server (Steam app 739590) into your data folder. Since Eco v11, the server refuses to start without Strange Loop Games (Strange Cloud) authentication. Use ECO_USER_TOKEN (recommended) or ECO_OFFLINE=true for offline mode.

:::note[Before you start]
- Eco v11+: set ECO_USER_TOKEN from [play.eco/account](https://play.eco/account) (Server Authentication), or ECO_OFFLINE=true for offline-only play (no Strange Cloud)
- Keep a data folder for the installed server and Eco's save data
- Open UDP ports 3000 and 3001
- Give the container at least 4 GB of RAM
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 3000 | UDP (and sometimes TCP) | Game traffic. Use this port in Direct Connect |
| 3001 | TCP | Web admin and server browser helpers. Not the game join port |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| ECO_USER_TOKEN | (empty) | Server auth token from [play.eco/account](https://play.eco/account), passed as -userToken= |
| ECO_OFFLINE | false | Set true to pass -offline and skip the token (offline mode, no Strange Cloud) |
| ECO_EXTRA_ARGS | (empty) | Extra arguments added after -nogui -userToken= |
| ECO_FORCE_UPDATE | false | Re-download the server from Steam on next start |
| ECO_APP_ID | 739590 | Steam app ID to install |
| STEAM_USERNAME | anonymous | Steam login used during the install step |
| STEAM_PASSWORD | (empty) | Steam password, needed alongside a real STEAM_USERNAME |
| STEAM_GUARD_CODE | (empty) | Steam Guard dockerized/code for the login step |
| STEAMCMD_WINDOWS_WORKAROUND | prime | SteamCMD platform-login workaround. Other values are full and off |

See [Quick start](/guides/quick-start/) if you need to log in with a real Steam account for the install step.

ECO_USER_TOKEN is only checked after the install step, so a first run with no token still downloads the full server before failing.

## Data folder

Your data folder mounts to /opt/eco inside the container. It holds the installed EcoServer binary and everything Eco writes at runtime, including configuration and save folders. The container does not create or manage Eco config files for you.

On every start the container copies steamclient.so from the bundled SteamCMD tree into the locations Eco expects. Eco loads Steamworks even in offline mode, so this step is required for the server to boot.

When mapping non-default host ports (for example 3060:3000), use the host port in Direct Connect (192.168.x.x:3060). Publish UDP for the game port and TCP for the web port (3001 inside the container). Mapping 3001 as UDP only is a common cause of connection timeouts.

## Compose

```bash
docker compose -f dockerized/eco/docker-compose.yml up -d
```

The included dockerized/eco/docker-compose.yml sets STEAM_USERNAME and STEAM_PASSWORD to literal values (anonymous and empty), not variable substitution. If Eco needs a real Steam account to install, pass -e STEAM_USERNAME=... -e STEAM_PASSWORD=... with docker run instead, or edit those two lines in the compose file. ECO_FORCE_UPDATE and ECO_USER_TOKEN do use variable substitution, so you can set those from your shell or a .env file next to the compose file.

## Docker run

```bash
docker run -d --name eco --restart unless-stopped --init \
  -p 3000:3000/udp -p 3001:3001/udp \
  -v "$PWD/dockerized/eco/data:/opt/eco" \
  -e ECO_USER_TOKEN="your-token-here" \
  {{IMAGE_PREFIX}}/eco:latest
```

Add -e STEAM_USERNAME=... -e STEAM_PASSWORD=... if anonymous SteamCMD cannot install app 739590 for your account.

## Updates

Set ECO_FORCE_UPDATE to true and recreate the container, or use the update command described in [Ops](/guides/ops/).

## Health check

The container reports healthy while the Eco server is running.
