---
title: Barotrauma
description: Barotrauma dedicated server via SteamCMD, App 1026340.
---

Compose path: barotrauma. Image: barotrauma.

Barotrauma dedicated server built on the shared [steam-base](/reference/images/) image. SteamCMD installs App **1026340** into the data volume on first start, then launches the native Linux `DedicatedServer` binary.

:::note[Requirements]
- Publish UDP **27015** and UDP **27016**
- Persist `./data` at `/opt/barotrauma`
- Allocate at least 4 GB RAM
- No Steam account is required, SteamCMD installs App 1026340 anonymously
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27015 | UDP | Main game port |
| 27016 | UDP | Secondary game port |

Barotrauma uses UDP only for gameplay. Do not publish TCP on these ports.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | Steam login for the SteamCMD install step |
| `STEAM_PASSWORD` | (empty) | Steam password |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code |
| `BAROTRAUMA_APP_ID` | `1026340` | Steam app id to install |
| `BAROTRAUMA_FORCE_UPDATE` | `false` | Re-run SteamCMD for App 1026340 on next start |
| `BAROTRAUMA_EXTRA_ARGS` | (empty) | Extra CLI flags appended when launching `DedicatedServer` |

See [Quick start](/guides/quick-start/) for the shared Steam login pattern.

## Data volume

`./data` mounts to `/opt/barotrauma`. It holds the installed `DedicatedServer` binary and server config created on first run.

| Path | Purpose |
| --- | --- |
| `DedicatedServer` | Server binary, installed by SteamCMD |
| `serversettings.xml` | Main server settings, edit on the host after first start |
| `Data/` | Saves, logs, and mod content |

## Compose

```bash
docker compose -f barotrauma/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name barotrauma --restart unless-stopped --init \
  -p 27015:27015/udp -p 27016:27016/udp \
  -v "$PWD/barotrauma/data:/opt/barotrauma" \
  {{IMAGE_PREFIX}}/barotrauma:latest
```

## Updating

Set `BAROTRAUMA_FORCE_UPDATE=true` and recreate the container, or run `./tools/gs update barotrauma` from [Ops](/guides/ops/). The healthcheck is a `process` probe for `DedicatedServer` with a 600 second start period.
