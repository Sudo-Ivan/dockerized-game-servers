---
title: DayZ
description: DayZ dedicated server via SteamCMD.
---

Compose path: dayz. Image: dayz.

Steam App **223350** (server). Workshop mods use client App **221100**. **You must use a Steam account that owns DayZ** for both server and workshop downloads. Anonymous SteamCMD cannot install the server depot.

Official reference: [DayZ: Hosting a Linux Server](https://community.bohemia.net/wiki/DayZ:Hosting_a_Linux_Server) on the Bohemia Community Wiki.

## Defaults

- UDP **2302** through **2306** (`DAYZ_PORT` is the main game port)
- Config: `serverDZ.cfg` in the data volume (default Chernarus offline mission)
- Profiles: `profiles/` (logs, persistence, admin tools)
- BattlEye: `battleye/` (copy and edit `beserver_x64.cfg` for RCon)
- Updates: `DAYZ_FORCE_UPDATE=true`
- Launch extras: `DAYZ_EXTRA_ARGS` (mods, custom flags)

Set `STEAM_USERNAME`, `STEAM_PASSWORD`, and optional `STEAM_GUARD_CODE` in compose or `.env`. Use a dedicated Steam account for the server, not your main gaming account.

## Environment

| Variable | Purpose |
| --- | --- |
| `DAYZ_PORT` | Main game UDP port |
| `DAYZ_HOSTNAME` | Seeds `hostname` in new `serverDZ.cfg` only |
| `DAYZ_MAX_PLAYERS` | Seeds `maxPlayers` in new `serverDZ.cfg` only |
| `DAYZ_FORCE_UPDATE` | Re-run SteamCMD for App 223350 |
| `DAYZ_EXTRA_ARGS` | Appended to the server command line (mods go here) |

Edit `dayz/data/serverDZ.cfg` on the host for live settings (`passwordAdmin`, time acceleration, `verifySignatures`, and so on).

## Modding

DayZ mods come from the **Steam Workshop** for the DayZ **client** (App ID **221100**). The server does not auto-subscribe for you: download mods with SteamCMD using the **same Steam login** that owns DayZ, then wire folders, keys, and `-mod` on the command line.

### 1. Download mods with SteamCMD

Run on the host (or `docker compose exec` with Steam credentials) with install dir set to your server data volume:

```bash
./steamcmd.sh +force_install_dir /path/to/dayz/data \
  +login YOUR_STEAM_USER YOUR_STEAM_PASSWORD \
  +workshop_download_item 221100 1559212036 \
  +workshop_download_item 221100 1564026768 \
  +quit
```

Replace the numeric IDs with Workshop mod IDs from each mod's Steam page (`?id=` in the URL). Files land under:

```text
dayz/data/steamapps/workshop/content/221100/<WORKSHOP_ID>/
```

Common examples (verify current IDs on Workshop before use):

| Mod | Typical Workshop ID |
| --- | --- |
| Community Framework | 1559212036 |
| Community Online Tools | 1564026768 |

### 2. Link mods into the server tree

Bohemia's Linux guide uses symlinks from the workshop content path into the server root, then references **numeric** mod IDs in `-mod`:

```bash
cd dayz/data
ln -s steamapps/workshop/content/221100/1559212036 1559212036
ln -s steamapps/workshop/content/221100/1564026768 1564026768
```

Some hosts use `@ModName` folders instead; names are case-sensitive and must match what you pass in `-mod`. Pick one convention and stay consistent.

### 3. Copy signature keys

With `verifySignatures = 2` in `serverDZ.cfg`, every mod's `.bikey` must be in `dayz/data/keys/`:

```bash
mkdir -p dayz/data/keys
cp dayz/data/steamapps/workshop/content/221100/1559212036/keys/*.bikey dayz/data/keys/
```

Missing keys usually cause kicks or "wrong signature" errors for clients.

### 4. Load mods at startup

Pass mods through `DAYZ_EXTRA_ARGS` in compose (semicolon-separated, **no spaces**):

```yaml
DAYZ_EXTRA_ARGS: '"-mod=1559212036;1564026768;"'
```

Or the `@Folder` style if you symlinked that way:

```yaml
DAYZ_EXTRA_ARGS: '"-mod=@CF;@COT;"'
```

**Load order matters**: Community Framework and other dependencies must appear **before** mods that require them. Restart the server after any mod change (no hot reload).

### 5. Update mods

Stop the server, re-run `workshop_download_item` for each ID (or add them to your update script), refresh symlinks if needed, copy any new `.bikey` files, then start again. The [Bohemia wiki](https://community.bohemia.net/wiki/DayZ:Hosting_a_Linux_Server) shows an `update.sh` pattern that removes old symlinks and keys before re-linking.

### Mod troubleshooting

| Symptom | Things to check |
| --- | --- |
| Server starts, mods ignored | `-mod=` missing from `DAYZ_EXTRA_ARGS` |
| Everyone kicked on join | `.bikey` not in `keys/` or `verifySignatures` too strict |
| Wrong version | Server workshop files out of date; clients must subscribe to same mods |
| BattlEye script errors | Mod not allowed by BE; check mod docs and server BE logs |
| Broken symlinks | Re-download mod and recreate `ln -s` into `dayz/data` |

Economy mods may ship extra `types.xml` or CE files you must merge into `mpmissions/` manually.

## BattlEye and RCon

After first install, configure BattlEye under `dayz/data/battleye/`. Set the RCon password in `beserver_x64.cfg` (or the active BE config for your build). Open the RCon port only if you need remote admin.

## Persistence and missions

Default generated config uses `dayzOffline.chernarusplus`. Other maps use different mission templates under `mpmissions/`. Back up `profiles/` and any custom mission folders before major updates.

## Docker run

```bash
docker run -d --name dayz --restart unless-stopped --init \
  -p 2302:2302/udp -p 2303:2303/udp -p 2304:2304/udp \
  -p 2305:2305/udp -p 2306:2306/udp \
  -v "$PWD/dayz/data:/opt/dayz" \
  -e STEAM_USERNAME="your_steam_user" \
  -e STEAM_PASSWORD="your_steam_password" \
  -e STEAM_GUARD_CODE="" \
  -e 'DAYZ_EXTRA_ARGS=-mod=1559212036;1564026768;' \
  {{IMAGE_PREFIX}}/dayz:latest
```

Allocate at least 6 GB RAM for vanilla; modded servers often need 8 GB or more.
