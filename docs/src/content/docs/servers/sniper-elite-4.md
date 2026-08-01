---
title: Sniper Elite 4
description: Sniper Elite 4 dedicated server (Windows binary via Wine).
---

This image downloads the Sniper Elite 4 dedicated server through Steam and runs the Windows build under Wine. On first start it also sets up a Wine environment, so expect the initial launch to take longer than later restarts.

:::note[Before you start]
- Keep a data folder for the server install and config
- Open UDP ports 27000 (auth), 27005 (game), TCP 27010 (lobby), and UDP 27015 (update)
- Anonymous Steam login works for most installs. If the download fails or the server does not list publicly, use a Steam account that owns Sniper Elite 4
- The compose file sets a 2 GB memory limit
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27000 | UDP | Authentication (SE4_AUTH_PORT) |
| 27005 | UDP | Game traffic (SE4_GAME_PORT) |
| 27010 | TCP | Lobby (SE4_LOBBY_PORT) |
| 27015 | UDP | Update channel (SE4_UPDATE_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used to download the server |
| STEAM_PASSWORD | (empty) | Steam password, required when using a real account |
| STEAM_GUARD_CODE | (empty) | Steam Guard code if prompted during login |
| SE4_APP_ID | 568880 | Steam app id for the dedicated server tool |
| SE4_STEAM_APP_ID | 312660 | Game app id, written to steam_appid.txt |
| SE4_FORCE_UPDATE | false | Reinstall the server on next start |
| SE4_AUTH_PORT | 27000 | Server.AuthPort in server.cfg |
| SE4_GAME_PORT | 27005 | Server.GamePort in server.cfg |
| SE4_LOBBY_PORT | 27010 | Server.LobbyPort in server.cfg |
| SE4_UPDATE_PORT | 27015 | Server.UpdatePort in server.cfg |
| SE4_SERVER_NAME | Sniper Elite 4 Server | Server.Name in server.cfg |
| SE4_MAX_PLAYERS | 12 | Settings.MaxPlayers in server.cfg |
| SE4_MAP_ROTATION | VILLAGE:DM,RIVIERA:DM,COMPOUND:DM,RAILYARD:DM,DOCKYARD:DM | Comma-separated MAP:MODE pairs for map rotation |
| SE4_EXTRA_ARGS | (empty) | Extra flags appended to the launch command |

## Data folder

Your data folder mounts at /opt/se4 inside the container.

| Path | Purpose |
| --- | --- |
| server.cfg | Generated once from the settings above, then left alone. Must end with a Server.Host line for hosting to start |
| .wine/ | Wine prefix, created on first start |
| steam_appid.txt | Rewritten every start with SE4_STEAM_APP_ID |

Edit server.cfg directly for settings beyond map rotation and player count. If SteamCMD installs files under a nested steamapps/common folder, the container moves them up into /opt/se4 on first start.

## Tuning the server

Stop the container, edit sniper-elite-4/data/server.cfg, and start again. The server reads the file once at launch. Useful lines beyond what the settings above generate:

| Setting | What it does |
| --- | --- |
| Server.MoTD | Message of the day shown to joining players |
| Server.AddTimedText plus Server.TimedTextInterval | Repeats a chat message on a timer |
| Rcon.Password | Enables remote admin commands |
| Settings.DefaultScoreLimit / Settings.DefaultTimeLimit | Per-round score and time limits |
| Settings.MaxLatency | Kicks players above a ping threshold |
| Lobby.StartTimer | How long the pre-match lobby waits before starting |
| exec Preset_Hardcore.cfg | Applies a bundled ruleset. Add before Server.Host |

Server.Host must stay the last line in the file. Anything after it is ignored. Running more than one instance on the same host needs a separate data folder and a fully distinct port set per instance.

The container fixes file ownership on the data folder automatically on every start.

## Updates

Set SE4_FORCE_UPDATE to true to reinstall on the next start. You can also run ./tools/gs update sniper-elite-4. See [Ops](/guides/ops/).

## Health check

The container reports healthy while the Sniper Elite 4 server process is running. Startup gets a 300 second grace period.

## Compose

```bash
docker compose -f sniper-elite-4/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name sniper-elite-4 --restart unless-stopped --init \
  -p 27000:27000/udp -p 27005:27005/udp -p 27010:27010/tcp -p 27015:27015/udp \
  -v "$PWD/sniper-elite-4/data:/opt/se4" \
  -e SE4_SERVER_NAME="My SE4 Server" \
  {{IMAGE_PREFIX}}/sniper-elite-4:latest
```
