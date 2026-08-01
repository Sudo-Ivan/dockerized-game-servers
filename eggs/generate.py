#!/usr/bin/env python3
"""Generate Pterodactyl PTDL_v2 eggs from ci/server-catalog.sh and compose files."""

from __future__ import annotations

import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EGGS_DIR = Path(__file__).resolve().parent
CATALOG = ROOT / "ci" / "server-catalog.sh"

AUTHOR = "sudo-ivan@users.noreply.github.com"
DEFAULT_IMAGE_PREFIX = "ghcr.io/sudo-ivan/dockerized-game-servers"

INSTALL_SCRIPT = """#!/bin/bash
# Server files: /mnt/server
set -e
mkdir -p /mnt/server
cd /mnt/server
echo "Install complete. Game files download on first container start."
"""

IMAGE_SLUG: dict[str, str] = {
    "fabric": "minecraft-fabric",
    "vanilla": "minecraft-vanilla",
    "forge": "minecraft-forge",
    "neoforge": "minecraft-neoforge",
}

EGG_FOLDERS: dict[str, str] = {
    "fabric": "minecraft",
    "vanilla": "minecraft",
    "forge": "minecraft",
    "neoforge": "minecraft",
    "valheim": "valheim",
    "valheim-plus": "valheim",
    "tf2": "source",
    "cs2": "source",
    "cs-source": "source",
    "l4d2": "source",
    "gmod": "source",
    "dod-source": "source",
    "kf2": "source",
    "cod": "call-of-duty",
    "cod2": "call-of-duty",
    "cod4": "call-of-duty",
    "codwaw": "call-of-duty",
    "bf1942": "battlefield",
    "bfv": "battlefield",
    "arma-3": "arma",
    "arma-reforger": "arma",
    "insurgency-source": "insurgency",
    "insurgency-sandstorm": "insurgency",
    "7-days-to-die": "survival",
    "project-zomboid": "survival",
    "the-forest": "survival",
    "sons-of-the-forest": "survival",
    "dayz": "survival",
    "icarus": "survival",
    "terraria": "sandbox",
    "starbound": "sandbox",
    "eco": "sandbox",
    "factorio": "sandbox",
    "palworld": "sandbox",
    "barotrauma": "sandbox",
    "core-keeper": "sandbox",
    "space-engineers": "sandbox",
    "ground-branch": "sandbox",
    "longvinter": "sandbox",
    "unturned": "sandbox",
    "quake3": "classic",
    "rtcw": "classic",
    "etl": "classic",
    "openmohaa": "classic",
    "delta-force-bhd": "classic",
    "supertuxkart": "classic",
    "sniper-elite-4": "classic",
    "hytale": "external",
    "stardew-valley": "external",
    "azerothcore": "external",
}

SIGINT_GAMES = {
    "cs2",
    "gmod",
    "tf2",
    "l4d2",
    "dod-source",
    "cs-source",
    "insurgency-source",
    "project-zomboid",
}

STEAM_GAMES = {
    "valheim",
    "valheim-plus",
    "ground-branch",
    "space-engineers",
    "core-keeper",
    "7-days-to-die",
    "project-zomboid",
    "terraria",
    "l4d2",
    "insurgency-source",
    "insurgency-sandstorm",
    "cs-source",
    "kf2",
    "icarus",
    "the-forest",
    "sons-of-the-forest",
    "sniper-elite-4",
    "etl",
    "eco",
    "palworld",
    "starbound",
    "longvinter",
    "barotrauma",
    "unturned",
    "tf2",
    "cs2",
    "dod-source",
    "gmod",
    "openmohaa",
    "arma-3",
    "arma-reforger",
    "dayz",
}

DONE_STRINGS: dict[str, str] = {
    "fabric": ")! For help, type ",
    "vanilla": ")! For help, type ",
    "forge": ")! For help, type ",
    "neoforge": ")! For help, type ",
    "valheim": "Starting Valheim server",
    "valheim-plus": "Starting Valheim Plus server",
    "core-keeper": "Starting Core Keeper server",
}

