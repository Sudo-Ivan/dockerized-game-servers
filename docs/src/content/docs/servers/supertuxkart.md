---
title: SuperTuxKart
description: SuperTuxKart dedicated server, compiled from source with SERVER_ONLY, no Steam and no GPU needed.
iconFit: contain
---

Unlike most servers in this repository, SuperTuxKart is compiled from source at image build time. There is no official server-only Linux release, so the image builds a headless binary with no graphics, sound, or GPU dependency. Game assets are bundled in the source tarball.

:::note[Before you start]
- Keep a data folder for server config and player data
- Open UDP port 2759
- LAN mode (the default) needs no account. WAN mode (public server list) needs a free [STK Online](https://online.supertuxkart.net/register.php) account
- Very light on resources. Official guidance is roughly 60 MB RAM for an 8-player race. The compose file sets a 512 MB memory limit
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 2759 | UDP | Game traffic (STK_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STK_ONLINE_USERNAME | (empty) | STK Online account login, required for STK_MODE=wan |
| STK_ONLINE_PASSWORD | (empty) | STK Online account password, used once to create the saved session |
| STK_MODE | lan | lan or wan. wan lists the server publicly and needs a saved STK Online session |
| STK_SERVER_NAME | SuperTuxKart Server | Server name, overrides server-name in server_config.xml on every start |
| STK_PORT | 2759 | Game UDP port |
| STK_MAX_PLAYERS | 8 | Player cap. Values above 8 can hurt performance |
| STK_GAME_MODE | 3 | 0 GP race, 1 GP time trial, 3 normal race, 4 time trial, 6 soccer, 7 free-for-all, 8 capture the flag |
| STK_DIFFICULTY | 0 | 0 beginner, 1 intermediate, 2 expert, 3 supertux |
| STK_PASSWORD | (empty) | Join password, empty for a public server |
| STK_RANKED | false | Submitting rankings needs prior permission from the stk-addons server |
| STK_OWNER_LESS | false | Races autostart with no server owner controlling the lobby |
| STK_TRACK_VOTING | true | Disable to have the server pick tracks randomly |
| STK_FIREWALLED | true | Enables STUN. Set false if the published port is already directly reachable |
| STK_MIN_START_PLAYERS | 2 | Minimum players needed to start a race |
| STK_MOTD | (empty) | Message of the day shown in the lobby |
| STK_EXTRA_ARGS | (empty) | Extra flags appended to the launch command |

## Data folder

Your data folder mounts at /opt/supertuxkart/data, separate from the compiled program baked into the image.

| Path | Purpose |
| --- | --- |
| server_config.xml | Written once from the settings above then left alone. STK rewrites it with the full schema after first start. Edit directly for settings not exposed above |
| home/.config/supertuxkart/config-0.10/players.xml | STK Online session token, created when STK_ONLINE_USERNAME and STK_ONLINE_PASSWORD are both set |
| home/.config/supertuxkart/config-0.10/server_config.log | Server log |

The container sets HOME so all player data lands inside the data folder. File ownership is fixed automatically.

## Updates

The game version is fixed at image build time. To upgrade, rebuild the image with a newer STK_VERSION and matching source checksum in the Dockerfile. There is no runtime updater.

## Health check

The container reports healthy while the SuperTuxKart server process is running. Startup gets a 60 second grace period.

## Compose

```bash
docker compose -f supertuxkart/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name supertuxkart --restart unless-stopped --init \
  -p 2759:2759/udp \
  -v "$PWD/supertuxkart/data:/opt/supertuxkart/data" \
  -e STK_SERVER_NAME="My Kart Server" \
  {{IMAGE_PREFIX}}/supertuxkart:latest
```
