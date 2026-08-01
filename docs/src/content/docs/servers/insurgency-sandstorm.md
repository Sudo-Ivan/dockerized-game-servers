---
title: Insurgency Sandstorm
description: Insurgency Sandstorm dedicated server, mods, and tokens.
---

On first start the container downloads the Linux dedicated server (Steam app 581330) into your data folder. The default map and scenario are Oilfield and Scenario_Refinery_Push_Security. Give the container at least 8 GB of RAM.

:::note[Before you start]
- Open UDP port 27102 for game traffic and UDP port 27131 for server queries
- Keep a data folder mounted at /opt/insurgency-sandstorm inside the container
- Set INS_SANDSTORM_GSLT for public Steam listing
- Set INS_SANDSTORM_GAMESTATS_TOKEN if you want GameStats tracking
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27102 | UDP | Game port (INS_SANDSTORM_PORT) |
| 27131 | UDP | Query port (INS_SANDSTORM_QUERY_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam account used to download server files |
| STEAM_PASSWORD | (empty) | Password for STEAM_USERNAME when not using anonymous login |
| STEAM_GUARD_CODE | (empty) | One-time Steam Guard code if Steam challenges the login |
| STEAMCMD_WINDOWS_WORKAROUND | prime | How SteamCMD fetches depots. full, prime, and off control how much is downloaded |
| INS_SANDSTORM_APP_ID | 581330 | Steam app id for the dedicated server download |
| INS_SANDSTORM_FORCE_UPDATE | false | Re-download and validate server files on next start |
| INS_SANDSTORM_PORT | 27102 | Game UDP port |
| INS_SANDSTORM_QUERY_PORT | 27131 | Query UDP port |
| INS_SANDSTORM_MAP | Oilfield | Map name |
| INS_SANDSTORM_SCENARIO | Scenario_Refinery_Push_Security | Scenario id |
| INS_SANDSTORM_MAXPLAYERS | 28 | Maximum players |
| INS_SANDSTORM_HOSTNAME | Sandstorm Server | Name shown in the server browser |
| INS_SANDSTORM_GSLT | (empty) | Game Server Login Token for Steam listing |
| INS_SANDSTORM_GAMESTATS_TOKEN | (empty) | Enables GameStats and passes the token to the server |
| INS_SANDSTORM_EXTRA_ARGS | (empty) | Extra command-line flags (mutators, mods, travel, and so on) |

Set tokens in docker-compose.yml, a .env file, or with -e on docker run. The container writes app id 581320 to steam_appid.txt on every start. That is the base game's Steamworks id (what GSLT tokens are issued against), not the 581330 dedicated server download id.

## GSLT and GameStats token

**GSLT (Game Server Login Token)**

1. Sign in with your Steam account at [Steam game server account management](https://steamcommunity.com/dev/managegameservers).
2. Create a token for Insurgency: Sandstorm (app id 581320).
3. Set INS_SANDSTORM_GSLT to that token. The server passes -GSLTToken on startup.

**GameStats token**

1. Connect with Steam at [Sandstorm GameStats](https://gamestats.sandstorm.game/).
2. Copy your GameStats token.
3. Set INS_SANDSTORM_GAMESTATS_TOKEN. The server adds -GameStats and -GameStatsToken.

Equivalent startup flags when both are set:

```text
-GSLTToken=A1234 -GameStats -GameStatsToken=1234
```

If you manage flags only through INS_SANDSTORM_EXTRA_ARGS, leave INS_SANDSTORM_GAMESTATS_TOKEN empty and pass -GameStats and -GameStatsToken there yourself.

## Modding

### Finding mods and IDs

Browse [mod.io Insurgency Sandstorm](https://mod.io/g/insurgencysandstorm). Open a mod and note the numeric ID on the right. Keep a local list with notes for each id.

### Config files

On the host, under the data folder, create:

```text
insurgency-sandstorm/data/Insurgency/Config/Server/
```

Add these text files:

| File | Purpose |
| --- | --- |
| Admins.txt | Steam64 IDs of server admins ([Steam ID Finder](https://www.steamidfinder.com/) helps) |
| MapCycle.txt | Maps on the vote screen. Modded maps often document the line to use on their mod.io page |
| Mods.txt | One mod.io mod ID per line |

Create the folders after the first successful server install so the Insurgency tree exists, or create Insurgency/Config/Server yourself before first start.

### Mutators

Pass mutators through INS_SANDSTORM_EXTRA_ARGS in compose or .env:

```yaml
INS_SANDSTORM_EXTRA_ARGS: >-
  -mutators=AllYouCanEat,Fullkit,Medicon,AdminCommands,Reloads,NoRestrictedArea,RealisticHealth
```

### Mods

1. Fill Mods.txt with mod.io IDs.
2. Add the -mods flag in INS_SANDSTORM_EXTRA_ARGS (reads Mods.txt from Insurgency/Config/Server/).

Example combining mutators and mods:

```yaml
INS_SANDSTORM_EXTRA_ARGS: >-
  -mutators=AllYouCanEat,Fullkit,Medicon,AdminCommands,Reloads,NoRestrictedArea,RealisticHealth
  -mods
```

### ModDownloadTravelTo

After mods download, the server can travel to a map and scenario with mutators. Add this to INS_SANDSTORM_EXTRA_ARGS after -mutators:

```text
-ModDownloadTravelTo="Farmhouse?Scenario=Scenario_Farmhouse_Checkpoint_Security?Lighting=Day?MaxPlayers=12?Mutators=Fullkit"
```

If you use Fullkit or ISMCarmory_Legacy, include the matching mutator name in the Mutators= query at the end of the travel string.

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

Restart the container after changing config files or settings.

## Compose

```bash
docker compose -f insurgency-sandstorm/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name insurgency-sandstorm --restart unless-stopped --init \
  -p 27102:27102/udp -p 27131:27131/udp \
  -v "$PWD/insurgency-sandstorm/data:/opt/insurgency-sandstorm" \
  -e INS_SANDSTORM_GSLT="your-gslt" \
  -e INS_SANDSTORM_GAMESTATS_TOKEN="your-gamestats-token" \
  {{IMAGE_PREFIX}}/insurgency-sandstorm:latest
```

## Updates

Set INS_SANDSTORM_FORCE_UPDATE to true and recreate the container, or use the update workflow in [Ops](/guides/ops/). The same guide covers backup and restore.

## Health check

The container reports healthy while the game server process is running.

## See also

- [All servers](/reference/servers/) for compose paths and image names
- [Ops](/guides/ops/) for backup, restore, and update
