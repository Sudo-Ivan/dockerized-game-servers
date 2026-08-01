---
title: Unturned
description: Unturned dedicated server via SteamCMD, App 1110390.
---

Compose path: unturned. Image: unturned.

Unturned dedicated server built on the shared [steam-base](/reference/images/) image. SteamCMD installs App **1110390** (not the client app **304930**) into the data volume on first start, then launches `ServerHelper.sh` with `+InternetServer/<name>`.

:::note[Requirements]
- Publish UDP **27015** and UDP **27016**
- Persist `./data` at `/opt/unturned`
- Allocate at least 4 GB RAM
- No Steam account is required, SteamCMD installs App 1110390 anonymously
- For public listing, create a GSLT for game id **304930** and configure it under `Servers/` or via `UNTURNED_EXTRA_ARGS`
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | UDP | Main game port |
| 27016 | UDP | Secondary game port |

Unturned uses UDP only for gameplay. Do not publish TCP on these ports.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | Steam login for the SteamCMD install step |
| `STEAM_PASSWORD` | (empty) | Steam password |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code |
| `UNTURNED_APP_ID` | `1110390` | SteamCMD app id for the dedicated server depot |
| `UNTURNED_FORCE_UPDATE` | `false` | Re-run SteamCMD for App 1110390 on next start |
| `UNTURNED_SERVER_NAME` | `UnturnedServer` | Internet server slot name, passed as `+InternetServer/<name>` |
| `UNTURNED_EXTRA_ARGS` | (empty) | Extra CLI flags appended after the InternetServer argument |

See [Quick start](/guides/quick-start/) for the shared Steam login pattern.

## GSLT

SteamCMD installs App **1110390**, but public server tokens are created for game id **304930** at [Steam game server account management](https://steamcommunity.com/dev/managegameservers). Add the token in your server config under `Servers/<UNTURNED_SERVER_NAME>/` or pass it through `UNTURNED_EXTRA_ARGS`.

## Data volume

`./data` mounts to `/opt/unturned`.

| Path | Purpose |
| --- | --- |
| `ServerHelper.sh` | Server launcher, installed by SteamCMD |
| `Servers/` | Per-server config folders keyed by `UNTURNED_SERVER_NAME` |
| `Maps/` | Custom maps |

## Compose

```bash
docker compose -f unturned/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name unturned --restart unless-stopped --init \
  -p 27015:27015/udp -p 27016:27016/udp \
  -v "$PWD/unturned/data:/opt/unturned" \
  -e UNTURNED_SERVER_NAME="MyUnturnedServer" \
  {{IMAGE_PREFIX}}/unturned:latest
```

## Updating

Set `UNTURNED_FORCE_UPDATE=true` and recreate the container, or run `./tools/gs update unturned` from [Ops](/guides/ops/). The healthcheck is a `process` probe for `Unturned_Headless` or `Unturned` with a 600 second start period.
