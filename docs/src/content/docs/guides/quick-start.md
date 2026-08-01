---
title: Quick start
description: Run a game server with Docker Compose or docker run.
---

## What you need

- Docker Engine with the Compose plugin (docker compose, not the older docker-compose command)
- A copy of this repository, because compose files and data folders live here
- Extra CPU and RAM for Wine-based games (Ground Branch, Space Engineers, Icarus, Sons Of The Forest, Sniper Elite 4). Those run a Windows build under Wine and are heavier than native Linux servers

## 1. Pick a server

Every runnable server is listed in [All servers](/reference/servers/). Each game also has its own guide under **Servers** with ports, folders, and settings for that title.

## 2. Set IMAGE_OWNER

Compose files pull images from ghcr.io using your GitHub owner and repo name (lowercase). Run this once per terminal session:

```bash
export IMAGE_OWNER="$(./ci/repo-meta.sh | sed -n 's/^IMAGE_OWNER=//p')"
```

If you only build and run locally and never pull from GitHub Container Registry, any value works. Compose will use a local image when one is already on disk.

## 3. Run with Compose

```bash
docker compose -f minecraft/fabric/docker-compose.yml up
```

Swap the path for any other server, for example valheim/vanilla/docker-compose.yml or core-keeper/docker-compose.yml.

To build the image on your machine instead of pulling:

```bash
docker compose -f minecraft/fabric/docker-compose.yml up --build
```

Every compose file names a published image and also includes a build section for local builds. With pull_policy set to missing, Compose uses an image already on disk before it tries to pull. Add --pull always to force a fresh pull.

## 4. Run with docker run instead

Compose is easier because it keeps ports, folders, health checks, and memory limits in one place. A plain docker run works too. Each server guide has a copy-paste example. The general shape:

```bash
docker run -d --name <container> --restart unless-stopped --init \
  -p <port>:<port>/<proto> \
  -v "$PWD/<server>/data:/<data-path>" \
  -e <ENV_VAR>=<value> \
  {{IMAGE_PREFIX}}/<image>:latest
```

Image prefix: {{IMAGE_PREFIX}}

For example, Minecraft Fabric with no mods needs only the EULA flag:

```bash
docker run -d --name fabric --restart unless-stopped --init \
  -p 25565:25565/tcp \
  -v "$PWD/minecraft/fabric/data:/data" \
  -e EULA=true \
  {{IMAGE_PREFIX}}/minecraft-fabric:latest
```

Match -p host:container/proto to the ports on the server's guide. Use both TCP and UDP where the game needs both. Keep --init when you switch to docker run. It cleans up child processes from wrapper scripts.

## Persistent data

Every server stores saves and config in a folder on your machine, usually ./data next to the compose file. A few games split state across more than one folder (Arma 3 uses server, configs, and profiles). Stop the container before editing config files by hand, then start it again.

## Settings you will see often

These show up on many servers, but not all. Always check the game's own guide for the full list.

| Setting | Where | What it does |
| --- | --- | --- |
| STEAM_USERNAME, STEAM_PASSWORD, STEAM_GUARD_CODE | Steam-downloaded games | Steam login for the download step. Defaults to anonymous. |
| EULA | Minecraft only | Must be true or the server refuses to start |
| SERVER_PASS and similar | Most Steam and Wine games | Join or admin password (name varies by game) |
| *_FORCE_UPDATE, *_FORCE_DOWNLOAD, *_FORCE_INSTALL | Games with an update flag in the catalog | Forces a reinstall on next start. Used by ./tools/gs update |
| PUID, PGID | Minecraft only | Match file ownership to a host user and group |

:::note[Steam login]
Anonymous Steam downloads work for most dedicated server tools. A few games (Arma 3 is the common case) need an account that owns the server files. Set STEAM_USERNAME and STEAM_PASSWORD, and STEAM_GUARD_CODE if Steam Guard asks for a code. Anonymous logins can also fail to list a server publicly for some titles. In that case use real credentials.
:::

## Networking: getting friends onto your server

Docker only opens ports on the machine it runs on. Your router still has to let traffic in from the internet. Two ways to do that:

- **Port forwarding** (best for a server you keep running): a rule on your router that sends traffic on a given port to your server's local IP. Reliable, and what most guides assume.
- **UPnP**: your router opens the port when asked. Convenient, but not every router supports it well, and it is a weaker security boundary.

Give the machine running Docker a fixed local IP (static IP or a DHCP reservation in your router). Otherwise the forwarding rule can point at the wrong device after a reboot.

:::note[If it is not working]
- **Same-network testing can lie to you.** Many home routers do not support NAT loopback, so visiting your own public IP from inside your network can fail even when it works for a friend elsewhere. Test from outside your network (mobile data works well) before assuming the setup is broken.
- **CGNAT blocks port forwarding entirely.** If your ISP puts you behind Carrier-Grade NAT, forwarded ports never reach your router. Compare the WAN IP in your router admin page to your public IP from a site like whatismyip.com. If they differ, you are likely behind CGNAT and need a different approach (a VPS, a tunnel, or asking your ISP for a public IP).
- **Check both TCP and UDP.** Most game servers need both. Forwarding one but not the other is a common miss. Check the port table on the server's guide.
- **A host firewall can still block a forwarded port.** ufw, firewalld, and cloud provider security groups sit between the internet and the container even after the router is set up.
:::

## Backup, restore, update, health checks

Covered on the [Ops](./ops/) page: ./tools/gs backup, restore, update, and how health checks show up in docker inspect.

## Next steps

- [All servers](/reference/servers/) for the full compose path and image table
- [Images](/reference/images/) for published image names
- [CI](/reference/ci/) for how images build and publish
