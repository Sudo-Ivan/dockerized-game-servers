---
title: Minecraft
description: Fabric, Vanilla, Forge, and NeoForge dedicated servers.
iconFit: contain
---

Four flavors share minecraft-base (Temurin JRE on Alpine). Each image downloads or installs the server jar at container start from the version environment variables below.

| Flavor | Compose | Image |
| --- | --- | --- |
| Fabric | minecraft/fabric | minecraft-fabric |
| Vanilla | minecraft/vanilla | minecraft-vanilla |
| Forge | minecraft/forge | minecraft-forge |
| NeoForge | minecraft/neoforge | minecraft-neoforge |

:::note[Requirements]
- Set `EULA=true`
- Persist `./data` for world and config
- Publish TCP and UDP **25565** by default
:::

## Default versions (regular compose)

The default `docker-compose.yml` files load pinned versions from [`minecraft/defaults.env`]({{GITHUB_URL}}/blob/master/minecraft/defaults.env). CI keeps those values aligned with each image Dockerfile and entrypoint.

| Flavor | Variables | Current default |
| --- | --- | --- |
| Vanilla | `VANILLA_VERSION` | `26.2` |
| Fabric | `FABRIC_MINECRAFT_VERSION`, `FABRIC_LOADER_VERSION`, `FABRIC_INSTALLER_VERSION` | `26.2`, `0.19.3`, `1.1.1` |
| Forge | `FORGE_MINECRAFT_VERSION`, `FORGE_VERSION` | `26.2`, `65.0.9` |
| NeoForge | `NEOFORGE_VERSION` | `26.2.0.35-beta` |

