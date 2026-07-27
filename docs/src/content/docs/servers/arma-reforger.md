---
title: Arma Reforger
description: Arma Reforger dedicated server via SteamCMD.
---

Compose path: arma/reforger. Image: arma-reforger.

Steam App **1874900** (stable dedicated server). Anonymous Steam login usually works after the Windows-then-Linux SteamCMD workaround (`STEAMCMD_WINDOWS_WORKAROUND=full`, the default in compose). If install still fails, set `STEAM_USERNAME` and `STEAM_PASSWORD`. The native Linux binary is `ArmaReforgerServer`. Data volume: `arma/reforger/data` at `/opt/arma-reforger`.

## Defaults

- UDP **2001** game (`ARMAR_BIND_PORT`)
- UDP **17777** A2S (`ARMAR_A2S_PORT`)
- Config: `Configs/ServerConfig.json` (written on first start if missing)
- Profile: `profile/` under the data volume
- Scenario: `ARMAR_SCENARIO_ID` (default Conflict on Everon)
- Updates: `ARMAR_FORCE_UPDATE=true`

Experimental server branch: set `ARMAR_APP_ID=1890870`.

## Docker run

```bash
docker run -d --name arma-reforger --restart unless-stopped --init \
  -p 2001:2001/udp -p 17777:17777/udp \
  -v "$PWD/arma/reforger/data:/opt/arma-reforger" \
  {{IMAGE_PREFIX}}/arma-reforger:latest
```

Allocate at least 6 GB RAM for the container.
