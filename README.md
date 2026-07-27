# dockerized-game-servers

Dockerized dedicated game servers with small images and compose files.

Docs publish to GitHub Pages for this repository (see Actions / Pages).

Images publish to GHCR under `ghcr.io/$IMAGE_OWNER/` where IMAGE_OWNER is `owner/repo` (from git remote or GITHUB_REPOSITORY). Compose reads IMAGE_OWNER from the environment or a local `.env` file.

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
| Factorio | `factorio` | `factorio` |
| OpenMoHAA | `openmohaa` | `openmohaa` |
| Arma 3 | `arma/arma-3` | `arma-3` |
| Hytale | `hytale` | external (`deinfreu/hytale-server`) |

Shared bases:

- `minecraft-base` Temurin JRE on Alpine
- `steam-base` SteamCMD on Arch Linux with the [XLibre](https://github.com/x11libre/xserver) Arch package repo ([xlibre-arch](https://github.com/xlibre-arch/xlibre-arch)) for X11/Xvfb needs

## Quick start

### Compose

Set IMAGE_OWNER to your GitHub owner/repo (lowercase), then start:

```bash
export IMAGE_OWNER="$(./ci/repo-meta.sh | sed -n 's/^IMAGE_OWNER=//p')"
docker compose -f minecraft/fabric/docker-compose.yml up
```

Build locally:

```bash
docker compose -f minecraft/fabric/docker-compose.yml up --build
```

Compose files set image to GHCR via IMAGE_OWNER and keep build for local rebuilds. pull_policy missing uses a local image when present, otherwise pulls.

### Docker run

Image prefix: ghcr.io/$IMAGE_OWNER

Minecraft Fabric:

```bash
docker run -d --name fabric --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/fabric/data:/data" \
  -e EULA=true \
  ghcr.io/$IMAGE_OWNER/minecraft-fabric:latest
```

Minecraft Vanilla:

```bash
docker run -d --name vanilla --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/vanilla/data:/data" \
  -e EULA=true \
  ghcr.io/$IMAGE_OWNER/minecraft-vanilla:latest
```

Minecraft Forge:

```bash
docker run -d --name forge --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/forge/data:/data" \
  -e EULA=true \
  ghcr.io/$IMAGE_OWNER/minecraft-forge:latest
```

Valheim:

```bash
docker run -d --name valheim --restart unless-stopped --init \
  -p 2456-2458:2456-2458/udp \
  -v "$PWD/valheim/vanilla/data:/opt/valheim" \
  -e SERVER_PASS=changeme \
  ghcr.io/$IMAGE_OWNER/valheim:latest
```

Valheim Plus:

```bash
docker run -d --name valheim-plus --restart unless-stopped --init \
  -p 2456-2458:2456-2458/udp \
  -v "$PWD/valheim/plus/data:/opt/valheim" \
  -e SERVER_PASS=changeme \
  ghcr.io/$IMAGE_OWNER/valheim-plus:latest
```

Ground Branch:

```bash
docker run -d --name ground-branch --restart unless-stopped --init \
  -p 7777:7777/udp -p 27015:27015/udp \
  -v "$PWD/ground-branch/data:/opt/groundbranch" \
  ghcr.io/$IMAGE_OWNER/ground-branch:latest
```

Core Keeper (SDR, no ports):

```bash
docker run -d --name core-keeper --restart unless-stopped --init \
  -v "$PWD/core-keeper/data:/opt/corekeeper" \
  ghcr.io/$IMAGE_OWNER/core-keeper:latest
```

Factorio:

```bash
docker run -d --name factorio --restart unless-stopped --init \
  -p 34197:34197/udp -p 27015:27015/tcp \
  -v "$PWD/factorio/data:/opt/factorio" \
  -e RCON_PASSWORD=changeme \
  ghcr.io/$IMAGE_OWNER/factorio:latest
```

OpenMoHAA (copy your owned MOHAA `main` / `mainta` / `maintt` PK3s into `openmohaa/data` first):

```bash
docker run -d --name openmohaa --restart unless-stopped --init \
  -p 12203:12203/udp -p 12300:12300/udp \
  -v "$PWD/openmohaa/data:/usr/local/share/mohaa" \
  ghcr.io/$IMAGE_OWNER/openmohaa:latest
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
  ghcr.io/$IMAGE_OWNER/arma-3:latest
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

Defaults to Steam Datagram Relay (SDR). No published ports are required. When ready, `docker logs` prints the Game ID and `Status: server ready and ready for players!`. Fallback:

```bash
docker exec -it core-keeper cat /opt/corekeeper/server/GameID.txt
```

For direct connect, set `SERVER_PORT` and publish that UDP port. World data lives under `core-keeper/data/`. Uses XLibre `xlibre-xserver-xvfb` (not X.Org) for the virtual display.

### Ops

Backup, restore, update, and healthchecks: `./tools/gs` (see docs guides/ops). Examples:

```bash
export IMAGE_OWNER="$(./ci/repo-meta.sh | sed -n 's/^IMAGE_OWNER=//p')"
./tools/gs list
./tools/gs backup core-keeper
./tools/gs update factorio --backup
```

### Factorio

Downloads the official headless package from factorio.com (`FACTORIO_VERSION`, default `stable`). Creates `saves/<SAVE_NAME>.zip` on first start and writes `config/server-settings.json` if missing. Game traffic is UDP `34197`. Set `RCON_PASSWORD` to enable RCON on TCP `27015`. Edit settings under `factorio/data/config/` after the first run.

### OpenMoHAA

Uses [OpenMoHAA](https://github.com/openmoh/openmohaa) release binaries. **You must copy licensed Allied Assault game data** (`main`, and optionally `mainta` / `maintt` PK3s) into `openmohaa/data/` before the server can run. Defaults: UDP `12203` (game) and UDP `12300` (GameSpy). Server config: `openmohaa/data/home/main/settings/server.cfg` (a default is created on first start). See [OpenMoHAA docs](https://docs.openmohaa.org/).

## Images

| Name | Notes |
| --- | --- |
| `minecraft-base` | Shared Minecraft runtime |
| `steam-base` | Shared SteamCMD runtime (Arch + XLibre repo) |
| `minecraft-fabric` | Fabric |
| `minecraft-vanilla` | Vanilla |
| `minecraft-forge` | Forge |
| `valheim` | Valheim dedicated |
| `valheim-plus` | Valheim Plus |
| `ground-branch` | Ground Branch (Wine) |
| `core-keeper` | Core Keeper dedicated |
| `factorio` | Factorio dedicated |
| `openmohaa` | OpenMoHAA (BYO MOHAA assets) |
| `arma-3` | Arma 3 dedicated |

```bash
docker pull ghcr.io/$IMAGE_OWNER/minecraft-fabric:latest
```

## CI

- `ci` runs on push, pull request, and manually: `ci/ci-check.sh` (catalog-driven compose checks, ShellCheck, health/tools tests) plus Trivy Dockerfile config scans (MEDIUM+HIGH+CRITICAL)
- `build` runs weekly (Sunday 06:00 UTC), on Dockerfile/base/`ci` path changes to `master`/`main`, and manually: builds/pushes GHCR images then Trivy-scans them (CRITICAL fail)
- `build-minecraft` is manual only: pick Fabric/Vanilla/Forge + a Minecraft version. Java is resolved from Mojang's `javaVersion`, Temurin Alpine JRE is pinned from Adoptium, Fabric loader/installer and Forge promos auto-fill when left blank. Publishes `minecraft-base:javaN` and `minecraft-<flavor>:<tag>` (tag defaults to the MC version, or `mc-forge` for Forge)

Example tags after a versioned Fabric build for `26.2`:

```text
ghcr.io/$IMAGE_OWNER/minecraft-base:java25
ghcr.io/$IMAGE_OWNER/minecraft-fabric:26.2
```

Local resolve preview:

```bash
./ci/resolve-minecraft-build.sh --flavor fabric --minecraft-version 26.2
./ci/resolve-minecraft-build.sh --flavor vanilla --minecraft-version 1.20.4
./ci/resolve-minecraft-build.sh --flavor forge --minecraft-version 1.21.8 --forge-channel latest
```

Trivy is installed from a pinned GitHub release tarball with SHA-256 verification (`ci/install-trivy.sh`). This repo does not use `aquasecurity/trivy-action` after the March 2026 supply-chain compromise. Shared scan settings live in `trivy.yaml`.

Base images are always pushed so matrix jobs can reuse them. Manual builds can set the `push` input for game images.

After the first publish, set GHCR package visibility to public if the repo is public.

## Layout

```text
bases/           shared Docker bases
ci/              POSIX CI scripts (repo-meta, server-catalog, checks)
tools/           host ops CLI (gs)
docs/            Starlight site (GitHub Pages)
minecraft/       Fabric, Vanilla, Forge
valheim/         Vanilla and Plus
ground-branch/   Ground Branch
core-keeper/     Core Keeper
factorio/         Factorio
openmohaa/       OpenMoHAA
arma/arma-3/     Arma 3
hytale/          external image compose
```

## License

0BSD
