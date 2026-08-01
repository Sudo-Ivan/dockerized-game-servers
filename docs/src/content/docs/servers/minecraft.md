---
title: Minecraft
description: Fabric, Vanilla, Forge, and NeoForge dedicated servers.
iconFit: contain
---

Four server types are available: Fabric, Vanilla, Forge, and NeoForge. They all share the same base setup. When the container starts, it downloads and installs the right server files for the version you pick.

| Flavor | Compose folder | Image name |
| --- | --- | --- |
| Fabric | minecraft/fabric | minecraft-fabric |
| Vanilla | minecraft/vanilla | minecraft-vanilla |
| Forge | minecraft/forge | minecraft-forge |
| NeoForge | minecraft/neoforge | minecraft-neoforge |

:::note[Before you start]
- Accept the Minecraft EULA (set EULA to true)
- Keep a data folder for your world and settings
- Open TCP port 25565 for Java Edition (Bedrock uses UDP 19132 and is not covered by these images)
:::

## Default versions

The included compose files pin versions in [minecraft/defaults.env]({{GITHUB_URL}}/blob/master/minecraft/defaults.env). CI keeps those values in sync with each image.

| Flavor | Settings | Current default |
| --- | --- | --- |
| Vanilla | VANILLA_VERSION | 26.2 |
| Fabric | FABRIC_MINECRAFT_VERSION, FABRIC_LOADER_VERSION, FABRIC_INSTALLER_VERSION | 26.2, 0.19.3, 1.1.1 |
| Forge | FORGE_MINECRAFT_VERSION, FORGE_VERSION | 26.2, 65.0.9 |
| NeoForge | NEOFORGE_VERSION | 26.2.0.35-beta |

Vanilla looks up the version from Mojang's release list (the same version id Fabric uses, for example 26.2). [NeoForge](https://neoforged.net/) uses one Maven version string (for example 26.2.0.35-beta for Minecraft 26.2). Pick a release from the [NeoForged installer files](https://neoforged.net/) or run ci/resolve-minecraft-build.sh with flavor neoforge and your target Minecraft version.

After you change game files, set the matching force flag so the container re-downloads on next start: VANILLA_FORCE_DOWNLOAD, FABRIC_FORCE_DOWNLOAD, FORGE_FORCE_INSTALL, or NEOFORGE_FORCE_INSTALL. The ./tools/gs update command sets these for a one-shot recreate. See [Ops](/guides/ops/).

## Memory

Each image sets a default heap size and a memory limit in compose. To change heap size, override JVM_FLAGS in the compose environment block or pass it with docker run -e.

| Flavor | Default heap | Compose memory limit |
| --- | --- | --- |
| Fabric | 2 GB min and max | 3072M |
| Vanilla | 2 GB min and max | 3072M |
| Forge | 3 GB min and max | 4096M |
| NeoForge | 3 GB min and max | 4096M |

## World data and file ownership

The server runs with /data as its working directory (your compose data folder on the host). Set PUID and PGID if you want files on the host to match your user. When EULA is true, eula.txt is written on every start.

Common paths inside the data folder:

| Path | Purpose |
| --- | --- |
| server.properties | Port, motd, difficulty, max players |
| world/ | Default world (name comes from level-name in server.properties) |
| world/datapacks/ | Datapacks (Java Edition) |
| mods/ | Mod jars for Fabric, Forge, or NeoForge |
| config/ | Mod loader configuration |

Edit server.properties while the server is stopped. Some settings can be reloaded in-game with /reload, but not all.

## Datapacks

Datapacks depend on the game version. For vanilla:

1. Download or build a datapack zip.
2. Put it in minecraft/vanilla/data/world/datapacks/ (create folders if needed).
3. Restart the server, or run /reload if the pack supports it.

For a new world, set level-name in server.properties before the first start, or add datapacks before the world folder is created.

Fabric and Forge use the same world/datapacks/ layout. Some mods add rules that datapacks rely on.

## Mods (Fabric, Forge, and NeoForge)

1. Match mod jars to your loader version.
2. Drop jar files into minecraft/<flavor>/data/mods/.
3. Restart the server and check logs/latest.log for loader errors.

Fabric downloads the server launcher on first start. Forge and NeoForge run the official installer into /data. After changing loader versions, set FORGE_FORCE_INSTALL or NEOFORGE_FORCE_INSTALL to true once so binaries match your mods.

Client-only mods do not belong on the dedicated server. Use server or universal artifacts from the mod author.

## Compose (pinned defaults)

```bash
docker compose -f minecraft/fabric/docker-compose.yml up
```

Replace fabric with vanilla, forge, or neoforge as needed.

## Compose (pick your own version)

Use docker-compose.scaffold.yml when you want versions in a local .env file instead of only the repo defaults.

```bash
cd minecraft/fabric
cp .env.example .env
# edit .env, then:
docker compose -f docker-compose.scaffold.yml up
```

Scaffold compose loads minecraft/defaults.env, an optional .env in the flavor folder, and explicit environment entries so your overrides win. You can also pass the defaults file on the command line:

```bash
docker compose -f minecraft/vanilla/docker-compose.scaffold.yml \
  --env-file minecraft/defaults.env up
```

The same pattern works under minecraft/vanilla, minecraft/forge, and minecraft/neoforge with their .env.example files.

## Docker run

Pass version settings with -e (image defaults apply when omitted). Set EULA=true and mount your data folder.

Fabric:

```bash
docker run -d --name fabric --restart unless-stopped --init \
  -p 25565:25565/tcp \
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
  -p 25565:25565/tcp \
  -v "$PWD/minecraft/vanilla/data:/data" \
  -e EULA=true \
  -e VANILLA_VERSION=26.2 \
  {{IMAGE_PREFIX}}/minecraft-vanilla:latest
```

Forge:

```bash
docker run -d --name forge --restart unless-stopped --init \
  -p 25565:25565/tcp \
  -v "$PWD/minecraft/forge/data:/data" \
  -e EULA=true \
  -e FORGE_MINECRAFT_VERSION=26.2 \
  -e FORGE_VERSION=65.0.9 \
  {{IMAGE_PREFIX}}/minecraft-forge:latest
```

NeoForge:

```bash
docker run -d --name neoforge --restart unless-stopped --init \
  -p 25565:25565/tcp \
  -v "$PWD/minecraft/neoforge/data:/data" \
  -e EULA=true \
  -e NEOFORGE_VERSION=26.2.0.35-beta \
  {{IMAGE_PREFIX}}/minecraft-neoforge:latest
```

Optional URL overrides (hosts are restricted for safety): VANILLA_JAR_URL (Mojang only), FORGE_INSTALLER_URL (Maven Forge only), NEOFORGE_INSTALLER_URL (maven.neoforged.net only).

## Health check

The health script checks that something is listening on SERVER_PORT (default 25565). If you change server-port in server.properties and remap ports in compose, set SERVER_PORT to match.

## Versioned image builds

The manual build-minecraft workflow can publish tags for a chosen Minecraft version. See [CI](/reference/ci/).

## See also

- [All servers](/reference/servers/) for compose paths and image names
- [Images](/reference/images/) for the shared minecraft-base image
- [Ops](/guides/ops/) for backup, restore, and update with ./tools/gs
