---
title: "Joint Operations: Typhoon Rising"
description: Joint Operations multiplayer host running jointops.exe under Wine and Xvfb with the documented server flags.
---

NovaLogic never shipped a headless dedicated server for Joint Operations. Hosting works by running the full game with `/w /serveonly`, which is what this image does under Wine and a virtual display. You must own Joint Operations: Typhoon Rising.

:::note[Before you start]
- You must own Joint Operations: Typhoon Rising
- Copy a Windows install patched to 1.7.5.7 into the data folder before the first start
- Keep a data folder for the game install and Wine prefix
- Open UDP ports 7597, 32768, 49152 and 64206 on both host and container
:::

## Required game files

Copy your Joint Operations install into the data folder so this file exists:

```text
dockerized/joint-operations/data/jointops.exe
```

A disc install patched to 1.7.5.7 or a Steam library backup both work. The Wine prefix is created automatically inside the same folder.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7597 | UDP | NovaWorld session traffic |
| 32768 | UDP | Main game port, the one to forward for public hosting |
| 49152 | UDP | Game traffic |
| 64206 | UDP | Game traffic |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| JO_SERVEONLY | true | Launch with /w /serveonly, the server mode. Set false to launch a normal game window under Xvfb |
| JO_EXTRA_ARGS | (empty) | Extra flags appended to the jointops.exe command |

## Server configuration

The host is a full game instance in serve-only mode, so all the usual Joint Operations hosting files apply:

- `game.cfg` in the install folder holds multiplayer settings like `mpipaddressstring` and the `mpgateserverlocalport*` range
- Sessions are administered live through the NovaLogic remote admin tool (RAT) or a community manager like the NovaHQ tools
- Community exes such as the FMJ-Squad JOexeFIX server builds (32/64/125 Hz tick rates, empty-server crash fix) are drop-in replacements for `jointops.exe` and work inside the container

## NovaWorld is dead

The official NovaWorld lobby is gone. Public server listing needs a community NovaWorld replacement such as the one NovaHQ runs. LAN hosting works without it: set the client to direct connect to the host IP. With NovaWorld or a replacement, also set `mpipaddressstring` in `game.cfg` to your public address and forward UDP 32768.

## Updates

There is no one-command update for this host. The game files are yours: replace `jointops.exe` or drop in a community server build in the data folder and restart.

## Health check

The container reports healthy while the `jointops.exe` process is running. Startup gets a 300 second grace period because the Wine prefix is initialized on first start.

## Compose

```bash
podman compose -f dockerized/joint-operations/compose.yml up -d
```

## podman run

```bash
podman run -d --name joint-operations --restart unless-stopped --init \
  -p 7597:7597/udp -p 32768:32768/udp \
  -p 49152:49152/udp -p 64206:64206/udp \
  -v "$PWD/dockerized/joint-operations/data:/opt/jointops" \
  {{IMAGE_PREFIX}}/joint-operations:latest
```
