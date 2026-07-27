---
title: Arma 3
description: Arma 3 dedicated server.
---

Compose path: arma/arma-3. Image: arma-3.

Arma 3 usually needs a Steam account that owns the server files. Set STEAM_USERNAME and STEAM_PASSWORD.

## Volumes

- server → /home/arma3/server
- configs → /home/arma3/configs
- profiles → /home/arma3/profiles
- cache → /home/arma3/cache

## Ports

UDP 2302-2306

## Docker run

```bash
docker run -d --name arma3 --restart unless-stopped \
  -p 2302-2306:2302-2306/udp \
  -v "$PWD/arma/arma-3/server:/home/arma3/server" \
  -v "$PWD/arma/arma-3/configs:/home/arma3/configs" \
  -v "$PWD/arma/arma-3/profiles:/home/arma3/profiles" \
  -v "$PWD/arma/arma-3/cache:/home/arma3/cache" \
  -e STEAM_USERNAME=youruser \
  -e STEAM_PASSWORD=yourpass \
  {{IMAGE_PREFIX}}/arma-3:latest
```
