---
title: Eco
description: Eco dedicated server via SteamCMD, requires a server registration token
---

Compose path: eco. Image: eco. Built from the shared [steam-base](/reference/images/) image (Arch Linux with SteamCMD).

Eco installs Steam App **739590** into the data volume on first start. The server will not start without `ECO_USER_TOKEN`, a registration token you generate from the Eco client so the dedicated server can register itself with your account.

:::note[Requirements]
- Set `ECO_USER_TOKEN` from the Eco client, the container installs the game then exits if it is missing
- Persist `./data` for the installed server and Eco's own save data
- Publish UDP **3000** and **3001**
- Allocate at least 4 GB RAM
:::

## How the server is installed

`entrypoint.sh` sources the shared [`bases/steam/steamcmd-app-update.sh`]({{GITHUB_URL}}/blob/master/bases/steam/steamcmd-app-update.sh) helper and runs `+app_update 739590 validate` against the data volume. SteamCMD logs in anonymously by default. If the binary is missing or `ECO_FORCE_UPDATE=true`, it reinstalls before starting. A defensive fallback walks `/home/eco/Steam/steamapps/common` and moves any directory containing `EcoServer` into the data volume, in case SteamCMD lands files outside `force_install_dir`.

`ECO_USER_TOKEN` is only checked **after** the install step, so a first run with no token still downloads the full server before failing.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 3000 | UDP | Main game/sync port |
| 3001 | UDP | Secondary Eco server port |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `ECO_USER_TOKEN` | *(none, required)* | Server registration token from the Eco client, the container exits if unset |
| `ECO_EXTRA_ARGS` | *(empty)* | Extra arguments appended after `-nogui -userToken=...` |
| `ECO_FORCE_UPDATE` | `false` | Re-run SteamCMD for App 739590 on next start |
| `ECO_APP_ID` | `739590` | Steam app id to install, only change for testing a different build |
| `STEAM_USERNAME` | `anonymous` | Steam login for the install step |
| `STEAM_PASSWORD` | *(empty)* | Steam password, needed alongside a real `STEAM_USERNAME` |
| `STEAM_GUARD_CODE` | *(empty)* | Steam Guard code for the login step |
| `STEAMCMD_WINDOWS_WORKAROUND` | `prime` | SteamCMD platform-login workaround, other values are `full` and `off` |

See [Quick start](/guides/quick-start/) for the shared `STEAM_USERNAME`/`STEAM_PASSWORD`/`STEAM_GUARD_CODE` pattern.

## Data volume

`./data` mounts to `/opt/eco`. It holds the installed `EcoServer` binary and everything Eco writes at runtime, including whatever configuration and save folders the Eco server itself creates. The entrypoint does not template or manage any Eco config file.

## Compose

```bash
docker compose -f eco/docker-compose.yml up -d
```

`eco/docker-compose.yml` sets `STEAM_USERNAME` and `STEAM_PASSWORD` to **literal** values (`anonymous` and empty), not compose variable substitution. If Eco needs a real Steam account to install, either pass `-e STEAM_USERNAME=... -e STEAM_PASSWORD=...` with `docker run` instead, or edit those two lines directly in the compose file. `ECO_FORCE_UPDATE` and `ECO_USER_TOKEN` do use `${VAR:-default}` substitution, so those two can be set from your shell or a `.env` file next to the compose file.

## Docker run

```bash
docker run -d --name eco --restart unless-stopped --init \
  -p 3000:3000/udp -p 3001:3001/udp \
  -v "$PWD/eco/data:/opt/eco" \
  -e ECO_USER_TOKEN="your-token-here" \
  {{IMAGE_PREFIX}}/eco:latest
```

Add `-e STEAM_USERNAME=... -e STEAM_PASSWORD=...` if anonymous SteamCMD cannot install App 739590 for your account.

## Updating

Set `ECO_FORCE_UPDATE=true` and recreate the container, or run `./tools/gs update eco` from [Ops](/guides/ops/). The healthcheck is a `process` probe for `EcoServer`.
