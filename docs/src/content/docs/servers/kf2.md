---
title: Killing Floor 2
description: Killing Floor 2 dedicated server via SteamCMD, App 232130.
---

On first start the container downloads the Killing Floor 2 dedicated server through Steam, then launches the Unreal Engine 3 dedicated server binary. Killing Floor 2 is free to play, so anonymous Steam login normally works.

:::note[Before you start]
- Open UDP port 7777, UDP port 27015, TCP port 8080, and UDP port 20560
- Keep a data folder mounted at /opt/kf2 inside the container
- Set STEAM_USERNAME and STEAM_PASSWORD only if an anonymous install fails
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7777 | UDP | Main game port (KF2_PORT) |
| 27015 | UDP | Query port for the server browser (KF2_QUERY_PORT) |
| 8080 | TCP | WebAdmin. Fixed port. Enable and set credentials in KFGame/Config/PCServer-KFWeb.ini |
| 20560 | UDP | Steam networking port. Fixed and not configurable through settings |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam account used to download server files |
| STEAM_PASSWORD | (empty) | Password for STEAM_USERNAME when not using anonymous login |
| STEAM_GUARD_CODE | (empty) | One-time Steam Guard dockerized/code if Steam challenges the login |
| KF2_APP_ID | 232130 | Steam app id for the dedicated server download |
| KF2_FORCE_UPDATE | false | Re-download and validate server files on next start |
| STEAMCMD_WINDOWS_WORKAROUND | full | How SteamCMD fetches depots. full downloads a Windows pass first, then Linux. prime and off are lighter options |
| KF2_PORT | 7777 | Game port |
| KF2_QUERY_PORT | 27015 | Query port |
| KF2_STARTMAP | kf-bioticslab | Map loaded at startup |
| KF2_EXTRA_ARGS | (empty) | Extra launch flags appended after the built-in ones. Use this for map options like ?MaxPlayers=6 or ?Difficulty=4 |

There is no KF2_MAXPLAYERS setting. Set player count, difficulty, game length, and web admin login through KF2_EXTRA_ARGS map options or by editing the .ini files under KFGame/Config/ in your data folder.

## Data folder

Your data folder mounts to /opt/kf2 inside the container.

| Path | Purpose |
| --- | --- |
| Binaries/Win64/KFGameSteamServer.bin.x86_64 | Server executable (native Linux binary despite the Win64 folder name) |
| steam_appid.txt | Written on every start with app id 232090 for Steamworks |
| KFGame/Config/PCServer-KFGame.ini | Gameplay config: mutators, difficulty, game length |
| KFGame/Config/PCServer-KFEngine.ini | Engine and networking config |
| KFGame/Config/PCServer-KFWeb.ini | WebAdmin port and login credentials |
| KFGame/Logs/ | Server logs |
| linux64/steamclient.so, linux32/steamclient.so | Steam client libraries copied from the image on every start for the Steamworks API |

## Updates

Set KF2_FORCE_UPDATE to true and recreate the container, or use the update workflow in [Ops](/guides/ops/).

Every install and forced update re-downloads and validates server files. If you have heavily customized .ini files under KFGame/Config/, back them up before setting KF2_FORCE_UPDATE to true.

## Health check

The container reports healthy while the game server process is running. The KF2 download is large, so startup gets a 900 second grace period.

## Notes

- The container starts as root, fixes ownership of the data folder, then runs the server as the dockerized/kf2 user (uid 1000).
- Steam client libraries are copied into the data folder on every start, even when KF2_FORCE_UPDATE is not set.
- Compose sets a 4 GB memory limit and a 90 second stop grace period. The image sends SIGTERM on stop.

## Compose

```bash
docker compose -f dockerized/kf2/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name kf2 --restart unless-stopped --init \
  -p 7777:7777/udp -p 27015:27015/udp -p 8080:8080/tcp -p 20560:20560/udp \
  -v "$PWD/dockerized/kf2/data:/opt/kf2" \
  {{IMAGE_PREFIX}}/kf2:latest
```
