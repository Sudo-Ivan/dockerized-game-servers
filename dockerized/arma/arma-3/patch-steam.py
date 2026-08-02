#!/usr/bin/env python3
"""Apply runtime fixes to the valvepython steam package after pip install."""

import re
import sys
from pathlib import Path


def patch_once(text, pattern, repl, label):
    if isinstance(repl, str) and repl in text:
        return text, False
    updated, count = re.subn(pattern, repl, text, count=1, flags=re.MULTILINE)
    if count != 1:
        raise RuntimeError(f"patch target missing: {label}")
    return updated, True


def find_steam_root(venv_root):
    site_packages = Path(venv_root) / "lib"
    matches = list(site_packages.glob("python*/site-packages/steam"))
    if not matches:
        raise RuntimeError(f"steam package not found under {venv_root}")
    return matches[0]


def main():
    venv_root = sys.argv[1] if len(sys.argv) > 1 else "/home/arma3/venv"
    steam_root = find_steam_root(venv_root)
    applied = []

    cdn_path = steam_root / "client" / "cdn.py"
    cdn_text = cdn_path.read_text(encoding="utf-8")
    cdn_text, changed = patch_once(
        cdn_text,
        r"(?ms)^(?P<indent>[ \t]+)if resp\.header\.eresult != EResult\.OK:\n"
        r"(?P=indent) raise SteamError\(resp\.header\.error_message or 'No message', resp\.header\.eresult\)\n"
        r"\n"
        r"(?P=indent)wf = None if resp is None else resp\.body\.publishedfiledetails\[0\]",
        r"\g<indent>if resp is None:\n"
        r"\g<indent> raise SteamError(\"Failed getting workshop file info\", EResult.Timeout)\n"
        r"\n"
        r"\g<indent>if resp.header.eresult != EResult.OK:\n"
        r"\g<indent> raise SteamError(resp.header.error_message or 'No message', resp.header.eresult)\n"
        r"\n"
        r"\g<indent>wf = resp.body.publishedfiledetails[0]",
        "cdn.get_manifest_for_workshop_item null check",
    )
    if changed:
        cdn_path.write_text(cdn_text, encoding="utf-8")
        applied.append("cdn.py")

    steamid_path = steam_root / "steamid.py"
    steamid_text = steamid_path.read_text(encoding="utf-8")

    steamid_text, changed = patch_once(
        steamid_text,
        r"if not re\.match\(r'\^'\+\_csgofrcode_chars\+'\\-\]\{10\}\$', code\):",
        "if not re.match(r'^['+_csgofrcode_chars+r'\\-]{10}$', code):",
        "steamid csgo friend code regex",
    )
    if changed:
        applied.append("steamid.py")

    steamid_text, changed = patch_once(
        steamid_text,
        r'data_match = re\.search\("OpenGroupChat\\\( \*\'\(\?P<steamid>\\d\+\)\'", text\)',
        'data_match = re.search(r"OpenGroupChat\\( *\'(?P<steamid>\\d+)\'", text)',
        "steamid OpenGroupChat regex",
    )
    if changed and "steamid.py" not in applied:
        applied.append("steamid.py")

    if "steamid.py" in applied:
        steamid_path.write_text(steamid_text, encoding="utf-8")

    if applied:
        print(f"Patched steam package at {steam_root}: {', '.join(applied)}")
    else:
        print(f"Steam package already patched at {steam_root}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
