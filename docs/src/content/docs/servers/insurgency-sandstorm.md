---
title: Insurgency Sandstorm
description: Insurgency Sandstorm dedicated server, mods, and tokens.
---

Compose path: insurgency-sandstorm. Image: insurgency-sandstorm.

## Behavior

Downloads the Linux dedicated server (Steam App 581330) on first start. Data volume: `insurgency-sandstorm/data` mounted at `/opt/insurgency-sandstorm`.

- Game: UDP 27102 (`INS_SANDSTORM_PORT`)
- Query: UDP 27131 (`INS_SANDSTORM_QUERY_PORT`)
- Default map and scenario: `Oilfield` / `Scenario_Refinery_Push_Security`
- Updates: `INS_SANDSTORM_FORCE_UPDATE=true` or `./tools/gs update insurgency-sandstorm`, see [Ops](/guides/ops/) for `backup` and `restore` too
- Allocate at least 8 GB RAM for the container

## Docker run

```bash
docker run -d --name insurgency-sandstorm --restart unless-stopped --init \
  -p 27102:27102/udp -p 27131:27131/udp \
  -v "$PWD/insurgency-sandstorm/data:/opt/insurgency-sandstorm" \
  -e INS_SANDSTORM_GSLT="your-gslt" \
  -e INS_SANDSTORM_GAMESTATS_TOKEN="your-gamestats-token" \
  {{IMAGE_PREFIX}}/insurgency-sandstorm:latest
```

## Environment

| Variable | Default | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME` | `anonymous` | Steam login for the install step |
| `STEAM_PASSWORD` | (empty) | Steam password, needed alongside a real `STEAM_USERNAME` |
| `STEAM_GUARD_CODE` | (empty) | Steam Guard code, only needed if Steam challenges the login |
| `STEAMCMD_WINDOWS_WORKAROUND` | `prime` | SteamCMD depot fetch mode (`full`, `prime`, or `off`), inherited from the shared SteamCMD helper |
| `INS_SANDSTORM_APP_ID` | `581330` | SteamCMD app id for the dedicated server depot |
| `INS_SANDSTORM_FORCE_UPDATE` | `false` | Set `true` to force `app_update 581330 validate` on next start, same var `./tools/gs update insurgency-sandstorm` sets |
| `INS_SANDSTORM_PORT` | `27102` | Game UDP port |
| `INS_SANDSTORM_QUERY_PORT` | `27131` | Query UDP port |
| `INS_SANDSTORM_MAP` | `Oilfield` | Map name |
| `INS_SANDSTORM_SCENARIO` | `Scenario_Refinery_Push_Security` | Scenario id |
| `INS_SANDSTORM_MAXPLAYERS` | `28` | Player cap |
| `INS_SANDSTORM_HOSTNAME` | `Sandstorm Server` | Server browser name |
| `INS_SANDSTORM_GSLT` | (empty) | Game Server Login Token for Steam listing |
| `INS_SANDSTORM_GAMESTATS_TOKEN` | (empty) | Enables `-GameStats` and passes `-GameStatsToken=...` |
| `INS_SANDSTORM_EXTRA_ARGS` | (empty) | Extra CLI flags (mutators, `-mods`, travel, and so on) |

Set tokens in `docker-compose.yml`, a `.env` file, or `-e` on `docker run`. The entrypoint writes `581320` to `steam_appid.txt` on every start regardless of `INS_SANDSTORM_APP_ID`, that is the base game's Steamworks app id and is what GSLT tokens are issued against, not the `581330` dedicated server depot.

## GSLT and GameStats token

**GSLT (Game Server Login Token)**

1. Sign in with your Steam account at [Steam game server account management](https://steamcommunity.com/dev/managegameservers).
2. Create a token for Insurgency: Sandstorm (App ID 581320).
3. Set `INS_SANDSTORM_GSLT` to that token. The image passes `-GSLTToken=...` on startup.

**GameStats token**

1. Connect with Steam at [Sandstorm GameStats](https://gamestats.sandstorm.game/).
2. Copy your GameStats token.
3. Set `INS_SANDSTORM_GAMESTATS_TOKEN`. The image adds `-GameStats` and `-GameStatsToken=...`.

Equivalent startup flags when both are set via env:

```text
-GSLTToken=A1234 -GameStats -GameStatsToken=1234
```

If you manage flags only through `INS_SANDSTORM_EXTRA_ARGS`, leave `INS_SANDSTORM_GAMESTATS_TOKEN` empty and pass `-GameStats` and `-GameStatsToken=...` there yourself.

## Modding

### Finding mods and IDs

Browse [mod.io Insurgency Sandstorm](https://mod.io/g/insurgencysandstorm). Open a mod and note the **ID** on the right (numeric). Keep a local list with comments for each id.

### Config files

On the host, under the data volume, create:

```text
insurgency-sandstorm/data/Insurgency/Config/Server/
```

Add these text files:

| File | Purpose |
| --- | --- |
| `Admins.txt` | Steam64 IDs of server admins ([Steam ID Finder](https://www.steamidfinder.com/) helps) |
| `MapCycle.txt` | Maps on the vote screen. Modded maps often document the line to use on their mod.io page |
| `Mods.txt` | One mod.io mod ID per line |

Create the folders after the first successful server install so the `Insurgency` tree exists, or create `Insurgency/Config/Server` yourself before first start.

### Mutators

Pass mutators through `INS_SANDSTORM_EXTRA_ARGS` in compose or `.env`:

```yaml
INS_SANDSTORM_EXTRA_ARGS: >-
  -mutators=AllYouCanEat,Fullkit,Medicon,AdminCommands,Reloads,NoRestrictedArea,RealisticHealth
```

### Mods

1. Fill `Mods.txt` with mod.io IDs.
2. Add the `-mods` flag in `INS_SANDSTORM_EXTRA_ARGS` (reads `Mods.txt` from `Insurgency/Config/Server/`).

Example combining mutators and mods:

```yaml
INS_SANDSTORM_EXTRA_ARGS: >-
  -mutators=AllYouCanEat,Fullkit,Medicon,AdminCommands,Reloads,NoRestrictedArea,RealisticHealth
  -mods
```

### ModDownloadTravelTo

After mods download, the server can travel to a map and scenario with mutators. Add this to `INS_SANDSTORM_EXTRA_ARGS` after `-mutators`:

```text
-ModDownloadTravelTo="Farmhouse?Scenario=Scenario_Farmhouse_Checkpoint_Security?Lighting=Day?MaxPlayers=12?Mutators=Fullkit"
```

If you use **Fullkit** or **ISMCarmory_Legacy**, include the matching mutator name in the `Mutators=` query at the end of the travel string.

Full compose example:

```yaml
environment:
  INS_SANDSTORM_GSLT: "${INS_SANDSTORM_GSLT:-}"
  INS_SANDSTORM_GAMESTATS_TOKEN: "${INS_SANDSTORM_GAMESTATS_TOKEN:-}"
  INS_SANDSTORM_EXTRA_ARGS: >-
    -mutators=Fullkit,Medicon,Reloads
    -mods
    -ModDownloadTravelTo="Farmhouse?Scenario=Scenario_Farmhouse_Checkpoint_Security?Lighting=Day?MaxPlayers=12?Mutators=Fullkit"
```

Restart the container after changing config files or env vars.

## See also

- [All servers](/reference/servers/) for the compose path and image name
- [Ops](/guides/ops/) for `./tools/gs backup`, `restore`, and `update`
