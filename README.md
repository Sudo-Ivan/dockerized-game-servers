# dockerized-game-servers

Dockerized dedicated game servers with small images and compose files. All Docker images, compose stacks, and server data directories live under `dockerized/`. Shared repo tooling (`ci/`, `tools/`, `docs/`) stays at the repository root. Other non-dockerized content may be added at the root later as this monorepo grows.

Docs publish to GitHub Pages for this repository (see Actions / Pages).

Images publish to GHCR as `ghcr.io/sudo-ivan/dockerized-game-servers/<image>:<tag>`. Compose files use the `IMAGE_OWNER` variable (set it in `.env` or the environment). Forks that publish their own images can set `IMAGE_OWNER` to their `owner/repo` (lowercase).

## Servers

| Server | Compose | Image |
| --- | --- | --- |
| Minecraft Fabric | `dockerized/minecraft/fabric` | `minecraft-fabric` |
| Minecraft Vanilla | `dockerized/minecraft/vanilla` | `minecraft-vanilla` |
| Minecraft Forge | `dockerized/minecraft/forge` | `minecraft-forge` |
| Minecraft NeoForge | `dockerized/minecraft/neoforge` | `minecraft-neoforge` |
| Valheim | `dockerized/valheim/vanilla` | `valheim` |
| Valheim Plus | `dockerized/valheim/plus` | `valheim-plus` |
| Ground Branch | `dockerized/ground-branch` | `ground-branch` |
| Space Engineers | `dockerized/space-engineers` | `space-engineers` |
| Satisfactory | `dockerized/satisfactory` | `satisfactory` |
| Core Keeper | `dockerized/core-keeper` | `core-keeper` |
| Factorio | `dockerized/factorio` | `factorio` |
| Vintage Story | `dockerized/vintage-story` | `vintage-story` |
| 7 Days to Die | `dockerized/7-days-to-die` | `7-days-to-die` |
| Project Zomboid | `dockerized/project-zomboid` | `project-zomboid` |
| Terraria | `dockerized/terraria` | `terraria` |
| Left 4 Dead 2 | `dockerized/l4d2` | `l4d2` |
| Insurgency (Source) | `dockerized/insurgency-source` | `insurgency-source` |
| Insurgency: Sandstorm | `dockerized/insurgency-sandstorm` | `insurgency-sandstorm` |
| Counter-Strike: Source | `dockerized/cs-source` | `cs-source` |
| Killing Floor 2 | `dockerized/kf2` | `kf2` |
| Icarus | `dockerized/icarus` | `icarus` |
| The Forest | `dockerized/the-forest` | `the-forest` |
| Sons Of The Forest | `dockerized/sons-of-the-forest` | `sons-of-the-forest` |
| Sniper Elite 4 | `dockerized/sniper-elite-4` | `sniper-elite-4` |
| SuperTuxKart | `dockerized/supertuxkart` | `supertuxkart` |
| Battlefield 1942 | `dockerized/bf1942` | `bf1942` |
| Battlefield Vietnam | `dockerized/bfv` | `bfv` |
| Call of Duty | `dockerized/cod` | `cod` |
| Call of Duty 2 | `dockerized/cod2` | `cod2` |
| Call of Duty: World at War | `dockerized/codwaw` | `codwaw` |
| Call of Duty 4 | `dockerized/cod4` | `cod4` |
| Quake 3: Arena | `dockerized/quake3` | `quake3` |
| Return to Castle Wolfenstein | `dockerized/rtcw` | `rtcw` |
| ET: Legacy | `dockerized/etl` | `etl` |
| Eco | `dockerized/eco` | `eco` |
| Enshrouded | `dockerized/enshrouded` | `enshrouded` |
| Palworld | `dockerized/palworld` | `palworld` |
| Starbound | `dockerized/starbound` | `starbound` |
| Longvinter | `dockerized/longvinter` | `longvinter` |
| Barotrauma | `dockerized/barotrauma` | `barotrauma` |
| Unturned | `dockerized/unturned` | `unturned` |
| VEIN | `dockerized/vein` | `vein` |
| V Rising | `dockerized/v-rising` | `v-rising` |
| Windrose | `dockerized/windrose` | `windrose` |
| Team Fortress 2 | `dockerized/tf2` | `tf2` |
| Counter-Strike 2 | `dockerized/cs2` | `cs2` |
| Day of Defeat: Source | `dockerized/dod-source` | `dod-source` |
| Don't Starve Together | `dockerized/dont-starve-together` | `dont-starve-together` |
| Garry's Mod | `dockerized/gmod` | `gmod` |
| Delta Force: Black Hawk Down | `dockerized/delta-force-bhd` | `delta-force-bhd` |
| OpenMoHAA | `dockerized/openmohaa` | `openmohaa` |
| Arma 3 | `dockerized/arma/arma-3` | `arma-3` |
| Arma Reforger | `dockerized/arma/reforger` | `arma-reforger` |
| DayZ | `dockerized/dayz` | `dayz` |
| Hytale | `dockerized/hytale` | external (`deinfreu/hytale-server`) |
| Stardew Valley | `dockerized/stardew-valley` | external ([JunimoServer](https://github.com/stardew-valley-dedicated-server/server) `sdvd/server`) |
| AzerothCore | `dockerized/azerothcore` | external ([acore-docker](https://github.com/azerothcore/acore-docker) `acore/ac-wotlk-*`) |

Shared bases (under `dockerized/bases/`):

- `minecraft-base` Temurin JRE on Alpine
- `steam-base` SteamCMD on Arch Linux with the [XLibre](https://github.com/x11libre/xserver) Arch package repo ([xlibre-arch](https://github.com/xlibre-arch/xlibre-arch)) for X11/Xvfb needs
- `runtime-base` Debian slim glibc runtime for non-Steam non-Java servers (Factorio, OpenMoHAA, LinuxGSM legacy binaries)

## Quick start

### Compose

Published images use `IMAGE_OWNER=sudo-ivan/dockerized-game-servers`. For a fork with its own GHCR packages, set `IMAGE_OWNER` in `.env` (see `.env.example`).

```bash
docker compose -f dockerized/minecraft/fabric/docker-compose.yml up
```

To pin the upstream registry explicitly:

```bash
export IMAGE_OWNER=sudo-ivan/dockerized-game-servers
docker compose -f dockerized/minecraft/fabric/docker-compose.yml up
```

Build locally:

```bash
docker compose -f dockerized/minecraft/fabric/docker-compose.yml up --build
```

Compose files reference `ghcr.io/${IMAGE_OWNER}/...` and keep build contexts for local rebuilds. `pull_policy: missing` uses a local image when present, otherwise pulls.

### Docker run

Image prefix: `ghcr.io/sudo-ivan/dockerized-game-servers` (replace `sudo-ivan/dockerized-game-servers` in the examples if you use another registry namespace).

Minecraft Fabric:

```bash
docker run -d --name fabric --restart unless-stopped --init \
  -p 25565:25565/tcp \
  -v "$PWD/dockerized/minecraft/fabric/data:/data" \
  -e EULA=true \
  ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-fabric:latest
```

Minecraft Vanilla:

```bash
docker run -d --name vanilla --restart unless-stopped --init \
  -p 25565:25565/tcp \
  -v "$PWD/dockerized/minecraft/vanilla/data:/data" \
  -e EULA=true \
  ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-vanilla:latest
```

Minecraft Forge:

```bash
docker run -d --name forge --restart unless-stopped --init \
  -p 25565:25565/tcp \
  -v "$PWD/dockerized/minecraft/forge/data:/data" \
  -e EULA=true \
  ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-forge:latest
```

Valheim:

```bash
docker run -d --name valheim --restart unless-stopped --init \
  -p 2456-2458:2456-2458/udp \
  -v "$PWD/dockerized/valheim/vanilla/data:/opt/valheim" \
  -e SERVER_PASS=changeme \
  ghcr.io/sudo-ivan/dockerized-game-servers/valheim:latest
```

Valheim Plus:

```bash
docker run -d --name valheim-plus --restart unless-stopped --init \
  -p 2456-2458:2456-2458/udp \
  -v "$PWD/dockerized/valheim/plus/data:/opt/valheim" \
  -e SERVER_PASS=changeme \
  ghcr.io/sudo-ivan/dockerized-game-servers/valheim-plus:latest
```

Ground Branch:

```bash
docker run -d --name ground-branch --restart unless-stopped --init \
  -p 7777:7777/udp -p 27015:27015/udp \
  -v "$PWD/dockerized/ground-branch/data:/opt/groundbranch" \
  ghcr.io/sudo-ivan/dockerized-game-servers/ground-branch:latest
```

Space Engineers:

```bash
docker run -d --name space-engineers --restart unless-stopped --init \
  -p 27016:27016/udp \
  -v "$PWD/dockerized/space-engineers/data/dedicated:/opt/spaceengineers/dedicated" \
  -v "$PWD/dockerized/space-engineers/data/instances:/opt/spaceengineers/instances" \
  -v "$PWD/dockerized/space-engineers/data/plugins:/opt/spaceengineers/plugins" \
  -e SE_INSTANCE_NAME=Default \
  ghcr.io/sudo-ivan/dockerized-game-servers/space-engineers:latest
```

Satisfactory:

```bash
docker run -d --name satisfactory --restart unless-stopped --init \
  -p 7777:7777/tcp -p 7777:7777/udp -p 8888:8888/tcp \
  -v "$PWD/dockerized/satisfactory/data:/opt/satisfactory" \
  ghcr.io/sudo-ivan/dockerized-game-servers/satisfactory:latest
```

Core Keeper (SDR, no ports):

```bash
docker run -d --name core-keeper --restart unless-stopped --init \
  -v "$PWD/dockerized/core-keeper/data:/opt/corekeeper" \
  ghcr.io/sudo-ivan/dockerized-game-servers/core-keeper:latest
```

Factorio:

```bash
docker run -d --name factorio --restart unless-stopped --init \
  -p 34197:34197/udp -p 27015:27015/tcp \
  -v "$PWD/dockerized/factorio/data:/opt/factorio" \
  -e RCON_PASSWORD=changeme \
  ghcr.io/sudo-ivan/dockerized-game-servers/factorio:latest
```

7 Days to Die:

```bash
docker run -d --name 7-days-to-die --restart unless-stopped --init \
  -p 26900:26900/tcp -p 26900:26900/udp \
  -p 26901-26903:26901-26903/udp \
  -v "$PWD/dockerized/7-days-to-die/data:/opt/7dtd" \
  ghcr.io/sudo-ivan/dockerized-game-servers/7-days-to-die:latest
```

Project Zomboid:

```bash
docker run -d --name project-zomboid --restart unless-stopped --init \
  -p 16261:16261/udp -p 16262:16262/udp \
  -v "$PWD/dockerized/project-zomboid/data:/opt/zomboid" \
  -e PZ_ADMIN_PASSWORD=changeme \
  ghcr.io/sudo-ivan/dockerized-game-servers/project-zomboid:latest
```

Terraria:

```bash
docker run -d --name terraria --restart unless-stopped --init \
  -p 7777:7777/tcp \
  -v "$PWD/dockerized/terraria/data:/opt/terraria" \
  ghcr.io/sudo-ivan/dockerized-game-servers/terraria:latest
```

Left 4 Dead 2:

```bash
docker run -d --name l4d2 --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27005:27005/udp \
  -v "$PWD/dockerized/l4d2/data:/opt/l4d2" \
  ghcr.io/sudo-ivan/dockerized-game-servers/l4d2:latest
```

Insurgency (Source):

```bash
docker run -d --name insurgency-source --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27016:27016/udp \
  -v "$PWD/dockerized/insurgency-source/data:/opt/insurgency-source" \
  ghcr.io/sudo-ivan/dockerized-game-servers/insurgency-source:latest
```

Insurgency: Sandstorm:

```bash
docker run -d --name insurgency-sandstorm --restart unless-stopped --init \
  -p 27102:27102/udp -p 27131:27131/udp \
  -v "$PWD/dockerized/insurgency-sandstorm/data:/opt/insurgency-sandstorm" \
  ghcr.io/sudo-ivan/dockerized-game-servers/insurgency-sandstorm:latest
```

Counter-Strike: Source:

```bash
docker run -d --name cs-source --restart unless-stopped --init \
  -p 27015:27015/tcp -p 27015:27015/udp -p 27005:27005/udp \
  -v "$PWD/dockerized/cs-source/data:/opt/cs-source" \
  -e CSS_GSLT="${CSS_GSLT:-}" \
  ghcr.io/sudo-ivan/dockerized-game-servers/cs-source:latest
```

Killing Floor 2:

```bash
docker run -d --name kf2 --restart unless-stopped --init \
  -p 7777:7777/udp -p 27015:27015/udp -p 8080:8080/tcp -p 20560:20560/udp \
  -v "$PWD/dockerized/kf2/data:/opt/kf2" \
  ghcr.io/sudo-ivan/dockerized-game-servers/kf2:latest
```

Icarus:

```bash
docker run -d --name icarus --restart unless-stopped --init \
  -p 17777:17777/udp -p 27015:27015/udp \
  -v "$PWD/dockerized/icarus/data:/opt/icarus" \
  ghcr.io/sudo-ivan/dockerized-game-servers/icarus:latest
```

The Forest:

```bash
docker run -d --name the-forest --restart unless-stopped --init \
  -p 8766:8766/tcp -p 8766:8766/udp \
  -p 27015:27015/tcp -p 27015:27015/udp \
  -p 27016:27016/tcp -p 27016:27016/udp \
  -v "$PWD/dockerized/the-forest/data:/opt/theforest" \
  ghcr.io/sudo-ivan/dockerized-game-servers/the-forest:latest
```

Sons Of The Forest:

```bash
docker run -d --name sons-of-the-forest --restart unless-stopped --init \
  -p 8766:8766/udp -p 27016:27016/udp -p 9700:9700/udp \
  -v "$PWD/dockerized/sons-of-the-forest/data:/opt/sotf" \
  ghcr.io/sudo-ivan/dockerized-game-servers/sons-of-the-forest:latest
```

Sniper Elite 4:

```bash
docker run -d --name sniper-elite-4 --restart unless-stopped --init \
  -p 27000:27000/udp -p 27005:27005/udp -p 27010:27010/tcp -p 27015:27015/udp \
  -v "$PWD/dockerized/sniper-elite-4/data:/opt/se4" \
  ghcr.io/sudo-ivan/dockerized-game-servers/sniper-elite-4:latest
```

SuperTuxKart:

```bash
docker run -d --name supertuxkart --restart unless-stopped --init \
  -p 2759:2759/udp \
  -v "$PWD/dockerized/supertuxkart/data:/opt/supertuxkart/data" \
  ghcr.io/sudo-ivan/dockerized-game-servers/supertuxkart:latest
```

Palworld:

```bash
docker run -d --name palworld --restart unless-stopped --init \
  -p 8211:8211/udp \
  -v "$PWD/dockerized/palworld/data:/opt/palworld" \
  ghcr.io/sudo-ivan/dockerized-game-servers/palworld:latest
```

Starbound:

```bash
docker run -d --name starbound --restart unless-stopped --init \
  -p 21025:21025/tcp \
  -v "$PWD/dockerized/starbound/data:/opt/starbound" \
  ghcr.io/sudo-ivan/dockerized-game-servers/starbound:latest
```

Longvinter:

```bash
docker run -d --name longvinter --restart unless-stopped --init \
  -p 7777:7777/udp \
  -v "$PWD/dockerized/longvinter/data:/opt/longvinter" \
  ghcr.io/sudo-ivan/dockerized-game-servers/longvinter:latest
```

Don't Starve Together:

```bash
docker run -d --name dont-starve-together --restart unless-stopped --init \
  -p 10999:10999/udp -p 11000:11000/udp -p 27016:27016/udp \
  -v "$PWD/dockerized/dont-starve-together/data:/opt/dst" \
  -e DST_CLUSTER_TOKEN="your-klei-cluster-token" \
  ghcr.io/sudo-ivan/dockerized-game-servers/dont-starve-together:latest
```

Enshrouded:

```bash
docker run -d --name enshrouded --restart unless-stopped --init \
  -p 15636:15636/udp -p 15637:15637/udp \
  -v "$PWD/dockerized/enshrouded/data:/opt/enshrouded" \
  ghcr.io/sudo-ivan/dockerized-game-servers/enshrouded:latest
```

VEIN:

```bash
docker run -d --name vein --restart unless-stopped --init \
  -p 7777:7777/udp -p 27015:27015/udp \
  -v "$PWD/dockerized/vein/data:/opt/vein" \
  ghcr.io/sudo-ivan/dockerized-game-servers/vein:latest
```

V Rising:

```bash
docker run -d --name v-rising --restart unless-stopped --init \
  -p 9876:9876/udp -p 9877:9877/udp -p 9877:9877/tcp \
  -v "$PWD/dockerized/v-rising/data:/opt/vrising" \
  ghcr.io/sudo-ivan/dockerized-game-servers/v-rising:latest
```

Windrose:

```bash
docker run -d --name windrose --restart unless-stopped --init \
  -p 7777:7777/tcp -p 7777:7777/udp \
  -v "$PWD/dockerized/windrose/data:/opt/windrose" \
  ghcr.io/sudo-ivan/dockerized-game-servers/windrose:latest
```

OpenMoHAA (copy your owned MOHAA `main` / `mainta` / `maintt` PK3s into `dockerized/openmohaa/data` first):

```bash
docker run -d --name openmohaa --restart unless-stopped --init \
  -p 12203:12203/udp -p 12300:12300/udp \
  -v "$PWD/dockerized/openmohaa/data:/usr/local/share/mohaa" \
  ghcr.io/sudo-ivan/dockerized-game-servers/openmohaa:latest
```

Arma 3:

```bash
docker run -d --name arma3 --restart unless-stopped \
  -p 2302-2306:2302-2306/udp \
  -v "$PWD/dockerized/arma/arma-3/server:/home/arma3/server" \
  -v "$PWD/dockerized/arma/arma-3/configs:/home/arma3/configs" \
  -v "$PWD/dockerized/arma/arma-3/profiles:/home/arma3/profiles" \
  -v "$PWD/dockerized/arma/arma-3/cache:/home/arma3/cache" \
  -e STEAM_USERNAME=youruser \
  -e STEAM_PASSWORD=yourpass \
  ghcr.io/sudo-ivan/dockerized-game-servers/arma-3:latest
```

Hytale (external image):

```bash
docker run -d --name hytale-server --restart unless-stopped \
  -p 5520:5520/udp \
  -v "$PWD/dockerized/hytale/data:/home/container" \
  -v /etc/machine-id:/etc/machine-id:ro \
  -e SERVER_IP=0.0.0.0 \
  -e SERVER_PORT=5520 \
  deinfreu/hytale-server:latest
```

Stardew Valley (JunimoServer, external images). Copy `dockerized/stardew-valley/.env.example` to `.env`, set Steam credentials and `SDVD_VNC_PASSWORD`, then run Steam setup once before `up`:

```bash
cd dockerized/stardew-valley
cp .env.example .env
docker compose run --rm -it steam-auth setup
docker compose up -d
```

UDP **24642** (game), UDP **27015** (query), TCP **5800** (VNC), TCP **8080** (API). Saves and game files under `dockerized/stardew-valley/data/`. See [Stardew Valley docs](https://sudo-ivan.github.io/dockerized-game-servers/servers/stardew-valley/) and [JunimoServer](https://github.com/stardew-valley-dedicated-server/server).

AzerothCore (WoW 3.3.5a, external `acore/*` images). Copy `dockerized/azerothcore/.env.example` to `.env`, then start the stack. First boot imports SQL and client data and can take several minutes:

```bash
cd dockerized/azerothcore
cp .env.example .env
docker compose up -d
docker attach azerothcore-worldserver
```

TCP **3724** (auth), TCP **8085** (world), TCP **7878** (SOAP). Data under `dockerized/azerothcore/data/`. Create accounts in the worldserver console (`account create ...`). See [AzerothCore docs](https://sudo-ivan.github.io/dockerized-game-servers/servers/azerothcore/) and the [installation guide](https://www.azerothcore.org/wiki/installation).

### Minecraft

Accept the EULA with `EULA=true`. World and config live in each server's `./data` volume.

Default game versions for the regular compose files are in `dockerized/minecraft/defaults.env` (vanilla and forge `26.2`, fabric `26.2` / loader `0.19.3`, forge build `65.0.9`, neoforge `26.2.0.35-beta`). To pick other versions, use `docker-compose.scaffold.yml` with a copied `.env.example`, or pass `-e VANILLA_VERSION=…` / `FABRIC_*` / `FORGE_*` / `NEOFORGE_VERSION` on `docker run`. See the [Minecraft docs](https://sudo-ivan.github.io/dockerized-game-servers/servers/minecraft/) for details.

### Steam games

Many titles still allow anonymous SteamCMD. Valve has removed anonymous access for some dedicated servers (for example Left 4 Dead 2 and Counter-Strike: Source). Those need `STEAM_USERNAME` and `STEAM_PASSWORD` for an account that owns the game, plus optional `STEAM_GUARD_CODE`. Linux installs use a shared SteamCMD workaround in `steam-base` (rebuild `steam-base` before game images when updating install logic). Arma 3 usually needs a Steam account that owns the server files. Set Valheim `SERVER_PASS` via `-e` or a `.env` file next to compose.

### Ground Branch

Server config appears under `dockerized/ground-branch/data/GroundBranch/ServerConfig/` after first start. Optional map/mission via `GB_MAP` and `GB_MISSION`.

### Space Engineers

Steam App 298740 (Windows dedicated server via Wine). Persist `dockerized/space-engineers/data/dedicated`, `instances`, and `plugins` (Wine/dotnet is baked into the image). Default instance `Default`, config `dockerized/space-engineers/data/instances/Default/SpaceEngineers-Dedicated.cfg`. First start downloads server files into `data/dedicated` (allow several minutes). UDP game port 27016. Set `SE_PUBLIC_IP` when the container cannot infer a reachable address for the dedicated config.

### Satisfactory

Steam App 1690800. Native Linux `FactoryServer.sh`. TCP/UDP 7777 and TCP 8888 (reliable channel). Persist `dockerized/satisfactory/data`. Allocate at least 8 GB RAM. Updates: `SATISFACTORY_FORCE_UPDATE=true`.

### Core Keeper

Defaults to Steam Datagram Relay (SDR). No published ports are required. When ready, `docker logs` prints the Game ID and `Status: server is up and ready for players!`. Fallback:

```bash
docker exec -it core-keeper cat /opt/corekeeper/server/GameID.txt
```

For direct connect, set `SERVER_PORT` and publish that UDP port. World data lives under `dockerized/core-keeper/data/`. Uses XLibre `xlibre-xserver-xvfb` (not X.Org) for the virtual display.

### Ops

Backup, restore, update, and healthchecks: `./tools/gs` (see docs guides/ops). Examples:

```bash
./tools/gs list
./tools/gs backup core-keeper
./tools/gs update factorio --backup
```

`./tools/gs` resolves `IMAGE_OWNER` from your git remote via `ci/repo-meta.sh`. Forks can `export IMAGE_OWNER=your-user/your-fork` when using custom images.

### Factorio

Downloads the official headless package from factorio.com (`FACTORIO_VERSION`, default `stable`). Creates `saves/<SAVE_NAME>.zip` on first start and writes `config/server-settings.json` if missing. Game traffic is UDP `34197`. Set `RCON_PASSWORD` to enable RCON on TCP `27015`. Edit settings under `dockerized/factorio/data/config/` after the first run.

### Vintage Story

Downloads the official Linux server package from cdn.vintagestory.at (`VS_VERSION`, default `1.22.6`, branch `stable`) and runs it with .NET 10 (required for 1.22+). Persistent world data mounts at `dockerized/vintage-story/data` (`serverconfig.json`, `Saves/`, `Mods/`). Game traffic uses TCP and UDP `42420`. Edit `serverconfig.json` after the first run. Set `VS_FORCE_UPDATE=true` or change `VS_VERSION` to reinstall server binaries.

### 7 Days to Die

Steam App 294420 via anonymous login. Persist `/opt/7dtd` (world, `Saves/`, config). Default `serverconfig.xml` is created on first start if missing. Game ports TCP/UDP 26900 and UDP 26901-26903.

### Project Zomboid

Steam App 380870. Server binaries under `dockerized/project-zomboid/data/server`. Saves and ini files under `dockerized/project-zomboid/data/home/Zomboid/`. Set `PZ_ADMIN_PASSWORD` before the first launch.

### Terraria

Steam App 105600. Official dedicated server binary and `serverconfig.txt` under `dockerized/terraria/data`. Default TCP port 7777.

### Left 4 Dead 2

Steam App 222860. Source dedicated server via `srcds_run`. Default map `c1m1_hotel`, port 27015 TCP/UDP. Set `L4D2_STARTMAP`, `L4D2_MAXPLAYERS`, and `L4D2_EXTRA_ARGS` as needed. SteamCMD needs an account that owns Left 4 Dead 2 (`STEAM_USERNAME`, `STEAM_PASSWORD`, optional `STEAM_GUARD_CODE`).

### Insurgency (Source)

Steam App 237410. Source dedicated server via `srcds_run` (`-game insurgency`). Default map `ministry`, ports 27015 and 27016. Config under `dockerized/insurgency-source/data/insurgency/cfg/` after first run.

### Insurgency: Sandstorm

Steam App 581330. Linux dedicated binary under `dockerized/insurgency-sandstorm/data`. Default UDP 27102 (game) and 27131 (query). Set `INS_SANDSTORM_MAP`, `INS_SANDSTORM_SCENARIO`, `INS_SANDSTORM_GSLT`, and `INS_SANDSTORM_GAMESTATS_TOKEN` for listing and GameStats. Use `INS_SANDSTORM_EXTRA_ARGS` for mutators, `-mods`, and `ModDownloadTravelTo`. Mod config files live under `dockerized/insurgency-sandstorm/data/Insurgency/Config/Server/`. See the [Insurgency Sandstorm](https://sudo-ivan.github.io/dockerized-game-servers/servers/insurgency-sandstorm/) docs page for a full modding guide. Allocate at least 8 GB RAM.

### Counter-Strike: Source

Steam App 232330. Source `srcds` with `-game cstrike`. Default map `de_dust2`. Set `CSS_GSLT` for public listing. Config under `dockerized/cs-source/data/cstrike/cfg/`.

### Killing Floor 2

Steam App 232130. Linux binary `KFGameSteamServer.bin.x86_64`. UDP 7777 game, 27015 query, TCP 8080 web admin. Default map `kf-bioticslab`. Config in `dockerized/kf2/data/KFGame/Config/`.

### Icarus

Steam App 2089300 (Windows server via Wine). UDP 17777 and 27015 query. Set `ICARUS_GAME_MODE`, `ICARUS_SESSION_NAME`, and related env vars. Persist `dockerized/icarus/data` including `.wine`. Allocate at least 8 GB RAM.

### The Forest

Steam App 556450. Native Linux dedicated binary (no Wine). UDP/TCP 8766 (Steam), 27015 (game), 27016 (query). Set `FOREST_SERVER_NAME`, `FOREST_DIFFICULTY`, `FOREST_MAX_PLAYERS`. Defaults to `FOREST_INIT_TYPE=Continue` so container restarts load the existing save instead of overwriting it. Persist `dockerized/the-forest/data`.

### Sons Of The Forest

Steam App 2465200 (dedicated server tool, Windows via Wine). UDP 8766 (game), 27016 (query), 9700 (BlobSync). `dedicatedserver.cfg` and `ownerswhitelist.txt` are generated under `dockerized/sons-of-the-forest/data/userdata/` on first start. Allocate at least 6 GB RAM.

### Sniper Elite 4

Steam App 568880 (dedicated server tool, Windows via Wine). UDP 27000 (auth), UDP 27005 (game), TCP 27010 (lobby), UDP 27015 (update). `server.cfg` is generated in `dockerized/sniper-elite-4/data/` with map rotation from `SE4_MAP_ROTATION`. Some accounts may need `STEAM_USERNAME` / `STEAM_PASSWORD` instead of anonymous login.

### SuperTuxKart

Not Steam-based. Compiled from the official `stk-code` source tarball with `-DSERVER_ONLY=ON`, no OpenGL/GPU dependency. Default LAN mode needs no account, set `STK_MODE=wan` plus `STK_ONLINE_USERNAME` / `STK_ONLINE_PASSWORD` (a free [STK Online](https://online.supertuxkart.net/register.php) account) to list publicly. UDP 2759. `server_config.xml` generated in `dockerized/supertuxkart/data/`. The lightest server in this repo, `mem_limit` is 512M.

### Battlefield 1942 / Vietnam

Linux dedicated files from [LinuxGSM](http://linuxgsm.download/) (same archives as LinuxGSM `install_server_files.sh`). You must own the game. Images bake the server payload; first start copies into `dockerized/bf1942/data` or `dockerized/bfv/data`. BF1942: UDP 14567 and TCP 23000. BFV: see `dockerized/bfv/docker-compose.yml` for ports.

### Call of Duty (1 / 2 / WaW / 4)

LinuxGSM-hosted dedicated binaries (`dockerized/cod_lnxded`, `dockerized/cod2_lnxded`, `dockerized/codwaw_lnxded`, CoD4x `dockerized/cod4x18_dedrun`). Data volumes are large for CoD2 and WaW. Default game UDP is 28960 for all four: change compose ports and `*_PORT` env vars if you run more than one on a host. CoD4 sets `sv_authorizemode -1` like typical LGSM configs.

### Quake 3: Arena

LinuxGSM Q3 dedicated archive. Default UDP 27960, map `q3dm17`. Data under `dockerized/quake3/data`.

### Return to Castle Wolfenstein

LinuxGSM [ioRTCW](http://linuxgsm.download/ReturnToCastleWolfenstein/) server archive. Default UDP 27960, map `mp_beach`. Data under `dockerized/rtcw/data`.

### ET: Legacy

[GameServerManagers etlserver-build](https://github.com/GameServerManagers/etlserver-build) bundle (32-bit `etlded`). Default UDP 27960 (game) and 27961 (status). Map `oasis`, gametype `4` (objective). Set `ETL_FORCE_UPDATE=true` to re-fetch the bundle into the volume. Data under `dockerized/etl/data`.

### Eco

Steam App 739590. **Requires `ECO_USER_TOKEN`** from the Eco client. UDP 3000 and 3001. Allocate at least 4 GB RAM. Updates: `ECO_FORCE_UPDATE=true`.

### Enshrouded

Steam App 2278520 (Windows server via Wine). UDP 15636 (game) and 15637 (query). `dockerized/enshrouded_server.json` is generated in `dockerized/enshrouded/data/` on first start. Allocate at least 8 GB RAM. Updates: `ENSHROUDED_FORCE_UPDATE=true`.

### Palworld

Steam App 2394010. Saves and `PalWorldSettings.ini` under `dockerized/palworld/data/Pal/Saved/` after first run. Default UDP 8211. Allocate at least 8 GB RAM for the container.

### Starbound

Steam App 211820. Writes `dockerized/starbound_server.config` on first start if missing. Default TCP 21025.

### Longvinter

Steam App 1639880. Writes `Game.ini` on first start if missing. Default UDP 7777. Allocate at least 4 GB RAM. Saves under `dockerized/longvinter/data/Longvinter/Saved/`.

### Barotrauma

Steam App 1026340. Native Linux `DedicatedServer` binary. UDP 27015 and 27016. Config under `dockerized/barotrauma/data/` after first run. Allocate at least 4 GB RAM. Updates: `BAROTRAUMA_FORCE_UPDATE=true`.

### Unturned

Steam App 1110390. Linux dedicated via `ServerHelper.sh`. UDP 27015 and 27016. Set `UNTURNED_SERVER_NAME` for the InternetServer slot. Data under `dockerized/unturned/data/`. Allocate at least 4 GB RAM. Updates: `UNTURNED_FORCE_UPDATE=true`.

### VEIN

Steam App 2131400 (Windows server via Wine). UDP 7777 (game) and 27015 (query). Launch args set port, query port, and player cap. Persist `dockerized/vein/data` including `.wine`. Allocate at least 8 GB RAM. Updates: `VEIN_FORCE_UPDATE=true`.

### V Rising

Steam App 1829350 (Windows server via Wine). UDP 9876 (game) and 9877 (query, UDP and TCP). `ServerHostSettings.json` is generated under `dockerized/v-rising/data/VRisingServer_Data/StreamingAssets/Settings/` on first start. Allocate at least 6 GB RAM. Updates: `VRISING_FORCE_UPDATE=true`.

### Windrose

Steam App 4129620 (Windows server via Wine). TCP and UDP 7777 for direct connection. `R5/ServerDescription.json` is generated in `dockerized/windrose/data/` on first start. Allocate at least 8 GB RAM. Updates: `WINDROSE_FORCE_UPDATE=true`.

### Team Fortress 2

Steam App 232250. Source `srcds_run` with `-game tf`. Default map `cp_dustbowl`, port 27015 TCP/UDP. Set `TF2_GSLT` for public listing. Config under `dockerized/tf2/data/tf/cfg/`. Uses `STEAMCMD_WINDOWS_WORKAROUND=full`. SteamCMD may need an account that owns Team Fortress 2.

### Counter-Strike 2

Steam App 730 (dedicated server). CS2 binary under `dockerized/cs2/data/game/bin/linuxsteamrt64/`. TCP/UDP 27015 and UDP 27020. Set `CS2_GSLT` for public listing. Default map `de_dust2`. Allocate at least 8 GB RAM. Updates: `CS2_FORCE_UPDATE=true`.

### Day of Defeat: Source

Steam App 232290. Source `srcds_run` with `-game dod`. Default map `dod_anzio`, port 27015 TCP/UDP. Set `DOD_GSLT` for public listing. Config under `dockerized/dod-source/data/dod/cfg/`. Uses `STEAMCMD_WINDOWS_WORKAROUND=full`.

### Don't Starve Together

Steam App 343050. Native Linux dedicated server with Master and Caves shards. UDP 10999 (Master), 11000 (Caves), and 27016 (Steam master). Set `DST_CLUSTER_TOKEN` from https://accounts.klei.com/ for online play. Cluster config and saves under `dockerized/dont-starve-together/data/klei/DoNotStarveTogether/`. Allocate at least 4 GB RAM. Updates: `DST_FORCE_UPDATE=true`.

### Garry's Mod

Steam App 4020. Source `srcds_run` with `-game garrysmod`. Default map `gm_flatgrass`, port 27015 TCP/UDP. Set `GMOD_GSLT` for public listing. Workshop and Lua addons under `dockerized/gmod/data/garrysmod/`. Uses `STEAMCMD_WINDOWS_WORKAROUND=full`. Allocate at least 4 GB RAM.

### Delta Force: Black Hawk Down

No SteamCMD dedicated server. **You must copy owned Windows game files** (`dfbhd.exe` and data) into `dockerized/delta-force-bhd/data/` before the server can run. Runs via Wine. Default UDP 3568. Community multiplayer may need external NovaHQ heartbeat tools.

### Stardew Valley

Uses [JunimoServer](https://github.com/stardew-valley-dedicated-server/server) (`sdvd/server` on Docker Hub), not a first-party image from this repo. Requires Steam credentials that own Stardew Valley. Two-service compose: `server` plus `steam-auth`. First-time `docker compose run --rm -it steam-auth setup` for Steam Guard and game download. Farm saves under `dockerized/stardew-valley/data/saves`, settings in `data/settings/server-settings.json`. Optional Discord bot: `docker compose --profile discord up -d`.

### AzerothCore

Uses pre-built [AzerothCore](https://www.azerothcore.org/) images (`acore/ac-wotlk-*` on Docker Hub), not a first-party image from this repo. Multi-service compose: MySQL, one-shot DB import and client-data init, `authserver`, and `worldserver`. First `docker compose up` downloads images and imports databases. Persist `dockerized/azerothcore/data/` (MySQL, maps, logs, config). Attach to `azerothcore-worldserver` to run `account create`. Players need a **3.3.5a** client pointed at your host. Optional phpMyAdmin: `docker compose --profile admin up -d`. See [AzerothCore installation](https://www.azerothcore.org/wiki/installation).

### OpenMoHAA

Uses [OpenMoHAA](https://github.com/openmoh/openmohaa) release binaries. **You must copy licensed Allied Assault game data** (`main`, and optionally `mainta` / `maintt` PK3s) into `dockerized/openmohaa/data/` before the server can run. Defaults: UDP `12203` (game) and UDP `12300` (GameSpy). Server config: `dockerized/openmohaa/data/home/main/settings/server.cfg` (a default is created on first start). See [OpenMoHAA docs](https://docs.openmohaa.org/).

### Arma 3

Steam App 233780. Linux dedicated server via SteamCMD with workshop mod sync from an HTML preset. UDP 2302-2306 (game). Requires `STEAM_USERNAME` / `STEAM_PASSWORD` for an account that owns the server files. Config `dockerized/arma/arma-3/configs/server.cfg`, modlist `dockerized/arma/arma-3/server/modlist.html`. See the [Arma 3](https://sudo-ivan.github.io/dockerized-game-servers/servers/arma-3/) docs page.

### Arma Reforger

Steam App 1874900. Native Linux `ArmaReforgerServer` via SteamCMD. Compose uses `STEAMCMD_WINDOWS_WORKAROUND=full` for anonymous installs. UDP 2001 and 17777. Server JSON under `dockerized/arma/reforger/data/Configs/`. Mods use the [Reforger Workshop](https://reforger.armaplatform.com/workshop) (16-char `modId` in `ServerConfig.json`, not Steam Workshop). See the [Arma Reforger](https://sudo-ivan.github.io/dockerized-game-servers/servers/arma-reforger/) docs page.

### DayZ

Steam App 223350. Requires `STEAM_USERNAME` / `STEAM_PASSWORD` for an account that owns DayZ (no anonymous depot). UDP 2302-2306. Config `dockerized/dayz/data/serverDZ.cfg`, profiles under `dockerized/dayz/data/profiles/`. Mods: Steam Workshop via App 221100, `.bikey` files in `keys/`, `-mod=` via `DAYZ_EXTRA_ARGS`. See the [DayZ](https://sudo-ivan.github.io/dockerized-game-servers/servers/dayz/) docs page.

## Images

| Name | Notes |
| --- | --- |
| `minecraft-base` | Shared Minecraft runtime |
| `steam-base` | Shared SteamCMD runtime (Arch + XLibre repo) |
| `runtime-base` | Shared Debian slim runtime (non-Steam, non-Java) |
| `minecraft-fabric` | Fabric |
| `minecraft-vanilla` | Vanilla |
| `minecraft-forge` | Forge |
| `minecraft-neoforge` | NeoForge |
| `valheim` | Valheim dedicated |
| `valheim-plus` | Valheim Plus |
| `ground-branch` | Ground Branch (Wine) |
| `space-engineers` | Space Engineers (Wine) |
| `satisfactory` | Satisfactory dedicated (native Linux) |
| `core-keeper` | Core Keeper dedicated |
| `factorio` | Factorio dedicated |
| `vintage-story` | Vintage Story dedicated |
| `7-days-to-die` | 7 Days to Die dedicated |
| `project-zomboid` | Project Zomboid dedicated |
| `terraria` | Terraria dedicated |
| `l4d2` | Left 4 Dead 2 dedicated |
| `insurgency-source` | Insurgency (Source) dedicated |
| `insurgency-sandstorm` | Insurgency: Sandstorm dedicated |
| `cs-source` | Counter-Strike: Source dedicated |
| `kf2` | Killing Floor 2 dedicated |
| `icarus` | Icarus dedicated (Wine) |
| `the-forest` | The Forest dedicated (native Linux) |
| `sons-of-the-forest` | Sons Of The Forest dedicated (Wine) |
| `sniper-elite-4` | Sniper Elite 4 dedicated (Wine) |
| `supertuxkart` | SuperTuxKart dedicated (compiled from source) |
| `bf1942` | Battlefield 1942 dedicated (LinuxGSM files) |
| `bfv` | Battlefield Vietnam dedicated (LinuxGSM files) |
| `cod` | Call of Duty dedicated (LinuxGSM files) |
| `cod2` | Call of Duty 2 dedicated (LinuxGSM files) |
| `codwaw` | Call of Duty: World at War dedicated (LinuxGSM files) |
| `cod4` | Call of Duty 4 dedicated (CoD4x / LinuxGSM files) |
| `quake3` | Quake 3: Arena dedicated (LinuxGSM files) |
| `rtcw` | Return to Castle Wolfenstein dedicated (ioRTCW / LinuxGSM files) |
| `etl` | ET: Legacy dedicated (etlserver-build) |
| `eco` | Eco dedicated (Steam) |
| `enshrouded` | Enshrouded dedicated (Wine) |
| `palworld` | Palworld dedicated |
| `starbound` | Starbound dedicated |
| `longvinter` | Longvinter dedicated |
| `barotrauma` | Barotrauma dedicated |
| `unturned` | Unturned dedicated |
| `vein` | VEIN dedicated (Wine) |
| `v-rising` | V Rising dedicated (Wine) |
| `windrose` | Windrose dedicated (Wine) |
| `tf2` | Team Fortress 2 dedicated |
| `cs2` | Counter-Strike 2 dedicated |
| `dod-source` | Day of Defeat: Source dedicated |
| `dont-starve-together` | Don't Starve Together dedicated (native Linux) |
| `gmod` | Garry's Mod dedicated |
| `delta-force-bhd` | Delta Force: Black Hawk Down (Wine, BYO game files) |
| `openmohaa` | OpenMoHAA (BYO MOHAA assets) |
| `arma-3` | Arma 3 dedicated |
| `arma-reforger` | Arma Reforger dedicated |
| `dayz` | DayZ dedicated |

```bash
docker pull ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-fabric:latest
```

## CI

- `ci` on push and pull request (docs-only changes are skipped), plus manual runs:
  - `repository checks`: `ci/ci-check.sh` (catalog-driven compose checks, ShellCheck, health/tools tests, GitHub matrix JSON)
  - `trivy / dockerfiles`: Trivy Dockerfile config scans (MEDIUM, HIGH, CRITICAL)
  - On pull requests: local Docker builds for shared base images (`verify-bases`, no registry push)
- `build` runs weekly (Sunday 06:00 UTC), on Dockerfile/base/`ci` path changes to `master`/`main`, and manually: matrix is generated from `ci/image-matrix.sh` via `ci/github-matrix.py`, builds/pushes GHCR images through the reusable `docker-image` workflow, then Trivy-scans them (CRITICAL fail)
- `build-minecraft` is manual only: pick Fabric/Vanilla/Forge + a Minecraft version. Java is resolved from Mojang's `javaVersion`, Temurin Alpine JRE is pinned from Adoptium, Fabric loader/installer and Forge promos auto-fill when left blank. Publishes `dockerized/minecraft-base:javaN` and `dockerized/minecraft-<flavor>:<tag>` (tag defaults to the MC version, or `mc-forge` for Forge)

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

Trivy is installed from a pinned GitHub release tarball with SHA-256 verification (`ci/install-trivy.sh`). This repo does not use `aquasecurity/trivy-action` after the March 2026 supply-chain compromise. Shared scan settings live in `dockerized/trivy.yaml`.

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
ci/              POSIX CI scripts (repo-meta, server-catalog, checks)
tools/           host ops CLI (gs)
docs/            Starlight site (GitHub Pages)
eggs/            Pterodactyl egg JSON (optional)
dockerized/
  bases/           shared Docker bases
  trivy.yaml       Trivy scan config for Dockerfiles
  minecraft/       Fabric, Vanilla, Forge, NeoForge
  valheim/         Vanilla and Plus
  ground-branch/   Ground Branch
  space-engineers/ Space Engineers
  satisfactory/    Satisfactory
  core-keeper/     Core Keeper
  factorio/         Factorio
  vintage-story/    Vintage Story
  7-days-to-die/    7 Days to Die
  project-zomboid/  Project Zomboid
  terraria/         Terraria
  l4d2/             Left 4 Dead 2
  insurgency-source/   Insurgency (Source)
  insurgency-sandstorm/ Insurgency: Sandstorm
  cs-source/        Counter-Strike: Source
  kf2/              Killing Floor 2
  icarus/           Icarus
  the-forest/      The Forest
  sons-of-the-forest/ Sons Of The Forest
  sniper-elite-4/  Sniper Elite 4
  supertuxkart/    SuperTuxKart
  enshrouded/       Enshrouded
  palworld/         Palworld
  starbound/        Starbound
  longvinter/       Longvinter
  barotrauma/      Barotrauma
  unturned/        Unturned
  vein/            VEIN
  v-rising/        V Rising
  windrose/        Windrose
  tf2/             Team Fortress 2
  cs2/             Counter-Strike 2
  dod-source/      Day of Defeat: Source
  dont-starve-together/ Don't Starve Together
  gmod/            Garry's Mod
  delta-force-bhd/ Delta Force: Black Hawk Down (Wine, BYO game files)
  openmohaa/       OpenMoHAA
  arma/arma-3/     Arma 3
  arma/reforger/   Arma Reforger
  dayz/            DayZ
  hytale/          external image compose
  stardew-valley/  JunimoServer (external images)
  azerothcore/     AzerothCore WotLK (external acore/* images)
```

## License

0BSD
