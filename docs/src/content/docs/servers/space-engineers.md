---
title: Space Engineers
description: Space Engineers dedicated server (Windows binary via Wine).
steamAppId: "298740"
---

This image downloads the Space Engineers dedicated server through Steam and runs the Windows build under Wine. First start also installs Wine and .NET Framework 4.8, which can take several minutes.

:::note[Before you start]
- Keep three separate data folders: dedicated, instances, and plugins (see Data folders below)
- Open UDP port 27016 for game traffic and UDP 8766 for Steam networking
- Anonymous Steam login works for most installs. If the download fails, use a Steam account that owns Space Engineers
- The compose file sets an 8 GB memory limit
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27016 | UDP | Game port (SE_PORT) |
| 8766 | UDP | Steam networking (SE_STEAM_PORT) |
| 8080 | TCP | VRage Remote API, only if enabled in the instance config |

## Data folders

| Host path | Container path | Purpose |
| --- | --- | --- |
| space-engineers/data/dedicated | /opt/spaceengineers/dedicated | SteamCMD install of the server and game content |
| space-engineers/data/instances | /opt/spaceengineers/instances | Per-instance config and saves. Default instance name is Default |
| space-engineers/data/plugins | /opt/spaceengineers/plugins | Drop .dll plugins here. They are added to the instance config on every start |

The Wine prefix is baked into the image at build time, not stored in any mounted folder. Rebuilding the image resets it. Recreating the container does not.

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used to download the server |
| STEAM_PASSWORD | (empty) | Steam password, required when using a real account |
| STEAM_GUARD_CODE | (empty) | Steam Guard code if prompted during login |
| SE_APP_ID | 298740 | Steam app id for the dedicated server tool |
| SE_GAME_APP_ID | 244850 | Space Engineers game app id, written to steam_appid.txt |
| SE_FORCE_UPDATE | false | Reinstall the server on next start |
| SE_INSTANCE_NAME | Default | Instance folder name under instances/ |
| SE_SERVER_NAME | Space Engineers | Name shown in the server list |
| SE_WORLD_NAME | DedicatedWorld | Save folder name under the instance |
| SE_PUBLIC_IP | (empty) | Public IP written into the instance config. Auto-detected when empty |
| SE_PORT | 27016 | Game UDP port |
| SE_STEAM_PORT | 8766 | Steam UDP port |
| SE_EXTRA_ARGS | (empty) | Extra flags appended to the launch command |
| SE_PREMADE_CHECKPOINT | (dedicated)/Content/CustomWorlds/Earth Planet/PC | Starting scenario, used only when no save exists yet |

When using docker run, you must pass SE_EXTRA_ARGS even if it is empty (-e SE_EXTRA_ARGS=). Without it the container exits immediately.

## Instance config

instances/<SE_INSTANCE_NAME>/SpaceEngineers-Dedicated.cfg is written once with Survival mode, a fixed max of 4 players, and other defaults. There is no SE_MAX_PLAYERS setting. Edit MaxPlayers in the generated file by hand for a different cap.

On every start the container rewrites these values in that file:

| Element | Updated from |
| --- | --- |
| IP | SE_PUBLIC_IP, or the container's detected address when empty |
| LoadWorld | The instance save path if one exists, cleared otherwise |
| SteamPort | SE_STEAM_PORT |
| ServerPort | SE_PORT |
| Plugins | Every .dll currently in the plugins folder |

Everything else in the file (game mode, inventory size, PCU limits, view distance, and so on) persists across restarts. The whole file is regenerated if it looks like an old format or is missing PremadeCheckpointPath.

## Updates

Set SE_FORCE_UPDATE to true to reinstall on the next start. You can also run ./tools/gs update space-engineers. See [Ops](/guides/ops/).

## Health check

The container reports healthy while the Space Engineers server process is running. Startup gets a 900 second grace period because first install and Wine setup can take a while.

## Compose

```bash
docker compose -f space-engineers/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name space-engineers --restart unless-stopped --init \
  -p 27016:27016/udp \
  -v "$PWD/space-engineers/data/dedicated:/opt/spaceengineers/dedicated" \
  -v "$PWD/space-engineers/data/instances:/opt/spaceengineers/instances" \
  -v "$PWD/space-engineers/data/plugins:/opt/spaceengineers/plugins" \
  -e SE_PUBLIC_IP=203.0.113.10 \
  -e SE_EXTRA_ARGS= \
  {{IMAGE_PREFIX}}/space-engineers:latest
```