Vanilla resolves `VANILLA_VERSION` from the Mojang version manifest (same id string Fabric uses for current releases, for example `26.2`). [NeoForge](https://neoforged.net/) uses a single Maven version string (for example `26.2.0.35-beta` for Minecraft `26.2`). Pick releases from the [NeoForged installer files](https://neoforged.net/) or `ci/resolve-minecraft-build.sh --flavor neoforge --minecraft-version 26.2`.

After changing game files, set the matching force flag so the entrypoint re-downloads or re-installs: `VANILLA_FORCE_DOWNLOAD`, `FABRIC_FORCE_DOWNLOAD`, `FORGE_FORCE_INSTALL`, or `NEOFORGE_FORCE_INSTALL`. These are the same env vars `./tools/gs update` sets to `true` for a one-shot recreate, see [Ops](/guides/ops/).

## Memory and JVM flags

Each Dockerfile bakes a default `JVM_FLAGS` (G1GC tuning) and each compose file sets a `mem_limit`. Override `JVM_FLAGS` in the compose `environment:` block or with `docker run -e JVM_FLAGS=...` to change heap size.

| Flavor | Default heap | Compose `mem_limit` |
| --- | --- | --- |
| Fabric | `-Xms2G -Xmx2G` | `3072M` |
| Vanilla | `-Xms2G -Xmx2G` | `3072M` |
| Forge | `-Xms3G -Xmx3G` | `4096M` |
| NeoForge | `-Xms3G -Xmx3G` | `4096M` |

## World data and permissions

The process runs with working directory `/data` (your compose `./data` mount). Use `PUID` and `PGID` so files on the host match your user. Every start writes `eula.txt` when `EULA=true`.

Common paths under `/data`:

| Path | Purpose |
| --- | --- |
| `server.properties` | Port, motd, difficulty, max players |
| `world/` | Default world (name from `level-name` in server.properties) |
| `world/datapacks/` | Vanilla and modded datapacks (Java Edition) |
| `mods/` | Fabric, Forge, or NeoForge mod jars |
| `config/` | Mod loader configuration |

Edit `server.properties` on the host while the server is stopped, or use the in-game `/reload` only for settings that support it.

## Datapacks (vanilla and modded)

Datapacks are version-specific. For vanilla:

1. Download or build a datapack zip.
2. Place it in `minecraft/vanilla/data/world/datapacks/` (create folders if needed).
3. Restart the server or run `/reload` if the pack allows hot reload.

For a new world, set `level-name` in `server.properties` before first start, or add datapacks before the world folder is created.

Fabric and Forge worlds use the same `world/datapacks/` layout. Mods may add game rules datapacks depend on.

## Mods (Fabric, Forge, and NeoForge)

1. Match mod jars to your loader version (Fabric loader, Forge build, or NeoForge `NEOFORGE_VERSION`).
2. Drop `.jar` files into `minecraft/<flavor>/data/mods/`.
3. Restart the server. Check `logs/latest.log` for loader errors.

Fabric downloads the server launcher jar on first start. Forge and NeoForge run the official installer into `/data` and use `run.sh` or `unix_args.txt` when present. After changing loader versions, set `FORGE_FORCE_INSTALL=true` or `NEOFORGE_FORCE_INSTALL=true` once so binaries match your mods.

Client-only mods do not belong on the dedicated server. Use the mod loader's "server" or "universal" artifacts.

## Compose (pinned defaults)

```bash
docker compose -f minecraft/fabric/docker-compose.yml up
```

Replace `fabric` with `vanilla`, `forge`, or `neoforge` as needed.

## Compose (choose your version)

Use `docker-compose.scaffold.yml` when you want versions in a local `.env` file (or shell exports) instead of only the repo defaults.

```bash
cd minecraft/fabric
cp .env.example .env
# edit .env, then:
docker compose -f docker-compose.scaffold.yml up
```

Scaffold compose merges `minecraft/defaults.env`, optional `.env` in the flavor directory, and explicit `environment` entries so overrides win. You can also pass the defaults file on the command line:

```bash
docker compose -f minecraft/vanilla/docker-compose.scaffold.yml \
  --env-file minecraft/defaults.env up
```

Use the same pattern under `minecraft/vanilla`, `minecraft/forge`, and `minecraft/neoforge` with their `.env.example` files.

## Docker run

Pass version variables with `-e` (image defaults apply when omitted). Set `EULA=true` and mount `./data`.

Fabric:

```bash
docker run -d --name fabric --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/fabric/data:/data" \
  -e EULA=true \
  -e FABRIC_MINECRAFT_VERSION=26.2 \
  -e FABRIC_LOADER_VERSION=0.19.3 \
  -e FABRIC_INSTALLER_VERSION=1.1.1 \
  {{IMAGE_PREFIX}}/minecraft-fabric:latest
```

Vanilla:

```bash
docker run -d --name vanilla --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/vanilla/data:/data" \
  -e EULA=true \
  -e VANILLA_VERSION=26.2 \
  {{IMAGE_PREFIX}}/minecraft-vanilla:latest
```

Forge:

```bash
docker run -d --name forge --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/forge/data:/data" \
  -e EULA=true \
  -e FORGE_MINECRAFT_VERSION=26.2 \
  -e FORGE_VERSION=65.0.9 \
  {{IMAGE_PREFIX}}/minecraft-forge:latest
```

NeoForge:

```bash
docker run -d --name neoforge --restart unless-stopped --init \
  -p 25565:25565/tcp -p 25565:25565/udp \
  -v "$PWD/minecraft/neoforge/data:/data" \
  -e EULA=true \
  -e NEOFORGE_VERSION=26.2.0.35-beta \
  {{IMAGE_PREFIX}}/minecraft-neoforge:latest
```

Optional overrides: `VANILLA_JAR_URL` (Mojang hosts only), `FORGE_INSTALLER_URL` (Maven Forge host only), `NEOFORGE_INSTALLER_URL` (`maven.neoforged.net` only).

## Healthcheck

`healthcheck.sh` probes for a listening TCP socket on `SERVER_PORT` (default `25565`). If you change `server-port` in `server.properties` and remap the compose ports, also set `SERVER_PORT` to match so the healthcheck keeps working.

## Versioned image builds

The manual `build-minecraft` workflow can publish tags for a chosen Minecraft version. See [CI](/reference/ci/).

## See also

- [All servers](/reference/servers/) for compose paths and image names
- [Images](/reference/images/) for the shared `minecraft-base` image
- [Ops](/guides/ops/) for `./tools/gs backup`, `restore`, and `update`
