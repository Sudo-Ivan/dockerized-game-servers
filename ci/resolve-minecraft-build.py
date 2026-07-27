#!/usr/bin/env python3
"""Resolve Minecraft flavor versions and matching Temurin Alpine JRE build args."""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.parse
import urllib.request


MOJANG_MANIFEST = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
FABRIC_LOADER = "https://meta.fabricmc.net/v2/versions/loader/{version}"
FABRIC_INSTALLER = "https://meta.fabricmc.net/v2/versions/installer"
FORGE_PROMOS = "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json"
NEOFORGE_VERSIONS = "https://maven.neoforged.net/api/maven/versions/releases/net/neoforged/neoforge"
ADOPTIUM_LATEST = (
    "https://api.adoptium.net/v3/assets/latest/{major}/hotspot"
    "?os=alpine-linux&architecture=x64&image_type=jre"
)


def http_json(url: str):
    req = urllib.request.Request(url, headers={"User-Agent": "dockerized-game-servers-resolver"})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.load(resp)


def resolve_java_major(minecraft_version: str, override: str | None) -> int:
    if override:
        return int(override)

    manifest = http_json(MOJANG_MANIFEST)
    version_url = next(
        (item["url"] for item in manifest.get("versions", []) if item.get("id") == minecraft_version),
        None,
    )
    if not version_url:
        raise SystemExit(f"Minecraft version not found in Mojang manifest: {minecraft_version}")

    version_json = http_json(version_url)
    java_version = version_json.get("javaVersion") or {}
    major = java_version.get("majorVersion")
    if not major:
        raise SystemExit(f"No javaVersion.majorVersion for Minecraft {minecraft_version}")
    return int(major)


def resolve_temurin(major: int) -> tuple[str, str, str]:
    assets = http_json(ADOPTIUM_LATEST.format(major=major))
    if not assets:
        raise SystemExit(f"No Adoptium Alpine JRE assets for Java {major}")

    package = assets[0]["binary"]["package"]
    link = package["link"]
    parts = link.rstrip("/").split("/")
    # Keep unencoded for Actions outputs. Dockerfile encodes '+' for the GitHub path.
    release_tag = urllib.parse.unquote(parts[-2])
    filename = parts[-1]
    marker = "hotspot_"
    if marker not in filename or not filename.endswith(".tar.gz"):
        raise SystemExit(f"Unexpected Temurin filename: {filename}")
    temurin_version = filename.split(marker, 1)[1][: -len(".tar.gz")]
    return str(major), temurin_version, release_tag


def resolve_fabric(minecraft_version: str, loader: str | None, installer: str | None) -> tuple[str, str]:
    if not loader:
        loaders = http_json(FABRIC_LOADER.format(version=urllib.parse.quote(minecraft_version, safe="")))
        if not loaders:
            raise SystemExit(f"No Fabric loader versions for Minecraft {minecraft_version}")
        stable = next((item for item in loaders if item.get("loader", {}).get("stable")), None)
        chosen = stable or loaders[0]
        loader = chosen["loader"]["version"]

    if not installer:
        installers = http_json(FABRIC_INSTALLER)
        if not installers:
            raise SystemExit("No Fabric installer versions returned")
        stable = next((item for item in installers if item.get("stable")), None)
        chosen = stable or installers[0]
        installer = chosen["version"]

    return loader, installer


def resolve_forge(minecraft_version: str, forge_version: str | None, channel: str) -> str:
    if forge_version:
        return forge_version

    promos = http_json(FORGE_PROMOS).get("promos", {})
    key = f"{minecraft_version}-{channel}"
    if key not in promos:
        latest_key = f"{minecraft_version}-latest"
        recommended_key = f"{minecraft_version}-recommended"
        available = [k for k in (recommended_key, latest_key) if k in promos]
        raise SystemExit(
            f"No Forge promo for {key}. Tried channel={channel}. "
            f"Available keys for version: {[k for k in promos if k.startswith(minecraft_version + '-')] or available or 'none'}"
        )
    return str(promos[key])


def neoforge_version_prefix(minecraft_version: str) -> str:
    parts = minecraft_version.split(".")
    if len(parts) >= 3 and parts[0] == "1":
        return f"{parts[1]}.{parts[2]}."
    return f"{minecraft_version}."


