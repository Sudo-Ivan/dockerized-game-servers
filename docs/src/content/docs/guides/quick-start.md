---
title: Quick start
description: Run a game server with Docker Compose or docker run.
---

## Prerequisites

- Docker Engine with the Compose plugin (`docker compose`, not the old `docker-compose`)
- A clone of this repository, since compose files and per-server `./data` folders live in it
- For Wine-based images (Ground Branch, Space Engineers, Icarus, Sons Of The Forest, Sniper Elite 4), enough CPU and RAM headroom, these run a Windows binary under Wine and are heavier than native Linux builds

## 1. Pick a server

Every runnable server has a compose path and image name in [All servers](/reference/servers/). Each also has its own guide under **Servers** with the exact ports, volumes, and environment variables for that game.

## 2. Set IMAGE_OWNER

Compose files reference `ghcr.io/${IMAGE_OWNER}/<image>:latest`. `IMAGE_OWNER` is your GitHub `owner/repo`, lowercased, and it comes from `ci/repo-meta.sh` (it reads `GITHUB_REPOSITORY` if set, otherwise your git remote):

```bash
export IMAGE_OWNER="$(./ci/repo-meta.sh | sed -n 's/^IMAGE_OWNER=//p')"
```

Set this once per shell session before running compose commands below. If you only build and run locally and never pull from GHCR, any value works since `pull_policy: missing` (see below) will use the local image.

## 3. Run with Compose

```bash
docker compose -f minecraft/fabric/docker-compose.yml up
```

Swap the path for any other server, for example `valheim/vanilla/docker-compose.yml` or `core-keeper/docker-compose.yml`.

To build the image locally instead of pulling from GHCR:

```bash
docker compose -f minecraft/fabric/docker-compose.yml up --build
```

Every compose file sets `image` to the GHCR tag and also keeps a `build` section pointing at the local `Dockerfile`. With `pull_policy: missing`, compose uses an image already on disk (including one you built locally) before it tries to pull. To force a fresh pull, add `--pull always`.

## 4. Run with docker run instead

Compose is recommended since it keeps ports, volumes, healthchecks, and resource limits together, but a plain `docker run` works too. Each server guide has a ready-to-copy example. The general shape:

```bash
docker run -d --name <container> --restart unless-stopped --init \
  -p <port>:<port>/<proto> \
  -v "$PWD/<server>/data:/<data-path>" \
  -e <ENV_VAR>=<value> \
  {{IMAGE_PREFIX}}/<image>:latest
```

Image prefix: `{{IMAGE_PREFIX}}`

For example, Minecraft Fabric with no mods needs only the EULA flag:

```bash
docker run -d --name fabric --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/fabric/data:/data" \
  -e EULA=true \
  {{IMAGE_PREFIX}}/minecraft-fabric:latest
```

`-p host:container/proto` must match the ports listed on the server's guide, both TCP and UDP where the game needs both. `--init` reaps zombie processes from wrapper scripts and is set in every compose file too, keep it when you switch to `docker run`.

## Persistent data

Every server mounts a host folder to a data path inside the container, most use `./data` next to the compose file (check the compose file's `volumes:` section if you're unsure since a few games split state across more than one path, for example Arma 3 uses `server`, `configs`, and `profiles`). Stop the container before editing config files by hand, then start it again.

## Environment variables you will see repeatedly

These patterns show up across many servers, but not all, always check the server's own guide for the full list:

| Variable | Where it applies | Purpose |
| --- | --- | --- |
| `STEAM_USERNAME`, `STEAM_PASSWORD`, `STEAM_GUARD_CODE` | Any SteamCMD-based image | Steam login for the download step. Defaults to anonymous. |
| `EULA` | Minecraft only | Must be `true` or the server refuses to start |
| `SERVER_PASS` / similar join password variables | Most Steam and Wine games | Join or admin password, game-specific name |
| `*_FORCE_UPDATE`, `*_FORCE_DOWNLOAD`, `*_FORCE_INSTALL` | Games with an update env in `ci/server-catalog.sh` | Forces a reinstall or redownload on next start, used by `./tools/gs update` |
| `PUID`, `PGID` | Minecraft only | Match container file ownership to a host user/group |

:::note[Steam login]
Anonymous SteamCMD downloads most dedicated server tools without a Steam account. A few games (Arma 3 is the common case) need an account that owns the server files. Set `STEAM_USERNAME` and `STEAM_PASSWORD`, and `STEAM_GUARD_CODE` if Steam Guard prompts for a code. Anonymous logins can also fail to list a server publicly for some titles, in which case set real credentials.
:::

## Networking: getting friends onto your server

Docker only publishes ports on the machine it runs on, your router still has to let the traffic in from the internet. Two ways to do that:

- **Port forwarding** (recommended for a server you keep around): a rule on your router that always sends traffic on a given port to your server's local IP. Reliable, and it is what most guides assume.
- **UPnP**: your router opens the port automatically when asked. Convenient, but not every router supports it well, and it is a weaker security boundary since any device on your network could ask for a port to be opened.

Whichever you use, give the machine running the containers a fixed local IP (a static IP or a DHCP reservation in your router). Otherwise the forwarding rule can silently point at the wrong device after a reboot.

:::note[If it "isn't working"]
- **Same-network testing can lie to you.** Many home routers do not support NAT loopback (hairpin NAT), so visiting your own public IP from inside your own network can fail even though it works fine for a friend elsewhere. Test from outside your network, mobile data works well, before assuming the setup is broken.
- **CGNAT blocks port forwarding entirely.** If your ISP puts you behind Carrier-Grade NAT, forwarded ports never reach your router no matter how you configure it. Compare the WAN IP shown in your router's admin page to your public IP from a site like whatismyip.com, if they differ, you are likely behind CGNAT and need a different approach (a VPS, a tunnel, or asking your ISP for a public IP).
- **Check both TCP and UDP.** Most game servers need both, and forwarding one but not the other is a common miss, check the port table on the server's guide.
- **A host firewall can still block a correctly forwarded port.** `ufw`/`firewalld`/cloud provider security groups sit between the internet and the container even after the router is configured correctly.
:::

## Ops: backup, restore, update, healthchecks

Covered on the [Ops](./ops/) page: `./tools/gs backup`, `./tools/gs restore`, `./tools/gs update`, and how healthchecks map to `docker inspect`.

## Next steps

- [All servers](/reference/servers/) for the full compose path and image table
- [Images](/reference/images/) for published GHCR image names
- [CI](/reference/ci/) for how images build and publish
