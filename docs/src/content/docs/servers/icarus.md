---
title: Icarus
description: Icarus dedicated server (Windows binary via Wine).
---

This image downloads the Icarus dedicated server through Steam and runs the Windows build under Wine. First start also sets up a Wine environment and can take up to 20 minutes.

:::note[Before you start]
- Keep a data folder for the server install
- Open UDP port 17777 for game traffic and UDP 27015 for server browser queries
- Anonymous Steam login works for most installs. If the download fails, use a Steam account that owns Icarus
- The compose file sets an 8 GB memory limit. Give the host at least that much RAM
- Only one service on the host should use UDP 27015 unless you change ICARUS_QUERY_PORT and the published port mapping
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 17777 | UDP | Game traffic (ICARUS_PORT) |
| 27015 | UDP | Server browser query (ICARUS_QUERY_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used to download the server |
| STEAM_PASSWORD | (empty) | Steam password, required when using a real account |
| STEAM_GUARD_CODE | (empty) | Steam Guard dockerized/code if prompted during login |
| ICARUS_APP_ID | 2089300 | Steam app id for the dedicated server tool |
| ICARUS_STEAM_APP_ID | 1149460 | Icarus game app id, written to steam_appid.txt |
| ICARUS_FORCE_UPDATE | false | Reinstall the server on next start |
| ICARUS_PORT | 17777 | Game UDP port |
| ICARUS_QUERY_PORT | 27015 | Query UDP port |
| ICARUS_GAME_MODE | Prospect | Game mode, passed as -GameMode= |
| ICARUS_SESSION_NAME | Icarus Server | Session name shown to players |
| ICARUS_MAX_PLAYERS | 8 | Player cap |
| ICARUS_ADMIN_PASSWORD | (empty) | Adds -AdminPassword= when set |
| ICARUS_EXTRA_ARGS | (empty) | Extra flags appended to the launch command |

## Data folder

Your data folder mounts at /opt/icarus inside the container.

| Path | Purpose |
| --- | --- |
| .wine/ | Wine prefix, created on first start |
| steam_appid.txt | Rewritten every start with ICARUS_STEAM_APP_ID |
| game install tree | Wherever SteamCMD placed the server binary |

The container does not write a config file. All settings above are launch arguments. If SteamCMD installs files under a nested steamapps/common folder, the container moves them up into /opt/icarus on first start.

The container fixes file ownership on the data folder automatically on every start.

## Updates

Set ICARUS_FORCE_UPDATE to true to reinstall on the next start. You can also run ./tools/gs update icarus. See [Ops](/guides/ops/).

## Health check

The container reports healthy while the Icarus server process is running. Startup gets a 1200 second grace period because first install can take a long time.

## Compose

```bash
docker compose -f dockerized/icarus/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name icarus --restart unless-stopped --init \
  -p 17777:17777/udp -p 27015:27015/udp \
  -v "$PWD/dockerized/icarus/data:/opt/icarus" \
  -e ICARUS_SESSION_NAME="My Prospect" \
  -e ICARUS_GAME_MODE=Prospect \
  {{IMAGE_PREFIX}}/icarus:latest
```