def resolve_neoforge(minecraft_version: str, neoforge_version: str | None) -> str:
    if neoforge_version:
        return neoforge_version

    prefix = neoforge_version_prefix(minecraft_version)
    versions = http_json(NEOFORGE_VERSIONS).get("versions", [])
    candidates = [v for v in versions if v.startswith(prefix)]
    if not candidates:
        raise SystemExit(
            f"No NeoForge versions with prefix {prefix!r} for Minecraft {minecraft_version}. "
            "Set --neoforge-version explicitly. See https://neoforged.net/"
        )

    stable = [v for v in candidates if "beta" not in v and "alpha" not in v]
    pool = stable if stable else candidates
    return str(pool[-1])


def derive_tag(flavor: str, minecraft_version: str, forge_version: str | None, neoforge_version: str | None, tag: str | None) -> str:
    if tag:
        return tag
    if flavor == "forge":
        return f"{minecraft_version}-{forge_version}"
    if flavor == "neoforge":
        return f"{minecraft_version}-{neoforge_version}"
    return minecraft_version


def emit(out, key: str, value: str) -> None:
    line = f"{key}={value}"
    print(line)
    if out is not None:
        # Delimiter form is safe for '+', '%', and newlines.
        delimiter = f"EOF_{key}"
        out.write(f"{key}<<{delimiter}\n{value}\n{delimiter}\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--flavor", required=True, choices=("fabric", "vanilla", "forge", "neoforge"))
    parser.add_argument("--minecraft-version", required=True)
    parser.add_argument("--fabric-loader-version", default="")
    parser.add_argument("--fabric-installer-version", default="")
    parser.add_argument("--forge-version", default="")
    parser.add_argument("--forge-channel", default="recommended", choices=("recommended", "latest"))
    parser.add_argument("--neoforge-version", default="")
    parser.add_argument("--java-major", default="")
    parser.add_argument("--tag", default="")
    parser.add_argument("--github-output", default="")
    args = parser.parse_args()

    mc = args.minecraft_version.strip()
    if not mc:
        raise SystemExit("minecraft-version is required")

    java_major = resolve_java_major(mc, args.java_major.strip() or None)
    temurin_major, temurin_version, temurin_release = resolve_temurin(java_major)

    fabric_loader = ""
    fabric_installer = ""
    forge_version = ""
    neoforge_version = ""

    if args.flavor == "fabric":
        fabric_loader, fabric_installer = resolve_fabric(
            mc,
            args.fabric_loader_version.strip() or None,
            args.fabric_installer_version.strip() or None,
        )
        image_name = "minecraft-fabric"
    elif args.flavor == "vanilla":
        image_name = "minecraft-vanilla"
    elif args.flavor == "forge":
        forge_version = resolve_forge(
            mc,
            args.forge_version.strip() or None,
            args.forge_channel,
        )
        image_name = "minecraft-forge"
    else:
        neoforge_version = resolve_neoforge(mc, args.neoforge_version.strip() or None)
        image_name = "minecraft-neoforge"

    image_tag = derive_tag(
        args.flavor,
        mc,
        forge_version or None,
        neoforge_version or None,
        args.tag.strip() or None,
    )
    base_tag = f"java{java_major}"

    gh_out = open(args.github_output, "a", encoding="utf-8") if args.github_output else None
    try:
        emit(gh_out, "FLAVOR", args.flavor)
        emit(gh_out, "MINECRAFT_VERSION", mc)
        emit(gh_out, "JAVA_MAJOR", str(java_major))
        emit(gh_out, "TEMURIN_MAJOR", temurin_major)
        emit(gh_out, "TEMURIN_VERSION", temurin_version)
        emit(gh_out, "TEMURIN_RELEASE", temurin_release)
        emit(gh_out, "FABRIC_LOADER_VERSION", fabric_loader)
        emit(gh_out, "FABRIC_INSTALLER_VERSION", fabric_installer)
        emit(gh_out, "FORGE_VERSION", forge_version)
        emit(gh_out, "NEOFORGE_VERSION", neoforge_version)
        emit(gh_out, "IMAGE_NAME", image_name)
        emit(gh_out, "IMAGE_TAG", image_tag)
        emit(gh_out, "BASE_TAG", base_tag)
        emit(gh_out, "BASE_IMAGE_NAME", "minecraft-base")
    finally:
        if gh_out is not None:
            gh_out.close()

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except urllib.error.URLError as exc:
        print(f"HTTP error: {exc}", file=sys.stderr)
        raise SystemExit(1)
