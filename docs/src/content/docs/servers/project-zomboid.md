---
title: Project Zomboid
description: Project Zomboid dedicated server via SteamCMD (App 380870).
---

Compose path: `project-zomboid`. Image: `project-zomboid`.

The entrypoint installs the Linux dedicated server with SteamCMD as root, then re-execs itself as an unprivileged `zomboid` user before touching game files. Anonymous SteamCMD can download and run the dedicated server binaries, a Steam account is only needed if you want the container to authenticate as a specific user.

:::note[Requirements]
- Set `PZ_ADMIN_PASSWORD` before first start, this becomes the server's admin password and both the entrypoint and the shipped compose file default it to the literal string `changeme`
- Persist `./data` for the installed server files, the Zomboid home directory, saves, and `.ini` configs
- Publish UDP **16261** and **16262**
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 16261 | UDP | Main game port |
| 16262 | UDP | Steam query / direct connect port |

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | SteamCMD login for the install step |
| `STEAM_PASSWORD` | (empty) | Password for `STEAM_USERNAME` when not anonymous |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code for the login above |
| `PZ_APP_ID` | `380870` | Steam App ID for the dedicated server |
| `PZ_FORCE_UPDATE` | `false` | Re-run `app_update` for `PZ_APP_ID` on next start even if the server is already installed |
| `PZ_SERVER_NAME` | `servertest` | Server profile name, controls the `.ini` file and save folder under the home directory |
| `PZ_ADMIN_PASSWORD` | `changeme` | Passed as `-adminpassword` on every start |
| `PZ_NO_STEAM` | `false` | Adds `-nosteam` to the launch command for GOG installs or non-Steam clients |
| `PZ_EXTRA_ARGS` | (empty) | Extra arguments appended verbatim to the launch command, space-separated |

The shipped `docker-compose.yml` only reads `STEAM_USERNAME`, `STEAM_PASSWORD`, `STEAM_GUARD_CODE`, `PZ_FORCE_UPDATE`, and `PZ_ADMIN_PASSWORD` from the shell or an `.env` file with a `${VAR:-default}` fallback. `PZ_SERVER_NAME`, `PZ_NO_STEAM`, and `PZ_EXTRA_ARGS` are fixed literals in that file, edit `project-zomboid/docker-compose.yml` directly to change them, or use `docker run -e` instead of compose.

## Data volume and file layout

Mount `project-zomboid/data` at `/opt/zomboid`. Two paths live under it:

| Path | Purpose |
| --- | --- |
| `server/` | SteamCMD-installed dedicated server binaries and `start-server.sh` |
| `home/Zomboid/` | Saves, server `.ini` files, and logs, since the entrypoint sets `HOME=/opt/zomboid/home` |

The active config is `home/Zomboid/Server/<PZ_SERVER_NAME>.ini`, created on first start. Stop the container before editing it by hand.

## Update

`PZ_FORCE_UPDATE=true` forces a reinstall on the next recreate. See [Ops](/guides/ops/) for `./tools/gs update project-zomboid` and backups.

## Healthcheck

Process check: the container is healthy while a `ProjectZomboid64` process is running, with a 600 second start period to cover the first SteamCMD download.

## Compose

```bash
export PZ_ADMIN_PASSWORD=changeme
docker compose -f project-zomboid/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name project-zomboid --restart unless-stopped --init \
  -p 16261:16261/udp -p 16262:16262/udp \
  -v "$PWD/project-zomboid/data:/opt/zomboid" \
  -e STEAM_USERNAME=anonymous \
  -e PZ_ADMIN_PASSWORD=changeme \
  -e PZ_SERVER_NAME=servertest \
  {{IMAGE_PREFIX}}/project-zomboid:latest
```

Allocate at least 4 GB RAM, the shipped compose file caps the container at 6144 MB.
