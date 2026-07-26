# dockerized-game-servers

Dockerized dedicated game servers with small images and compose files.

Images publish to GHCR under `ghcr.io/sudo-ivan/dockerized-game-servers/`.

## Servers

| Server | Compose | Image |
| --- | --- | --- |
| Minecraft Fabric | `minecraft/fabric` | `minecraft-fabric` |
| Minecraft Vanilla | `minecraft/vanilla` | `minecraft-vanilla` |
| Minecraft Forge | `minecraft/forge` | `minecraft-forge` |
| Valheim | `valheim/vanilla` | `valheim` |
| Valheim Plus | `valheim/plus` | `valheim-plus` |
| Ground Branch | `ground-branch` | `ground-branch` |
| Core Keeper | `core-keeper` | `core-keeper` |
| Arma 3 | `arma/arma-3` | `arma-3` |
| Hytale | `hytale` | external (`deinfreu/hytale-server`) |

Shared bases:

- `minecraft-base` Temurin JRE on Alpine
- `steam-base` SteamCMD on Arch Linux

## Quick start

### Compose

```bash
docker compose -f minecraft/fabric/docker-compose.yml up
```

Build locally:

```bash
docker compose -f minecraft/fabric/docker-compose.yml up --build
```

Compose files set `image:` to GHCR and keep `build:` for local rebuilds. `pull_policy: missing` uses a local image when present, otherwise pulls.

### Docker run

Image prefix: `ghcr.io/sudo-ivan/dockerized-game-servers`

Minecraft Fabric:

```bash
docker run -d --name fabric --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/fabric/data:/data" \
  -e EULA=true \
  ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-fabric:latest
```

Minecraft Vanilla:

```bash
docker run -d --name vanilla --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/vanilla/data:/data" \
  -e EULA=true \
  ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-vanilla:latest
```

Minecraft Forge:

```bash
docker run -d --name forge --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/forge/data:/data" \
  -e EULA=true \
  ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-forge:latest
```

Valheim:

```bash
docker run -d --name valheim --restart unless-stopped --init \
  -p 2456-2458:2456-2458/udp \
  -v "$PWD/valheim/vanilla/data:/opt/valheim" \
  -e SERVER_PASS=changeme \
  ghcr.io/sudo-ivan/dockerized-game-servers/valheim:latest
```

Valheim Plus:

```bash
docker run -d --name valheim-plus --restart unless-stopped --init \
  -p 2456-2458:2456-2458/udp \
  -v "$PWD/valheim/plus/data:/opt/valheim" \
  -e SERVER_PASS=changeme \
  ghcr.io/sudo-ivan/dockerized-game-servers/valheim-plus:latest
```

Ground Branch:

```bash
docker run -d --name ground-branch --restart unless-stopped --init \
  -p 7777:7777/udp -p 27015:27015/udp \
  -v "$PWD/ground-branch/data:/opt/groundbranch" \
  ghcr.io/sudo-ivan/dockerized-game-servers/ground-branch:latest
```

Core Keeper (SDR, no ports):

```bash
docker run -d --name core-keeper --restart unless-stopped --init \
  -v "$PWD/core-keeper/data:/opt/corekeeper" \
  ghcr.io/sudo-ivan/dockerized-game-servers/core-keeper:latest
```

Arma 3:

```bash
docker run -d --name arma3 --restart unless-stopped \
  -p 2302-2306:2302-2306/udp \
  -v "$PWD/arma/arma-3/server:/home/arma3/server" \
  -v "$PWD/arma/arma-3/configs:/home/arma3/configs" \
  -v "$PWD/arma/arma-3/profiles:/home/arma3/profiles" \
  -v "$PWD/arma/arma-3/cache:/home/arma3/cache" \
  -e STEAM_USERNAME=youruser \
  -e STEAM_PASSWORD=yourpass \
  ghcr.io/sudo-ivan/dockerized-game-servers/arma-3:latest
```

Hytale (external image):

```bash
docker run -d --name hytale-server --restart unless-stopped \
  -p 5520:5520/udp \
  -v "$PWD/hytale/data:/home/container" \
  -v /etc/machine-id:/etc/machine-id:ro \
  -e SERVER_IP=0.0.0.0 \
  -e SERVER_PORT=5520 \
  deinfreu/hytale-server:latest
```

### Minecraft

Accept the EULA with `EULA=true`. World and config live in each server's `./data` volume.

### Steam games

Many titles allow anonymous SteamCMD. Arma 3 usually needs a Steam account that owns the server files. Set Valheim `SERVER_PASS` via `-e` or a `.env` file next to compose.

### Ground Branch

Server config appears under `ground-branch/data/GroundBranch/ServerConfig/` after first start. Optional map/mission via `GB_MAP` and `GB_MISSION`.

### Core Keeper

Defaults to Steam Datagram Relay (SDR). No published ports are required. After start, read the game ID:

```bash
docker exec -it core-keeper cat /opt/corekeeper/server/GameID.txt
```

For direct connect, set `SERVER_PORT` and publish that UDP port. World data lives under `core-keeper/data/`.

## Images

| Name | Notes |
| --- | --- |
| `minecraft-base` | Shared Minecraft runtime |
| `steam-base` | Shared SteamCMD runtime (Arch) |
| `minecraft-fabric` | Fabric |
| `minecraft-vanilla` | Vanilla |
| `minecraft-forge` | Forge |
| `valheim` | Valheim dedicated |
| `valheim-plus` | Valheim Plus |
| `ground-branch` | Ground Branch (Wine) |
| `core-keeper` | Core Keeper dedicated |
| `arma-3` | Arma 3 dedicated |

```bash
docker pull ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-fabric:latest
```

## CI

Workflows are manual (`workflow_dispatch`):

- `ci` runs `ci/ci-check.sh`
- `build` builds base images concurrently, then game images in a matrix, and pushes to GHCR

Base images are always pushed so matrix jobs can reuse them. Game image push is controlled by the workflow `push` input.

After the first publish, set GHCR package visibility to public if the repo is public.

## Layout

```text
bases/           shared Docker bases
ci/              POSIX CI scripts
minecraft/       Fabric, Vanilla, Forge
valheim/         Vanilla and Plus
ground-branch/   Ground Branch
core-keeper/     Core Keeper
arma/arma-3/     Arma 3
hytale/          external image compose
```

## License

0BSD