DISPLAY_NAMES: dict[str, str] = {
    "fabric": "Minecraft Fabric",
    "vanilla": "Minecraft Vanilla",
    "forge": "Minecraft Forge",
    "neoforge": "Minecraft NeoForge",
    "valheim": "Valheim",
    "valheim-plus": "Valheim Plus",
    "ground-branch": "Ground Branch",
    "space-engineers": "Space Engineers",
    "core-keeper": "Core Keeper",
    "7-days-to-die": "7 Days to Die",
    "project-zomboid": "Project Zomboid",
    "l4d2": "Left 4 Dead 2",
    "insurgency-source": "Insurgency (Source)",
    "insurgency-sandstorm": "Insurgency: Sandstorm",
    "cs-source": "Counter-Strike: Source",
    "kf2": "Killing Floor 2",
    "the-forest": "The Forest",
    "sons-of-the-forest": "Sons Of The Forest",
    "sniper-elite-4": "Sniper Elite 4",
    "supertuxkart": "SuperTuxKart",
    "bf1942": "Battlefield 1942",
    "bfv": "Battlefield Vietnam",
    "cod": "Call of Duty",
    "cod2": "Call of Duty 2",
    "codwaw": "Call of Duty: World at War",
    "cod4": "Call of Duty 4",
    "quake3": "Quake III Arena",
    "rtcw": "Return to Castle Wolfenstein",
    "etl": "ET: Legacy",
    "palworld": "Palworld",
    "longvinter": "Longvinter",
    "barotrauma": "Barotrauma",
    "tf2": "Team Fortress 2",
    "cs2": "Counter-Strike 2",
    "dod-source": "Day of Defeat: Source",
    "gmod": "Garry's Mod",
    "delta-force-bhd": "Delta Force: Black Hawk Down",
    "openmohaa": "OpenMoHAA",
    "arma-3": "Arma 3",
    "arma-reforger": "Arma Reforger",
    "dayz": "DayZ",
    "hytale": "Hytale",
    "stardew-valley": "Stardew Valley",
    "azerothcore": "AzerothCore WotLK",
}

DATA_ENV: dict[str, list[tuple[str, str]]] = {
    "valheim": [("VALHEIM_DIR", "")],
    "valheim-plus": [("VALHEIM_DIR", "")],
    "ground-branch": [("GB_INSTALL_DIR", "")],
    "factorio": [("FACTORIO_DIR", "")],
    "7-days-to-die": [("SEVENDTD_DIR", "")],
    "project-zomboid": [("PZ_INSTALL_DIR", "server")],
    "terraria": [("TERRARIA_DIR", "")],
    "l4d2": [("L4D2_DIR", "")],
    "insurgency-source": [("INS_SOURCE_DIR", "")],
    "insurgency-sandstorm": [("INS_SANDSTORM_DIR", "")],
    "cs-source": [("CSS_DIR", "")],
    "kf2": [("KF2_DIR", "")],
    "icarus": [("ICARUS_DIR", "")],
    "the-forest": [("FOREST_DIR", "")],
    "sons-of-the-forest": [("SOTF_DIR", "")],
    "sniper-elite-4": [("SE4_DIR", "")],
    "supertuxkart": [("STK_DATA_DIR", "")],
    "bf1942": [("BF1942_DIR", "")],
    "bfv": [("BFV_DIR", "")],
    "cod": [("COD_DIR", "")],
    "cod2": [("COD2_DIR", "")],
    "codwaw": [("CODWAW_DIR", "")],
    "cod4": [("COD4_DIR", "")],
    "quake3": [("Q3_DIR", "")],
    "rtcw": [("RTCW_DIR", "")],
    "etl": [("ETL_DIR", "")],
    "eco": [("ECO_DIR", "")],
    "palworld": [("PALWORLD_DIR", "")],
    "starbound": [("STARBOUND_DIR", "")],
    "longvinter": [("LONGVINTER_DIR", "")],
    "barotrauma": [("BAROTRAUMA_DIR", "")],
    "unturned": [("UNTURNED_DIR", "")],
    "tf2": [("TF2_DIR", "")],
    "cs2": [("CS2_DIR", "")],
    "dod-source": [("DOD_DIR", "")],
    "gmod": [("GMOD_DIR", "")],
    "delta-force-bhd": [("BHD_DIR", "")],
    "openmohaa": [
        ("MOHAA_INSTALL_DIR", "install"),
        ("MOHAA_DATA_DIR", "data"),
    ],
    "arma-reforger": [("ARMAR_DIR", "")],
    "dayz": [("DAYZ_DIR", "")],
    "core-keeper": [
        ("CK_INSTALL_DIR", "server"),
        ("CK_DATA_DIR", "data"),
    ],
    "space-engineers": [
        ("SE_ROOT", ""),
        ("SE_DEDICATED_DIR", "dedicated"),
        ("SE_INSTANCES_DIR", "instances"),
        ("SE_PLUGINS_DIR", "plugins"),
    ],
}

