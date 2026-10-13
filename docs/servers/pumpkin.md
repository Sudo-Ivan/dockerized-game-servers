---
title: Pumpkin
description: Pumpkin dedicated server, a Rust Minecraft server for Java and Bedrock clients, from upstream release binaries.
game_icon: game-icons/pumpkin.jpg
game_icon_fit: contain
---

# Pumpkin

This image ships the upstream [Pumpkin](https://github.com/Pumpkin-MC/Pumpkin) release binary. It needs no Java and no game data download: the server binary is self contained and creates a world on first start. Pumpkin is under heavy development, so expect missing features compared with the vanilla server.

!!! note "Before you start"

    - Keep a data folder for the world and pumpkin.toml
    - Open TCP port 25565 for Java clients and UDP 19132/19133 for Bedrock clients

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 25565 | TCP | Java clients (PUMPKIN_PORT) |
| 19132 | UDP | Bedrock clients IPv4 (PUMPKIN_BEDROCK_PORT) |
| 19133 | UDP | Bedrock clients IPv6 |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| PUMPKIN_IP | 0.0.0.0 | Bind address |
| PUMPKIN_PORT | 25565 | Java TCP port, written into pumpkin.toml only when that file is first created |
| PUMPKIN_BEDROCK | true | Listen for Bedrock clients |
| PUMPKIN_BEDROCK_PORT | 19132 | Bedrock UDP port, IPv6 clients use the next port |
| PUMPKIN_MOTD | A blazingly fast Pumpkin server! | Server list text for Java and Bedrock |
| PUMPKIN_MAX_PLAYERS | 1000 | Max players |
| PUMPKIN_ONLINE_MODE | true | Authenticate players against Microsoft |
| PUMPKIN_SEED | (empty) | World seed, a random seed is used when empty |
| PUMPKIN_GAMEMODE | Survival | Default game mode |
| PUMPKIN_DIFFICULTY | Normal | Default difficulty |
| PUMPKIN_EXTRA_ARGS | (empty) | Extra arguments appended to the pumpkin command |

All of these are written into pumpkin.toml only when that file is first created. After that, edit poderized/pumpkin/data/pumpkin.toml on the host to change settings. Pumpkin fills in any missing keys with its own defaults on startup.

## Data folder

Your data folder mounts to /data inside the container and holds the world, pumpkin.toml, nethernet-key.der, and log files.

## Updates

The image carries one pinned upstream release and verifies it by sha256 at build time. Rebuild the image to move to a newer pinned version, or bump PUMPKIN_VERSION and PUMPKIN_SHA256 in the Containerfile.

## Health check

The container reports healthy while the Java port is listening.

## Compose

```bash
podman compose -f poderized/pumpkin/compose.yml up -d
```

## podman run

```bash
podman run -d --name pumpkin --restart unless-stopped --init \
  -p 25565:25565/tcp \
  -p 19132:19132/udp \
  -p 19133:19133/udp \
  -v "$PWD/poderized/pumpkin/data:/data" \
  -e PUMPKIN_PORT=25565 \
  -e PUMPKIN_BEDROCK=true \
  -e PUMPKIN_MOTD="A blazingly fast Pumpkin server!" \
  {{IMAGE_PREFIX}}/pumpkin:latest
```
