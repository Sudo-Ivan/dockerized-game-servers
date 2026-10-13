#!/usr/bin/env python3
"""Fetch game art for server pages and sync the game_icon front matter.

Resolution order per page in docs/servers:

1. front matter iconUrl or steamAppId
2. Steam app IDs found in the page's compose and entrypoint files
3. Steam store search by page title (exact name match)
4. Wikipedia page thumbnail by title (with a few aliases)

Icons are written to docs/game-icons/ and the front matter of each page is
updated so that game_icon points at the downloaded file. Pages without a
resolvable icon get the field removed and render without the banner.

Stdlib only. Run before zensical build (see ci/test-docs.sh).
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SERVERS_DIR = ROOT / "docs" / "servers"
ICONS_DIR = ROOT / "docs" / "game-icons"
PODERIZED_DIR = ROOT / "poderized"

UA = "poderized-game-servers-docs/1.0 (+https://github.com/Sudo-Ivan/poderized-game-servers)"

STEAM_CDN = "https://cdn.cloudflare.steamstatic.com/steam/apps"
STEAM_ASSETS = ["library_600x900.jpg", "capsule_sm_120.jpg", "header.jpg", "capsule_231x87.jpg"]

# App IDs that are redistributables or tooling, never game art.
SKIP_APP_IDS = {"1007"}

# Wikipedia titles when the docs title is not a useful page name.
WIKI_TITLE_ALIASES = {
    "openmohaa": "Medal of Honor: Allied Assault",
    "l4d2": "Left 4 Dead 2",
    "7-days-to-die": "7 Days to Die",
    "arma-3": "Arma 3",
    "cs-source": "Counter-Strike: Source",
    "kf2": "Killing Floor 2",
    "insurgency-source": "Insurgency (2014 video game)",
    "insurgency-sandstorm": "Insurgency: Sandstorm",
    "ground-branch": "Ground Branch",
    "core-keeper": "Core Keeper",
    "project-zomboid": "Project Zomboid",
    "stardew-valley": "Stardew Valley",
    "azerothcore": "World of Warcraft: Wrath of the Lich King",
    "space-engineers": "Space Engineers",
}

# Direct icon URLs when Steam and Wikipedia have nothing usable.
DIRECT_ICON_URLS = {
    "minecraft": "https://minecraft.wiki/images/Grass_Block_JE7_BE6.png",
    "factorio": "https://wiki.factorio.com/images/thumb/6/60/Factorio-logo.png/240px-Factorio-logo.png",
    "vintage-story": "https://wiki.vintagestory.at/images/Vintagestory-icon.png",
}

# Icons that should use contain plus a square frame instead of a portrait crop.
ICON_FIT_CONTAIN = {"minecraft", "factorio", "openmohaa", "vintage-story"}

TIMEOUT = 30


def fetch_buffer(url: str) -> tuple[bytes, str, str] | None:
    request = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "*/*"})
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            data = response.read()
            content_type = response.headers.get("Content-Type", "").lower()
    except (urllib.error.URLError, OSError, ValueError):
        return None
    if len(data) < 64:
        return None
    return data, content_type, url


def fetch_steam_asset(app_id: str) -> tuple[bytes, str, str, str] | None:
    for asset in STEAM_ASSETS:
        got = fetch_buffer(f"{STEAM_CDN}/{app_id}/{asset}")
        if got:
            data, content_type, url = got
            return data, content_type, url, f"steam:{asset}"
    return None


def steam_search_exact(title: str) -> str | None:
    query = urllib.parse.urlencode({"term": title, "l": "english", "cc": "US"})
    got = fetch_json(f"https://store.steampowered.com/api/storesearch/?{query}")
    if not got:
        return None
    needle = title.strip().lower()
    for item in got.get("items", []):
        if str(item.get("name", "")).strip().lower() == needle:
            return str(item["id"])
    return None


def wikipedia_thumb(title: str) -> tuple[bytes, str, str, str] | None:
    url = "https://en.wikipedia.org/api/rest_v1/page/summary/" + urllib.parse.quote(title)
    got = fetch_json(url)
    if not got:
        return None
    source = (got.get("originalimage") or {}).get("source") or (got.get("thumbnail") or {}).get("source")
    if not source:
        return None
    asset = fetch_buffer(source)
    if not asset:
        return None
    data, content_type, asset_url = asset
    return data, content_type, asset_url, f"wikipedia:{title}"


def fetch_json(url: str):
    request = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            return json.loads(response.read().decode("utf-8", "replace"))
    except (urllib.error.URLError, OSError, ValueError):
        return None


def parse_frontmatter(text: str) -> tuple[list[str] | None, str]:
    if not text.startswith("---\n"):
        return None, text
    end = text.find("\n---\n", 4)
    if end < 0:
        return None, text
    return text[4:end].split("\n"), text[end + 5 :]


def frontmatter_value(lines: list[str], key: str) -> str | None:
    for line in lines:
        match = re.match(rf"^{key}:\s*(.+?)\s*$", line)
        if match:
            value = match.group(1).strip()
            if (value.startswith('"') and value.endswith('"')) or (
                value.startswith("'") and value.endswith("'")
            ):
                value = value[1:-1]
            return value
    return None


def sync_frontmatter(path: Path, icon: str | None, fit: str) -> bool:
    """Add, update, or remove game_icon fields. Returns True when the file changed."""
    text = path.read_text()
    lines, body = parse_frontmatter(text)
    if lines is None:
        return False

    kept = [line for line in lines if not re.match(r"^(game_icon|game_icon_fit):", line)]

    if icon:
        insert = 0
        for index, line in enumerate(kept):
            if re.match(r"^(description|title):", line):
                insert = index + 1
        fields = [f"game_icon: {icon}"]
        if fit == "contain":
            fields.append("game_icon_fit: contain")
        kept[insert:insert] = fields

    updated = "---\n" + "\n".join(kept) + "\n---\n" + body
    if updated != text:
        path.write_text(updated)
        return True
    return False


def catalog_entries() -> list[dict[str, str]]:
    output = subprocess.run(
        [str(ROOT / "ci" / "server-catalog.sh")],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    entries = []
    for line in output.splitlines():
        parts = line.split("\t")
        if len(parts) >= 2 and parts[0].strip():
            entries.append({"id": parts[0], "compose": parts[1]})
    return entries


def roots_for_slug(slug: str, catalog: list[dict[str, str]]) -> list[Path]:
    roots: list[Path] = []
    direct = PODERIZED_DIR / slug
    if direct.is_dir():
        roots.append(direct)
    for entry in catalog:
        compose = entry["compose"]
        if (
            entry["id"] == slug
            or entry["id"].startswith(slug + "-")
            or compose == f"{slug}/compose.yml"
            or compose.startswith(slug + "/")
            or f"/{slug}/" in compose
        ):
            roots.append(ROOT / Path(compose).parent)
    if slug == "minecraft":
        roots += [PODERIZED_DIR / "minecraft" / variant for variant in ("fabric", "vanilla", "forge", "neoforge")]
    if slug == "valheim":
        roots += [PODERIZED_DIR / "valheim" / variant for variant in ("vanilla", "plus")]
    seen: set[Path] = set()
    unique = []
    for root in roots:
        if root not in seen and root.is_dir():
            seen.add(root)
            unique.append(root)
    return unique


def walk_scripts(root: Path) -> list[Path]:
    files: list[Path] = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [name for name in dirnames if name != "data" and not name.startswith(".")]
        for name in filenames:
            if name in ("compose.yml", "entrypoint.sh", "container-entrypoint.sh"):
                files.append(Path(dirpath) / name)
    return files


def is_preferred_app_env(name: str) -> bool:
    if re.search(r"STEAMWORKS", name):
        return False
    return bool(re.search(r"(?:GAME|STEAM)_APP_ID$", name)) and not re.search(r"STEAMWORKS_APP_ID$", name)


def is_fallback_app_env(name: str) -> bool:
    if re.search(r"STEAMWORKS", name):
        return False
    if is_preferred_app_env(name):
        return False
    return bool(re.search(r"_APP_ID$", name))


def extract_app_ids(text: str) -> tuple[list[str], list[str]]:
    preferred: list[str] = []
    fallback: list[str] = []

    def push_unique(target: list[str], app_id: str) -> None:
        if not re.match(r"^\d{2,10}$", app_id) or app_id in SKIP_APP_IDS:
            return
        if app_id not in target:
            target.append(app_id)

    patterns = [
        (r"\b([A-Z0-9_]+_APP_ID)\s*[:=]\s*[\"']?(\d{2,10})[\"']?", False),
        (r"\b([A-Z0-9_]+_APP_ID)\s*=\s*\"\$\{[^:]+:-(\d{2,10})\}\"", False),
        (r"steam_appid\.txt[\"']?\s*<<.*?\n['\"]?(\d{2,10})['\"]?\s*\n", True),
        (r"printf\s+'%s\\n'\s+\"(\d{2,10})\"\s*>\s*\"\$\{[^}]*\}\/steam_appid\.txt\"", True),
        (r"printf\s+'%s\\n'\s+'(\d{2,10})'\s*>\s*\"\$\{[^}]*\}\/steam_appid\.txt\"", True),
    ]

    for pattern, direct in patterns:
        flags = re.DOTALL if direct else 0
        for match in re.finditer(pattern, text, flags):
            if direct:
                push_unique(preferred, match.group(1))
            else:
                name, app_id = match.group(1), match.group(2)
                if is_preferred_app_env(name):
                    push_unique(preferred, app_id)
                elif is_fallback_app_env(name):
                    push_unique(fallback, app_id)
    return preferred, fallback


def discover_app_ids(slug: str, catalog: list[dict[str, str]]) -> tuple[list[str], list[str]]:
    preferred: list[str] = []
    fallback: list[str] = []
    for root in roots_for_slug(slug, catalog):
        for script in walk_scripts(root):
            got_preferred, got_fallback = extract_app_ids(script.read_text(errors="replace"))
            for app_id in got_preferred:
                if app_id not in preferred:
                    preferred.append(app_id)
            for app_id in got_fallback:
                if app_id not in fallback and app_id not in preferred:
                    fallback.append(app_id)
    return preferred, fallback


def pick_ext(data: bytes, content_type: str, source_url: str) -> str:
    if "png" in content_type or source_url.endswith(".png"):
        return "png"
    if "webp" in content_type or source_url.endswith(".webp"):
        return "webp"
    if "gif" in content_type or source_url.endswith(".gif"):
        return "gif"
    if "jpeg" in content_type or "jpg" in content_type or source_url.endswith(".jpg"):
        return "jpg"
    if data[0] == 0x89 and data[1] == 0x50:
        return "png"
    if data[0] == 0xFF and data[1] == 0xD8:
        return "jpg"
    if data[0] == 0x52 and data[1] == 0x49:
        return "webp"
    return "jpg"


def resolve_icon(slug: str, title: str, attrs: dict[str, str], catalog: list[dict[str, str]]):
    preferred: list[str] = []
    fallback: list[str] = []
    if attrs.get("steamAppId"):
        preferred.append(attrs["steamAppId"])
    got_preferred, got_fallback = discover_app_ids(slug, catalog)
    for app_id in got_preferred:
        if app_id not in preferred:
            preferred.append(app_id)
    for app_id in got_fallback:
        if app_id not in preferred and app_id not in fallback:
            fallback.append(app_id)

    if attrs.get("iconUrl"):
        asset = fetch_buffer(attrs["iconUrl"])
        if asset:
            data, content_type, url = asset
            return data, content_type, url, "frontmatter:iconUrl"

    for app_id in preferred:
        got = fetch_steam_asset(app_id)
        if got:
            return got

    search_id = steam_search_exact(title)
    if search_id:
        got = fetch_steam_asset(search_id)
        if got:
            return got

    for app_id in fallback:
        got = fetch_steam_asset(app_id)
        if got:
            return got

    wiki_title = WIKI_TITLE_ALIASES.get(slug, title)
    got = wikipedia_thumb(wiki_title)
    if got:
        return got

    if slug in DIRECT_ICON_URLS:
        asset = fetch_buffer(DIRECT_ICON_URLS[slug])
        if asset:
            data, content_type, url = asset
            return data, content_type, url, f"direct:{slug}"

    return None


def main() -> int:
    catalog = catalog_entries()
    ICONS_DIR.mkdir(parents=True, exist_ok=True)

    pages = sorted(SERVERS_DIR.glob("*.md"))
    keep: set[str] = set()
    fetched = 0
    misses: list[str] = []
    updates: list[str] = []

    for page in pages:
        slug = page.stem
        lines, _body = parse_frontmatter(page.read_text())
        attrs: dict[str, str] = {}
        if lines:
            for line in lines:
                match = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
                if match:
                    attrs[match.group(1)] = match.group(2).strip().strip("'\"")
        title = attrs.get("title", slug)

        try:
            asset = resolve_icon(slug, title, attrs, catalog)
        except Exception as error:  # network edge cases should not stop the build
            print(f"  -- {slug}: error: {error}", file=sys.stderr)
            asset = None

        if not asset:
            misses.append(slug)
            if sync_frontmatter(page, None, "cover"):
                updates.append(f"{page.name}: removed game_icon")
            continue

        data, content_type, source_url, source = asset
        file_name = f"{slug}.{pick_ext(data, content_type, source_url)}"
        (ICONS_DIR / file_name).write_bytes(data)
        keep.add(file_name)
        fetched += 1

        fit_override = attrs.get("game_icon_fit")
        if fit_override in ("contain", "cover"):
            fit = fit_override
        elif slug in ICON_FIT_CONTAIN or source.startswith(("direct:", "wikipedia:")):
            fit = "contain"
        else:
            fit = "cover"

        if sync_frontmatter(page, f"game-icons/{file_name}", fit):
            updates.append(f"{page.name}: game_icon -> game-icons/{file_name}")

    for stale in ICONS_DIR.iterdir():
        if stale.is_file() and stale.name not in keep:
            stale.unlink()

    print(f"game icons: {fetched}/{len(pages)} downloaded")
    for update in updates:
        print(f"  updated {update}")
    for slug in misses:
        print(f"  -- {slug}: no icon resolved")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
