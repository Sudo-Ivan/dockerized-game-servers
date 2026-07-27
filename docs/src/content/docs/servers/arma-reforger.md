---
title: Arma Reforger
description: Arma Reforger dedicated server via SteamCMD.
---

Compose path: arma/reforger. Image: arma-reforger.

Steam App **1874900** (stable dedicated server). Anonymous Steam login usually works after the Windows-then-Linux SteamCMD workaround (`STEAMCMD_WINDOWS_WORKAROUND=full`, the default in compose). If install still fails, set `STEAM_USERNAME` and `STEAM_PASSWORD`. The native Linux binary is `ArmaReforgerServer`. Data volume: `arma/reforger/data` at `/opt/arma-reforger`.

Official reference: [Arma Reforger server hosting](https://community.bistudio.com/wiki/Arma_Reforger:Server_Hosting) on the Bohemia Community Wiki.

## Defaults

- UDP **2001** game (`ARMAR_BIND_PORT`)
- UDP **17777** A2S query (`ARMAR_A2S_PORT`)
- Config: `Configs/ServerConfig.json` (written on first start if missing)
- Profile: `profile/` under the data volume (logs, saves, downloaded mod data)
- Scenario: `ARMAR_SCENARIO_ID` (default Conflict on Everon)
- Updates: `ARMAR_FORCE_UPDATE=true`
- Extra CLI: `ARMAR_EXTRA_ARGS` (for example `-listScenarios` for debugging)

Experimental server branch: set `ARMAR_APP_ID=1890870`.

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | Steam login for the install step |
| `STEAM_PASSWORD` | (empty) | Steam password, only needed if anonymous install fails |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code for the login step |
| `STEAMCMD_WINDOWS_WORKAROUND` | `full` | SteamCMD depot fetch mode (`full`, `prime`, or `off`), `full` pulls a Windows depot pass before the Linux depot |
| `ARMAR_APP_ID` | `1874900` | SteamCMD app id, set `1890870` for the experimental branch |
| `ARMAR_FORCE_UPDATE` | `false` | Re-run SteamCMD install, same var `./tools/gs update arma-reforger` sets |
| `ARMAR_BIND_PORT` | `2001` | Game UDP port, must match the compose port mapping |
| `ARMAR_A2S_PORT` | `17777` | A2S query UDP port, must match the compose port mapping |
| `ARMAR_SERVER_NAME` | `Arma Reforger Server` | Browser name, seed config only, edit JSON later for live changes |
| `ARMAR_MAX_PLAYERS` | `16` | Player cap in generated config |
| `ARMAR_SCENARIO_ID` | `{59AD59368755F41A}Missions/23_Campaign.conf` | Scenario GUID path, this default is Conflict on Everon |
| `ARMAR_MAX_FPS` | `60` | Server FPS cap |
| `ARMAR_EXTRA_ARGS` | (empty) | Extra CLI args appended to the launch command, for example `-listScenarios` |

After the first start, edit `arma/reforger/data/Configs/ServerConfig.json` directly for hostname, password, RCON, mods, and scenario. Restart the container to apply changes.

The healthcheck is a process probe (`pgrep -f ArmaReforgerServer`) with a 1200s start period since first install and validation can take a while. See [Ops](/guides/ops/) for `./tools/gs backup`, `restore`, and `update`.

## Modding

Reforger mods use the **Arma Reforger Workshop** at [reforger.armaplatform.com/workshop](https://reforger.armaplatform.com/workshop). This is **not** Steam Workshop: do not use `workshop_download_item` or numeric Steam Workshop IDs.

### Find a mod ID (`modId`)

1. Open the mod on [reforger.armaplatform.com/workshop](https://reforger.armaplatform.com/workshop).
2. Copy the **16-character hexadecimal GUID** from the page URL (for example `591AF5BDA9F7CE8B`).
3. Optionally subscribe in the game client and read `ServerData.json` under `Documents/my games/ArmaReforger/addons/<mod>/` for `id`, `name`, and `version`.

### Add mods in `ServerConfig.json`

Edit `game.mods` inside `Configs/ServerConfig.json`:

```json
"mods": [
  { "modId": "591AF5BDA9F7CE8B", "name": "Capture & Hold", "version": "1.0.8" },
  { "modId": "5965520F24A0E525", "name": "Example Mod" }
]
```

| Field | Notes |
| --- | --- |
| `modId` | Required. 16-char hex from the Reforger Workshop URL |
| `name` | Optional. Helps logs and admin tools |
| `version` | Optional. Omit to always use the latest published version |
| `required` | Optional. When true, clients must have the mod |

The dedicated server **downloads listed mods on startup** into the profile/addons area under your data volume. **Load order matters**: list framework and dependency mods before mods that depend on them (for example ACE core before ACE extensions).

Other useful `game` settings:

- `modsRequiredByDefault` forces clients to download mods before join when enabled.
- Modded scenarios use a `scenarioId` that points at the mod mission (check the mod docs or discover scenarios with `-listScenarios` via `ARMAR_EXTRA_ARGS`).

### Cross-platform

PC, Xbox, and PlayStation can join many modded servers, but individual mods may be PC-only depending on author restrictions. Test with your target platforms before advertising a modded server.

### Mod troubleshooting

| Symptom | Things to check |
| --- | --- |
| Server exits on start | Invalid JSON in `ServerConfig.json` (trailing commas, bad quotes) |
| Mod not loading | Wrong `modId` (Steam numeric ID instead of Reforger hex GUID) |
| Clients cannot join | Missing dependency mod or wrong load order |
| Wrong scenario | `scenarioId` does not match a scenario from installed mods |

## RCON and admin

The generated config is minimal. For RCON, add an `rcon` block to `ServerConfig.json` (see [community examples](https://community.bistudio.com/wiki/Arma_Reforger:Server_Hosting)) with `port`, `password`, and `permission`. Use a strong password and restrict who can reach the RCON port if you publish it.

## Docker run

```bash
docker run -d --name arma-reforger --restart unless-stopped --init \
  -p 2001:2001/udp -p 17777:17777/udp \
  -v "$PWD/arma/reforger/data:/opt/arma-reforger" \
  -e STEAMCMD_WINDOWS_WORKAROUND=full \
  {{IMAGE_PREFIX}}/arma-reforger:latest
```

Allocate at least 6 GB RAM for the container. Mod-heavy servers need more CPU, RAM, and disk under `profile/`.

## See also

- [All servers](/reference/servers/) for the compose path and image name
- [Ops](/guides/ops/) for `./tools/gs backup`, `restore`, and `update`