SKIP_ENV = {
    "STEAM_USERNAME",
    "STEAM_PASSWORD",
    "STEAM_GUARD_CODE",
    "TZ",
    "PUID",
    "PGID",
    "HOME",
    "PATH",
    "USER",
    "JAVA_HOME",
    "WINEPREFIX",
    "WINEARCH",
    "WINEDEBUG",
    "SteamAppId",
    "LD_LIBRARY_PATH",
}

STEAM_ENV_VARS = [
    {
        "name": "Steam Username",
        "description": "Steam account for dedicated server installs. Use anonymous unless the game requires a login.",
        "env_variable": "STEAM_USERNAME",
        "default_value": "anonymous",
        "user_viewable": True,
        "user_editable": True,
        "rules": "required|string|max:64",
        "field_type": "text",
    },
    {
        "name": "Steam Password",
        "description": "Steam password when not using anonymous login.",
        "env_variable": "STEAM_PASSWORD",
        "default_value": "",
        "user_viewable": True,
        "user_editable": True,
        "rules": "nullable|string|max:64",
        "field_type": "text",
    },
    {
        "name": "Steam Guard Code",
        "description": "One-time Steam Guard code for SteamCMD login.",
        "env_variable": "STEAM_GUARD_CODE",
        "default_value": "",
        "user_viewable": True,
        "user_editable": True,
        "rules": "nullable|string|max:32",
        "field_type": "text",
    },
]

MINECRAFT_EULA_VAR = {
    "name": "Accept EULA",
    "description": "Must be true to run the Minecraft server.",
    "env_variable": "EULA",
    "default_value": "true",
    "user_viewable": True,
    "user_editable": True,
    "rules": "required|boolean",
    "field_type": "text",
}


