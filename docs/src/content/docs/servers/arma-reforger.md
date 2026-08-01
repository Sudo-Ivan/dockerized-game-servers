---
title: Arma Reforger
description: Arma Reforger dedicated server via SteamCMD.
---

This image installs the Arma Reforger dedicated server through SteamCMD and runs the native Linux binary. Anonymous Steam login usually works. If install fails, use a Steam account with the game.

Official reference: [Arma Reforger server hosting](https://community.bistudio.com/wiki/Arma_Reforger:Server_Hosting) on the Bohemia Community Wiki.

:::note[Before you start]
- Keep a data folder for the server install, config, and profile
- Open UDP port 2001 for game traffic and UDP 17777 for A2S queries
- Allocate at least 6 GB RAM. Mod-heavy servers need more CPU, RAM, and disk
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 2001 | UDP | Game traffic (ARMAR_BIND_PORT) |
| 17777 | UDP | A2S query (ARMAR_A2S_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login for the install step |
| STEAM_PASSWORD | (empty) | Steam password, only needed if anonymous install fails |
| STEAM_GUARD_CODE | (empty) | Steam Guard code for the login step |
| STEAMCMD_WINDOWS_WORKAROUND | full | SteamCMD depot fetch mode (full, prime, or off). full pulls a Windows depot pass before the Linux depot |
| ARMAR_APP_ID | 1874900 | SteamCMD app id. Set 1890870 for the experimental branch |
| ARMAR_FORCE_UPDATE | false | Re-run SteamCMD install on next start |
| ARMAR_BIND_PORT | 2001 | Game UDP port, must match the compose port mapping |
| ARMAR_A2S_PORT | 17777 | A2S query UDP port, must match the compose port mapping |
| ARMAR_SERVER_NAME | Arma Reforger Server | Browser name, seeds config only. Edit JSON later for live changes |
| ARMAR_MAX_PLAYERS | 16 | Player cap in generated config |
| ARMAR_SCENARIO_ID | {59AD59368755F41A}Missions/23_Campaign.conf | Scenario path. Default is Conflict on Everon |
| ARMAR_MAX_FPS | 60 | Server FPS cap |
| ARMAR_EXTRA_ARGS | (empty) | Extra CLI args appended to the launch command |

After the first start, edit arma/reforger/data/Configs/ServerConfig.json directly for hostname, password, RCON, mods, and scenario. Restart the container to apply changes.

## Updates

Set ARMAR_FORCE_UPDATE to true to reinstall on the next start. You can also run ./tools/gs update arma-reforger. See [Ops](/guides/ops/) for backup, restore, and update.

## Health check

The container reports healthy while the Arma Reforger server process is running. Startup gets a 1200 second grace period because first install and validation can take a while.

## Modding

Reforger mods use the **Arma Reforger Workshop** at [reforger.armaplatform.com/workshop](https://reforger.armaplatform.com/workshop). This is not Steam Workshop. Do not use workshop_download_item or numeric Steam Workshop IDs.

### Find a mod ID

1. Open the mod on [reforger.armaplatform.com/workshop](https://reforger.armaplatform.com/workshop).
2. Copy the 16-character hexadecimal GUID from the page URL (for example 591AF5BDA9F7CE8B).
3. Optionally subscribe in the game client and read ServerData.json under Documents/my games/ArmaReforger/addons/ for id, name, and version.

### Add mods in ServerConfig.json

Edit game.mods inside Configs/ServerConfig.json:

```json
"mods": [
  { "modId": "591AF5BDA9F7CE8B", "name": "Capture & Hold", "version": "1.0.8" },
  { "modId": "5965520F24A0E525", "name": "Example Mod" }
]
```

| Field | Notes |
| --- | --- |
| modId | Required. 16-char hex from the Reforger Workshop URL |
| name | Optional. Helps logs and admin tools |
| version | Optional. Omit to always use the latest published version |
| required | Optional. When true, clients must have the mod |

The dedicated server downloads listed mods on startup into the profile/addons area under your data folder. Load order matters. List framework and dependency mods before mods that depend on them.

Other useful game settings:

- modsRequiredByDefault forces clients to download mods before join when enabled.
- Modded scenarios use a scenarioId that points at the mod mission. Use -listScenarios via ARMAR_EXTRA_ARGS to discover scenarios.

### Cross-platform

PC, Xbox, and PlayStation can join many modded servers, but individual mods may be PC-only depending on author restrictions. Test with your target platforms before advertising a modded server.

### Mod troubleshooting

| Symptom | Things to check |
| --- | --- |
| Server exits on start | Invalid JSON in ServerConfig.json (trailing commas, bad quotes) |
| Mod not loading | Wrong modId (Steam numeric ID instead of Reforger hex GUID) |
| Clients cannot join | Missing dependency mod or wrong load order |
| Wrong scenario | scenarioId does not match a scenario from installed mods |

## RCON and admin

The generated config is minimal. For RCON, add an rcon block to ServerConfig.json (see [community examples](https://community.bistudio.com/wiki/Arma_Reforger:Server_Hosting)) with port, password, and permission. Use a strong password and restrict who can reach the RCON port if you publish it.

## Compose

```bash
docker compose -f arma/reforger/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name arma-reforger --restart unless-stopped --init \
  -p 2001:2001/udp -p 17777:17777/udp \
  -v "$PWD/arma/reforger/data:/opt/arma-reforger" \
  -e STEAMCMD_WINDOWS_WORKAROUND=full \
  {{IMAGE_PREFIX}}/arma-reforger:latest
```

## See also

- [All servers](/reference/servers/) for compose paths and image names
- [Ops](/guides/ops/) for ./tools/gs backup, restore, and update
