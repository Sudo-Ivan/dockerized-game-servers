---
title: Eco
description: Eco dedicated server via SteamCMD.
---

Compose path: eco. Image: eco.

Steam App 739590. Installs on first start into `eco/data` (`/opt/eco`). **Requires `ECO_USER_TOKEN`**: create a server registration token in the Eco client. The container exits if the token is missing.

## Ports and volume

- UDP 3000 and 3001
- Data: `eco/data`
- Updates: `ECO_FORCE_UPDATE=true`
- Extra args: `ECO_EXTRA_ARGS`

Allocate at least 4 GB RAM.

## Docker run

```bash
docker run -d --name eco --restart unless-stopped --init \
  -p 3000:3000/udp -p 3001:3001/udp \
  -v "$PWD/eco/data:/opt/eco" \
  -e ECO_USER_TOKEN="your-token-here" \
  {{IMAGE_PREFIX}}/eco:latest
```

SteamCMD uses anonymous login for the dedicated app where Valve allows it. If install fails, use `STEAM_USERNAME` and `STEAM_PASSWORD` for an account that owns Eco.