def slugify(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


def parse_catalog() -> list[dict[str, str]]:
    out = subprocess.check_output([str(CATALOG)], text=True)
    rows: list[dict[str, str]] = []
    for line in out.splitlines():
        parts = line.split("\t")
        if len(parts) != 7:
            continue
        rows.append(
            {
                "id": parts[0],
                "compose": parts[1],
                "container": parts[2],
                "volumes": parts[3],
                "update_envs": parts[4],
                "health": parts[5],
                "first_party": parts[6],
            }
        )
    return rows


def read_compose(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def parse_image(game_id: str, compose_text: str, image_prefix: str) -> str:
    if game_id == "azerothcore":
        return "acore/ac-wotlk-worldserver:master"
    if game_id == "stardew-valley":
        return "sdvd/server:latest"
    if game_id == "hytale":
        return "deinfreu/hytale-server:latest"

    owner_match = re.search(
        r"image:\s*ghcr\.io/\$\{IMAGE_OWNER\}/([^:\s\"']+)",
        compose_text,
    )
    if owner_match:
        return f"{image_prefix}/{owner_match.group(1)}:latest"

    match = re.search(r"^\s*image:\s*(.+)$", compose_text, re.MULTILINE)
    if not match:
        raise ValueError("no image line in compose")
    raw = match.group(1).strip().strip('"').strip("'")
    tag_match = re.search(r":([^:\s\"']+)$", raw)
    tag = tag_match.group(1) if tag_match else "latest"
    base = raw[: -len(f":{tag}")] if tag_match else raw
    if "${" in base:
        slug = IMAGE_SLUG.get(game_id, game_id)
        return f"{image_prefix}/{slug}:{tag}"
    return raw


def parse_ports(compose_text: str) -> list[dict[str, str]]:
    ports: list[dict[str, str]] = []
    in_ports = False
    for line in compose_text.splitlines():
        stripped = line.strip()
        if stripped.startswith("ports:"):
            in_ports = True
            continue
        if in_ports:
            if not stripped.startswith("- "):
                if ports:
                    break
                continue
            entry = stripped[2:].strip().strip('"').strip("'")
            if entry.startswith("#"):
                continue
            host, rest = entry.split(":", 1)
            container_part, proto = (rest.rsplit("/", 1) + ["tcp"])[:2]
            ports.append(
                {
                    "host": host,
                    "container": container_part,
                    "protocol": proto,
                }
            )
    return ports


def parse_environment(compose_text: str) -> list[tuple[str, str]]:
    envs: list[tuple[str, str]] = []
    in_env = False
    for line in compose_text.splitlines():
        stripped = line.strip()
        if stripped == "environment:":
            in_env = True
            continue
        if in_env:
            if not stripped or stripped.startswith("#"):
                continue
            if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*:", stripped):
                if envs:
                    break
                continue
            key, value = stripped.split(":", 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            value = re.sub(r"\$\{([^}:]+)(?::-([^}]*))?\}", r"\2", value)
            if key in SKIP_ENV:
                continue
            if key.endswith("_APP_ID") or key.endswith("_STEAMWORKS_APP_ID"):
                continue
            envs.append((key, value))
    return envs


def ptero_path(sub: str) -> str:
    if not sub:
        return "/home/container"
    return f"/home/container/{sub}"


def build_data_exports(game_id: str) -> str:
    pairs = DATA_ENV.get(game_id, [])
    if not pairs:
        return ""
    parts = [f"{key}={ptero_path(sub)}" for key, sub in pairs]
    return "export " + " ".join(parts)


def minecraft_startup() -> str:
    return (
        "/bin/sh -c 'rm -rf /data 2>/dev/null; ln -sfn /home/container /data; exec /entrypoint.sh'"
    )


def docker_entrypoint_startup(game_id: str) -> str:
    exports = build_data_exports(game_id)
    if game_id == "arma-3":
        body = (
            "mkdir -p /home/arma3; "
            "for d in server configs profiles cache; do "
            "mkdir -p /home/container/$d; "
            "ln -sfn /home/container/$d /home/arma3/$d; "
            "done; "
            "export ARMA_DIR=/home/arma3/server; "
            "exec /docker-entrypoint.sh"
        )
        return f"/bin/bash -c '{body}'"
    if exports:
        return f"/bin/bash -c '{exports}; exec /docker-entrypoint.sh'"
    return "/docker-entrypoint.sh"


def hytale_startup() -> str:
    return "/bin/bash -c 'cd /home/container && exec /start.sh'"


def stardew_startup() -> str:
    body = (
        "mkdir -p /home/container/game /home/container/saves /home/container/settings "
        "/config/xdg/config/StardewValley; "
        "ln -sfn /home/container/saves /config/xdg/config/StardewValley; "
        "export SETTINGS_PATH=/home/container/settings/server-settings.json; "
        "exec /start.sh"
    )
    return f"/bin/bash -c '{body}'"


def azerothcore_startup() -> str:
    body = (
        "mkdir -p /home/container/data /home/container/logs /home/container/etc; "
        "ln -sfn /home/container/data /azerothcore/env/dist/data; "
        "ln -sfn /home/container/logs /azerothcore/env/dist/logs; "
        "ln -sfn /home/container/etc /azerothcore/env/dist/etc; "
        "exec ./bin/worldserver"
    )
    return f"/bin/bash -c '{body}'"


def pick_startup(game_id: str, first_party: bool) -> str:
    if game_id in {"fabric", "vanilla", "forge", "neoforge"}:
        return minecraft_startup()
    if game_id == "hytale":
        return hytale_startup()
    if game_id == "stardew-valley":
        return stardew_startup()
    if game_id == "azerothcore":
        return azerothcore_startup()
    if first_party == "1":
        return docker_entrypoint_startup(game_id)
    return "/docker-entrypoint.sh"


def pick_stop(game_id: str) -> str:
    if game_id in {"fabric", "vanilla", "forge", "neoforge"}:
        return "stop"
    if game_id in SIGINT_GAMES:
        return "^C"
    return "^C"


def pick_done(game_id: str) -> str:
    if game_id in DONE_STRINGS:
        return DONE_STRINGS[game_id]
    if game_id.startswith("minecraft") or game_id in {"fabric", "vanilla", "forge", "neoforge"}:
        return ")! For help, type "
    return "Starting"


def pick_features(game_id: str) -> list[str] | None:
    if game_id in {"fabric", "vanilla", "forge", "neoforge"}:
        return ["eula", "java_version"]
    return None


def env_to_variable(name: str, key: str, default: str) -> dict:
    rules = "nullable|string|max:512"
    if default.lower() in {"true", "false"}:
        rules = "nullable|boolean"
    elif re.fullmatch(r"-?\d+", default or ""):
        rules = "nullable|integer|between:0,65535"
    elif default == "":
        rules = "nullable|string|max:512"
    else:
        rules = "required|string|max:512"
    return {
        "name": name,
        "description": f"Container environment {key}.",
        "env_variable": key,
        "default_value": default,
        "user_viewable": True,
        "user_editable": True,
        "rules": rules,
        "field_type": "text",
    }


def build_variables(game_id: str, compose_env: list[tuple[str, str]], first_party: str) -> list[dict]:
    variables: list[dict] = []
    seen: set[str] = set()

    if game_id in {"fabric", "vanilla", "forge", "neoforge"}:
        variables.append(MINECRAFT_EULA_VAR)
        seen.add("EULA")

    if game_id in STEAM_GAMES:
        for var in STEAM_ENV_VARS:
            if var["env_variable"] not in seen:
                variables.append(var)
                seen.add(var["env_variable"])

    for key, default in compose_env:
        if key in seen:
            continue
        if key.endswith("_FORCE_UPDATE") or key.endswith("_FORCE_DOWNLOAD") or key.endswith("_FORCE_INSTALL"):
            variables.append(
                {
                    "name": human_key(key),
                    "description": "Set true on reinstall to force a fresh download or update.",
                    "env_variable": key,
                    "default_value": default or "false",
                    "user_viewable": True,
                    "user_editable": True,
                    "rules": "required|boolean",
                    "field_type": "text",
                }
            )
            seen.add(key)
            continue
        variables.append(env_to_variable(human_key(key), key, default))
        seen.add(key)

    if game_id == "stardew-valley":
        variables.append(
            {
                "name": "Steam Auth URL",
                "description": "URL of the sdvd/steam-service sidecar (required for JunimoServer).",
                "env_variable": "STEAM_AUTH_URL",
                "default_value": "http://steam-auth:3001",
                "user_viewable": True,
                "user_editable": True,
                "rules": "required|string|max:191",
                "field_type": "text",
            }
        )

    if game_id == "azerothcore":
        variables.append(
            {
                "name": "Database Root Password",
                "description": "MariaDB root password used in AC_*_DATABASE_INFO strings.",
                "env_variable": "ACORE_DB_ROOT_PASSWORD",
                "default_value": "acore",
                "user_viewable": True,
                "user_editable": True,
                "rules": "required|string|max:64",
                "field_type": "text",
            }
        )

    return variables


def human_key(key: str) -> str:
    return key.replace("_", " ").title()


def build_description(game_id: str, image: str, ports: list[dict[str, str]], first_party: str) -> str:
    name = DISPLAY_NAMES.get(game_id, game_id.replace("-", " ").title())
    lines = [
        f"{name} using the dockerized-game-servers image.",
        f"Docker image: {image}.",
        "Persistent data is stored under /home/container (mapped from the image data directory on startup).",
    ]
    if ports:
        port_text = ", ".join(
            f"{p['container']}/{p['protocol']}" for p in ports[:6]
        )
        lines.append(f"Default ports: {port_text}")
    if game_id == "stardew-valley":
        lines.append(
            "Requires a separate sdvd/steam-service container for Steam authentication."
        )
    if game_id == "azerothcore":
        lines.append(
            "This egg runs only the worldserver binary. MariaDB, db-import, and client-data init are still required."
        )
    if game_id == "arma-3":
        lines.append(
            "Place modlist.html in server/modlist.html under the server data directory for workshop mod sync."
        )
    if first_party == "0":
        lines.append("External image maintained outside this repository.")
    return " ".join(lines)


def build_egg(row: dict[str, str], image_prefix: str) -> dict:
    game_id = row["id"]
    compose_path = ROOT / row["compose"]
    compose_text = read_compose(compose_path)
    image = parse_image(game_id, compose_text, image_prefix)
    ports = parse_ports(compose_text)
    compose_env = parse_environment(compose_text)
    name = DISPLAY_NAMES.get(game_id, game_id.replace("-", " ").title())

    egg = {
        "_comment": "Pterodactyl egg for dockerized-game-servers",
        "meta": {
            "version": "PTDL_v2",
            "update_url": None,
        },
        "exported_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
        "name": name,
        "author": AUTHOR,
        "description": build_description(game_id, image, ports, row["first_party"]),
        "features": pick_features(game_id),
        "docker_images": {"Latest": image},
        "file_denylist": [],
        "startup": pick_startup(game_id, row["first_party"]),
        "config": {
            "files": "{}",
            "startup": json.dumps({"done": pick_done(game_id)}),
            "logs": "{}",
            "stop": pick_stop(game_id),
        },
        "scripts": {
            "installation": {
                "script": INSTALL_SCRIPT,
                "container": "ghcr.io/pterodactyl/installers:alpine",
                "entrypoint": "ash",
            }
        },
        "variables": build_variables(game_id, compose_env, row["first_party"]),
    }
    return egg


def validate_egg(egg: dict) -> list[str]:
    errors: list[str] = []
    if egg.get("meta", {}).get("version") != "PTDL_v2":
        errors.append("meta.version must be PTDL_v2")
    if not egg.get("name"):
        errors.append("name required")
    if "@" not in egg.get("author", ""):
        errors.append("author must be email")
    if not egg.get("startup"):
        errors.append("startup required")
    images = egg.get("docker_images")
    if not isinstance(images, dict) or not images:
        errors.append("docker_images required")
    config = egg.get("config", {})
    if not isinstance(config.get("stop"), str):
        errors.append("config.stop required")
    for key in ("files", "startup", "logs"):
        val = config.get(key)
        if not isinstance(val, str):
            errors.append(f"config.{key} must be string")
        elif key != "stop":
            try:
                json.loads(val)
            except json.JSONDecodeError:
                errors.append(f"config.{key} must be valid JSON string")
    return errors


def egg_folder(game_id: str) -> str:
    return EGG_FOLDERS.get(game_id, "other")


def egg_json_paths() -> set[str]:
    paths: set[str] = set()
    for path in EGGS_DIR.rglob("*.json"):
        if path.name == "nest.json":
            continue
        paths.add(path.relative_to(EGGS_DIR).as_posix())
    return paths


def main() -> int:
    image_prefix = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_IMAGE_PREFIX
    rows = parse_catalog()
    existing = egg_json_paths()
    generated: list[str] = []

    for row in rows:
        egg = build_egg(row, image_prefix)
        errors = validate_egg(egg)
        if errors:
            print(f"validation failed for {row['id']}: {errors}", file=sys.stderr)
            return 1
        folder = egg_folder(row["id"])
        filename = f"{slugify(row['id'])}.json"
        rel_path = f"{folder}/{filename}"
        path = EGGS_DIR / folder / filename
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(egg, indent=2) + "\n", encoding="utf-8")
        generated.append(rel_path)

    nest = {
        "_comment": "Import eggs from eggs/<folder>/*.json via Admin > Nests > Import Egg",
        "name": "Dockerized Game Servers",
        "description": "Dedicated servers from the dockerized-game-servers project (GHCR images).",
        "author": AUTHOR,
        "eggs": generated,
    }
    (EGGS_DIR / "nest.json").write_text(json.dumps(nest, indent=2) + "\n", encoding="utf-8")

    stale = sorted(existing - set(generated))
    for rel_path in stale:
        (EGGS_DIR / rel_path).unlink()
    if stale:
        print(f"removed stale egg files: {', '.join(stale)}", file=sys.stderr)

    for path in sorted(EGGS_DIR.rglob("*"), key=lambda p: len(p.parts), reverse=True):
        if path.is_dir() and path != EGGS_DIR and not any(path.iterdir()):
            path.rmdir()

    verify_errors: list[str] = []
    for rel_path in generated:
        path = EGGS_DIR / rel_path
        try:
            egg = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            verify_errors.append(f"{rel_path}: invalid JSON: {exc}")
            continue
        file_errors = validate_egg(egg)
        if file_errors:
            verify_errors.append(f"{rel_path}: {file_errors}")

    if verify_errors:
        for msg in verify_errors:
            print(msg, file=sys.stderr)
        return 1

    print(f"generated {len(generated)} eggs under {EGGS_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
