---
title: SuperTuxKart
description: SuperTuxKart dedicated server, compiled from source with SERVER_ONLY, no Steam and no GPU needed.
iconFit: contain
---

Compose path: `supertuxkart`. Image: `supertuxkart`.

Unlike every other server in this repository, SuperTuxKart is not downloaded as a prebuilt binary. There is no official server-only Linux release, so the image compiles [`stk-code`](https://github.com/supertuxkart/stk-code) from the official source tarball with `-DSERVER_ONLY=ON`, which produces a GUI-less, sound-less binary with no OpenGL, X11, or GPU dependency at all, safe for a plain headless container. Assets are bundled in the source tarball, no separate SVN checkout is needed.

:::note[Requirements]
- Persist `supertuxkart/data` at `/opt/supertuxkart/data`
- Publish UDP **2759**
- LAN mode (the default) needs no account at all. WAN mode (public server list) needs a free [STK Online](https://online.supertuxkart.net/register.php) account, set `STK_ONLINE_USERNAME` and `STK_ONLINE_PASSWORD`
- Lightest server in this repository by far, official guidance is roughly 60 MB RAM and well under one CPU core for an 8-player race, `mem_limit` is set to 512M
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 2759 (`STK_PORT`) | UDP | Game traffic |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STK_ONLINE_USERNAME` | (empty) | STK Online account login, required for `STK_MODE=wan` |
| `STK_ONLINE_PASSWORD` | (empty) | STK Online account password, only used once to create the saved session |
| `STK_MODE` | `lan` | `lan` or `wan`. `wan` lists the server publicly and needs a saved STK Online session |
| `STK_SERVER_NAME` | `SuperTuxKart Server` | Passed as the name to `--lan-server` / `--wan-server`, overrides `server-name` in `server_config.xml` on every start |
| `STK_PORT` | `2759` | `server-port` |
| `STK_MAX_PLAYERS` | `8` | `server-max-players`, values above 8 can degrade performance per upstream guidance |
| `STK_GAME_MODE` | `3` | `server-mode`: `0` GP race, `1` GP time trial, `3` normal race, `4` time trial, `6` soccer, `7` free-for-all, `8` capture the flag |
| `STK_DIFFICULTY` | `0` | `server-difficulty`: `0` beginner, `1` intermediate, `2` expert, `3` supertux |
| `STK_PASSWORD` | (empty) | `private-server-password`, join password, empty is a public server |
| `STK_RANKED` | `false` | `ranked`, submitting rankings needs prior permission from the stk-addons server |
| `STK_OWNER_LESS` | `false` | `owner-less`, races autostart with no server owner controlling the lobby |
| `STK_TRACK_VOTING` | `true` | `track-voting`, disable to have the server pick tracks randomly |
| `STK_FIREWALLED` | `true` | `firewalled-server`, enables STUN. Set `false` to save resources if the published port is already directly reachable |
| `STK_MIN_START_PLAYERS` | `2` | `min-start-game-players` |
| `STK_MOTD` | (empty) | `motd`, message of the day shown in the lobby |
| `STK_EXTRA_ARGS` | (empty) | Extra flags appended to the launch command |

## Data volume

`supertuxkart/data` mounts at `/opt/supertuxkart/data`, separate from the compiled program under `/opt/supertuxkart/bin` and `/opt/supertuxkart/share` baked into the image.

| Path | Purpose |
| --- | --- |
| `server_config.xml` | Written once from the environment variables above then left alone, STK itself rewrites it with the full schema (comments included) after the first start. Edit it directly for settings not exposed as env vars |
| `home/.config/supertuxkart/config-0.10/players.xml` | STK Online session token, created by `--init-user` when `STK_ONLINE_USERNAME` and `STK_ONLINE_PASSWORD` are both set |
| `home/.config/supertuxkart/config-0.10/server_config.log` | Server log |

The entrypoint exports `HOME=/opt/supertuxkart/data/home` so all of STK's own per-user state lands inside the data volume instead of the container's throwaway home directory.

The container starts as root, chowns `/opt/supertuxkart/data` to the `supertuxkart` user, then drops privileges before launching the game, so no manual chown of the host directory is needed.

## Updating the game version

The compiled version is fixed at image build time by `STK_VERSION` (build arg, default `1.5`) and `STK_SRC_SHA256` in `supertuxkart/Dockerfile`. Bump both to a newer release tag and its published source tarball checksum, then rebuild the image, there is no runtime updater.

## Healthcheck

Process check (`pgrep -f /opt/supertuxkart/bin/supertuxkart`), 60 second start period.

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
