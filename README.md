# dockerized-game-servers

Dockerized dedicated game servers with small images and compose files.

Docs publish to GitHub Pages for this repository (see Actions / Pages).

Images publish to GHCR as `ghcr.io/sudo-ivan/dockerized-game-servers/<image>:<tag>`. Compose files use the `IMAGE_OWNER` variable (set it in `.env` or the environment). Forks that publish their own images can set `IMAGE_OWNER` to their `owner/repo` (lowercase).

## Servers

| Server | Compose | Image |
| --- | --- | --- |
| Minecraft Fabric | `minecraft/fabric` | `minecraft-fabric` |
| Minecraft Vanilla | `minecraft/vanilla` | `minecraft-vanilla` |
| Minecraft Forge | `minecraft/forge` | `minecraft-forge` |
| Valheim | `valheim/vanilla` | `valheim` |
| Valheim Plus | `valheim/plus` | `valheim-plus` |
| Ground Branch | `ground-branch` | `ground-branch` |
| Space Engineers | `space-engineers` | `space-engineers` |
| Core Keeper | `core-keeper` | `core-keeper` |
| Factorio | `factorio` | `factorio` |
| 7 Days to Die | `7-days-to-die` | `7-days-to-die` |
| Project Zomboid | `project-zomboid` | `project-zomboid` |
| Terraria | `terraria` | `terraria` |
| Left 4 Dead 2 | `l4d2` | `l4d2` |
| Insurgency (Source) | `insurgency-source` | `insurgency-source` |
| Insurgency: Sandstorm | `insurgency-sandstorm` | `insurgency-sandstorm` |
| Palworld | `palworld` | `palworld` |
| Starbound | `starbound` | `starbound` |
| OpenMoHAA | `openmohaa` | `openmohaa` |
| Arma 3 | `arma/arma-3` | `arma-3` |
| Hytale | `hytale` | external (`deinfreu/hytale-server`) |
| Stardew Valley | `stardew-valley` | external ([JunimoServer](https://github.com/stardew-valley-dedicated-server/server) `sdvd/server`) |

Shared bases:

- `minecraft-base` Temurin JRE on Alpine
- `steam-base` SteamCMD on Arch Linux with the [XLibre](https://github.com/x11libre/xserver) Arch package repo ([xlibre-arch](https://github.com/xlibre-arch/xlibre-arch)) for X11/Xvfb needs
- `runtime-base` Debian slim glibc runtime for non-Steam non-Java servers (Factorio, OpenMoHAA)

## Quick start

### Compose

Published images use `IMAGE_OWNER=sudo-ivan/dockerized-game-servers`. For a fork with its own GHCR packages, set `IMAGE_OWNER` in `.env` (see `.env.example`).

```bash
docker compose -f minecraft/fabric/docker-compose.yml up
```

To pin the upstream registry explicitly:

```bash
export IMAGE_OWNER=sudo-ivan/dockerized-game-servers
docker compose -f minecraft/fabric/docker-compose.yml up
```

Build locally:

```bash
docker compose -f minecraft/fabric/docker-compose.yml up --build
```

Compose files reference `ghcr.io/${IMAGE_OWNER}/...` and keep build contexts for local rebuilds. `pull_policy: missing` uses a local image when present, otherwise pulls.

### Docker run

Image prefix: `ghcr.io/sudo-ivan/dockerized-game-servers` (replace `sudo-ivan/dockerized-game-servers` in the examples if you use another registry namespace).

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

Space Engineers:

```bash
docker run -d --name space-engineers --restart unless-stopped --init \
  -p 27016:27016/udp \
  -v "$PWD/space-engineers/data/dedicated:/opt/spaceengineers/dedicated" \
  -v "$PWD/space-engineers/data/instances:/opt/spaceengineers/instances" \
  -v "$PWD/space-engineers/data/plugins:/opt/spaceengineers/plugins" \
  -e SE_INSTANCE_NAME=Default \
  ghcr.io/sudo-ivan/dockerized-game-servers/space-engineers:latest
```

Core Keeper (SDR, no ports):

```bash
docker run -d --name core-keeper --restart unless-stopped --init \
  -v "$PWD/core-keeper/data:/opt/corekeeper" \
  ghcr.io/sudo-ivan/dockerized-game-servers/core-keeper:latest
```

Factorio:

```bash
docker run -d --name factorio --restart unless-stopped --init \
  -p 34197:34197/udp -p 27015:27015/tcp \
  -v "$PWD/factorio/data:/opt/factorio" \
  -e RCON_PASSWORD=changeme \
  ghcr.io/sudo-ivan/dockerized-game-servers/factorio:latest
```

7 Days to Die:

```bash
docker run -d --name 7-days-to-die --restart unless-stopped --init \
  -p 26900:26900/tcp -p 26900:26900/udp \
  -p 26901-26903:26901-26903/udp \
  -v "$PWD/7-days-to-die/data:/opt/7dtd" \
  ghcr.io/sudo-ivan/dockerized-game-servers/7-days-to-die:latest
```

Project Zomboid:

```bash
docker run -d --name project-zomboid --restart unless-stopped --init \
  -p 16261:16261/udp -p 16262:16262/udp \
  -v "$PWD/project-zomboid/data:/opt/zomboid" \
  -e PZ_ADMIN_PASSWORD=changeme \
  ghcr.io/sudo-ivan/dockerized-game-servers/project-zomboid:latest
```

Terraria:

```bash
docker run -d --name terraria --restart unless-stopped --init \
  -p 7777:7777/tcp \
  -v "$PWD/terraria/data:/opt/terraria" \
  ghcr.io/sudo-ivan/dockerized-game-servers/terraria:latest
```

Left 4 Dead 2:

```bash
docker run -d --name l4d2 --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27005:27005/udp \
  -v "$PWD/l4d2/data:/opt/l4d2" \
  ghcr.io/sudo-ivan/dockerized-game-servers/l4d2:latest
```

Insurgency (Source):

```bash
docker run -d --name insurgency-source --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27016:27016/udp \
  -v "$PWD/insurgency-source/data:/opt/insurgency-source" \
  ghcr.io/sudo-ivan/dockerized-game-servers/insurgency-source:latest
```

Insurgency: Sandstorm:

```bash
docker run -d --name insurgency-sandstorm --restart unless-stopped --init \
  -p 27102:27102/udp -p 27131:27131/udp \
  -v "$PWD/insurgency-sandstorm/data:/opt/insurgency-sandstorm" \
  ghcr.io/sudo-ivan/dockerized-game-servers/insurgency-sandstorm:latest
```

Palworld:

```bash
docker run -d --name palworld --restart unless-stopped --init \
  -p 8211:8211/udp \
  -v "$PWD/palworld/data:/opt/palworld" \
  ghcr.io/sudo-ivan/dockerized-game-servers/palworld:latest
```

Starbound:

```bash
docker run -d --name starbound --restart unless-stopped --init \
  -p 21025:21025/tcp \
  -v "$PWD/starbound/data:/opt/starbound" \
  ghcr.io/sudo-ivan/dockerized-game-servers/starbound:latest
```

OpenMoHAA (copy your owned MOHAA `main` / `mainta` / `maintt` PK3s into `openmohaa/data` first):

```bash
docker run -d --name openmohaa --restart unless-stopped --init \
  -p 12203:12203/udp -p 12300:12300/udp \
  -v "$PWD/openmohaa/data:/usr/local/share/mohaa" \
  ghcr.io/sudo-ivan/dockerized-game-servers/openmohaa:latest
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

Stardew Valley (JunimoServer, external images). Copy `stardew-valley/.env.example` to `.env`, set Steam credentials and `SDVD_VNC_PASSWORD`, then run Steam setup once before `up`:

```bash
cd stardew-valley
cp .env.example .env
docker compose run --rm -it steam-auth setup
docker compose up -d
```

UDP **24642** (game), UDP **27015** (query), TCP **5800** (VNC), TCP **8080** (API). Saves and game files under `stardew-valley/data/`. See [Stardew Valley docs](https://sudo-ivan.github.io/dockerized-game-servers/servers/stardew-valley/) and [JunimoServer](https://github.com/stardew-valley-dedicated-server/server).

### Minecraft

Accept the EULA with `EULA=true`. World and config live in each server's `./data` volume.

### Steam games

Many titles allow anonymous SteamCMD. Arma 3 usually needs a Steam account that owns the server files. Set Valheim `SERVER_PASS` via `-e` or a `.env` file next to compose.

### Ground Branch

Server config appears under `ground-branch/data/GroundBranch/ServerConfig/` after first start. Optional map/mission via `GB_MAP` and `GB_MISSION`.

### Space Engineers

Steam App 298740 (Windows dedicated server via Wine). Persist `space-engineers/data/dedicated`, `instances`, and `plugins` (Wine/dotnet is baked into the image). Default instance `Default`, config `space-engineers/data/instances/Default/SpaceEngineers-Dedicated.cfg`. First start downloads server files into `data/dedicated` (allow several minutes). UDP game port 27016. Set `SE_PUBLIC_IP` when the container cannot infer a reachable address for the dedicated config.

### Core Keeper

Defaults to Steam Datagram Relay (SDR). No published ports are required. When ready, `docker logs` prints the Game ID and `Status: server is up and ready for players!`. Fallback:

```bash
docker exec -it core-keeper cat /opt/corekeeper/server/GameID.txt
```

For direct connect, set `SERVER_PORT` and publish that UDP port. World data lives under `core-keeper/data/`. Uses XLibre `xlibre-xserver-xvfb` (not X.Org) for the virtual display.

### Ops

Backup, restore, update, and healthchecks: `./tools/gs` (see docs guides/ops). Examples:

```bash
./tools/gs list
./tools/gs backup core-keeper
./tools/gs update factorio --backup
```

`./tools/gs` resolves `IMAGE_OWNER` from your git remote via `ci/repo-meta.sh`. Forks can `export IMAGE_OWNER=your-user/your-fork` when using custom images.

### Factorio

Downloads the official headless package from factorio.com (`FACTORIO_VERSION`, default `stable`). Creates `saves/<SAVE_NAME>.zip` on first start and writes `config/server-settings.json` if missing. Game traffic is UDP `34197`. Set `RCON_PASSWORD` to enable RCON on TCP `27015`. Edit settings under `factorio/data/config/` after the first run.

### 7 Days to Die

Steam App 294420 via anonymous login. Persist `/opt/7dtd` (world, `Saves/`, config). Default `serverconfig.xml` is created on first start if missing. Game ports TCP/UDP 26900 and UDP 26901-26903.

### Project Zomboid

Steam App 380870. Server binaries under `project-zomboid/data/server`. Saves and ini files under `project-zomboid/data/home/Zomboid/`. Set `PZ_ADMIN_PASSWORD` before the first launch.

### Terraria

Steam App 105600. Official dedicated server binary and `serverconfig.txt` under `terraria/data`. Default TCP port 7777.

### Left 4 Dead 2

Steam App 222860. Source dedicated server via `srcds_run`. Default map `c1m1_hotel`, port 27015 TCP/UDP. Set `L4D2_STARTMAP`, `L4D2_MAXPLAYERS`, and `L4D2_EXTRA_ARGS` as needed.

### Insurgency (Source)

Steam App 237410. Source dedicated server via `srcds_run` (`-game insurgency`). Default map `ministry`, ports 27015 and 27016. Config under `insurgency-source/data/insurgency/cfg/` after first run.

### Insurgency: Sandstorm

Steam App 581330. Linux dedicated binary under `insurgency-sandstorm/data`. Default UDP 27102 (game) and 27131 (query). Set `INS_SANDSTORM_MAP`, `INS_SANDSTORM_SCENARIO`, `INS_SANDSTORM_GSLT`, and `INS_SANDSTORM_GAMESTATS_TOKEN` for listing and GameStats. Use `INS_SANDSTORM_EXTRA_ARGS` for mutators, `-mods`, and `ModDownloadTravelTo`. Mod config files live under `insurgency-sandstorm/data/Insurgency/Config/Server/`. See the [Insurgency Sandstorm](https://sudo-ivan.github.io/dockerized-game-servers/servers/insurgency-sandstorm/) docs page for a full modding guide. Allocate at least 8 GB RAM.

### Palworld

Steam App 2394010. Saves and `PalWorldSettings.ini` under `palworld/data/Pal/Saved/` after first run. Default UDP 8211. Allocate at least 8 GB RAM for the container.

### Starbound

Steam App 211820. Writes `starbound_server.config` on first start if missing. Default TCP 21025.

### Stardew Valley

Uses [JunimoServer](https://github.com/stardew-valley-dedicated-server/server) (`sdvd/server` on Docker Hub), not a first-party image from this repo. Requires Steam credentials that own Stardew Valley. Two-service compose: `server` plus `steam-auth`. First-time `docker compose run --rm -it steam-auth setup` for Steam Guard and game download. Farm saves under `stardew-valley/data/saves`, settings in `data/settings/server-settings.json`. Optional Discord bot: `docker compose --profile discord up -d`.

### OpenMoHAA

Uses [OpenMoHAA](https://github.com/openmoh/openmohaa) release binaries. **You must copy licensed Allied Assault game data** (`main`, and optionally `mainta` / `maintt` PK3s) into `openmohaa/data/` before the server can run. Defaults: UDP `12203` (game) and UDP `12300` (GameSpy). Server config: `openmohaa/data/home/main/settings/server.cfg` (a default is created on first start). See [OpenMoHAA docs](https://docs.openmohaa.org/).

## Images

| Name | Notes |
| --- | --- |
| `minecraft-base` | Shared Minecraft runtime |
| `steam-base` | Shared SteamCMD runtime (Arch + XLibre repo) |
| `runtime-base` | Shared Debian slim runtime (non-Steam, non-Java) |
| `minecraft-fabric` | Fabric |
| `minecraft-vanilla` | Vanilla |
| `minecraft-forge` | Forge |
| `valheim` | Valheim dedicated |
| `valheim-plus` | Valheim Plus |
| `ground-branch` | Ground Branch (Wine) |
| `space-engineers` | Space Engineers (Wine) |
| `core-keeper` | Core Keeper dedicated |
| `factorio` | Factorio dedicated |
| `7-days-to-die` | 7 Days to Die dedicated |
| `project-zomboid` | Project Zomboid dedicated |
| `terraria` | Terraria dedicated |
| `l4d2` | Left 4 Dead 2 dedicated |
| `insurgency-source` | Insurgency (Source) dedicated |
| `insurgency-sandstorm` | Insurgency: Sandstorm dedicated |
| `palworld` | Palworld dedicated |
| `starbound` | Starbound dedicated |
| `openmohaa` | OpenMoHAA (BYO MOHAA assets) |
| `arma-3` | Arma 3 dedicated |

```bash
docker pull ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-fabric:latest
```

## CI

- `ci` on push and pull request (docs-only changes are skipped), plus manual runs:
  - `repository checks`: `ci/ci-check.sh` (catalog-driven compose checks, ShellCheck, health/tools tests, GitHub matrix JSON)
  - `trivy / dockerfiles`: Trivy Dockerfile config scans (MEDIUM, HIGH, CRITICAL)
  - On pull requests: local Docker builds for shared base images (`verify-bases`, no registry push)
- `build` runs weekly (Sunday 06:00 UTC), on Dockerfile/base/`ci` path changes to `master`/`main`, and manually: matrix is generated from `ci/image-matrix.sh` via `ci/github-matrix.py`, builds/pushes GHCR images through the reusable `docker-image` workflow, then Trivy-scans them (CRITICAL fail)
- `build-minecraft` is manual only: pick Fabric/Vanilla/Forge + a Minecraft version. Java is resolved from Mojang's `javaVersion`, Temurin Alpine JRE is pinned from Adoptium, Fabric loader/installer and Forge promos auto-fill when left blank. Publishes `minecraft-base:javaN` and `minecraft-<flavor>:<tag>` (tag defaults to the MC version, or `mc-forge` for Forge)

Example tags after a versioned Fabric build for `26.2`:

```text
ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-base:java25
ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-fabric:26.2
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

### GHCR push denied from Actions

If `build` or `build-minecraft` logs show the image built then fails with `denied: installation not allowed to Write organization package` (or similar), the Docker build succeeded and GitHub blocked the registry push.

1. Repository **Settings → Actions → General → Workflow permissions**: choose **Read and write permissions** (not read-only). Workflows also declare `packages: write` on publish jobs, but the repo default must allow it.
2. Open the package on GitHub (**Packages**, or the failed image under `ghcr.io/...`). **Package settings → Manage Actions access** (or link the package to this repository) and grant this repo **Write** access.
3. If the repo lives under an **organization**, check org **Settings → Actions → General** for the same workflow permission default, and org **Packages** policies that restrict Actions from publishing.
4. PR **verify-bases** jobs use `push: false` and should not contact GHCR. Logs that show `pushing layers` to `ghcr.io` are from the **`build`** workflow (merge to `main` / schedule / manual publish), not from verify.

See [Publishing packages with GitHub Actions](https://docs.github.com/en/packages/managing-github-packages-using-github-actions-workflows-and-grants/publishing-and-installing-a-package-with-github-actions).

## Layout

```text
bases/           shared Docker bases
ci/              POSIX CI scripts (repo-meta, server-catalog, checks)
tools/           host ops CLI (gs)
docs/            Starlight site (GitHub Pages)
minecraft/       Fabric, Vanilla, Forge
valheim/         Vanilla and Plus
ground-branch/   Ground Branch
space-engineers/ Space Engineers
core-keeper/     Core Keeper
factorio/         Factorio
7-days-to-die/    7 Days to Die
project-zomboid/  Project Zomboid
terraria/         Terraria
l4d2/             Left 4 Dead 2
insurgency-source/   Insurgency (Source)
insurgency-sandstorm/ Insurgency: Sandstorm
palworld/         Palworld
starbound/        Starbound
openmohaa/       OpenMoHAA
arma/arma-3/     Arma 3
hytale/          external image compose
stardew-valley/  JunimoServer (external images)
```

## License

0BSD
