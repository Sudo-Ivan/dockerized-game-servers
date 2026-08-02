#!/usr/bin/env python3
"""Sync Arma 3 workshop mods from a launcher HTML preset via Steam CDN."""

import glob
import os
import shutil
import sys

from api.config import normalize_steam_username, require_workshop_steam_account
from modlist import extract_workshop_ids


def arma_dir():
    return os.environ.get("ARMA_DIR", "/home/arma3/server")


def keys_directory():
    return os.path.join(arma_dir(), "keys")


def workshop_mod_path(mod_id):
    return os.path.join(arma_dir(), "workshop", str(mod_id))


def copy_mod_keys(mod_path):
    keys_out = keys_directory()
    os.makedirs(keys_out, exist_ok=True)
    key_files = glob.glob(os.path.join(mod_path, "**", "*.bikey"), recursive=True)
    if not key_files:
        print(f"Missing keys: {mod_path}", file=sys.stderr)
        return
    for key_path in key_files:
        if os.path.isfile(key_path):
            shutil.copy2(key_path, keys_out)


def sync_workshop_mods(preset_file, session):
    mod_ids = extract_workshop_ids(preset_file)
    if not mod_ids:
        print("No workshop IDs found in preset.", file=sys.stderr)
        return []

    synced = []
    for mod_id in mod_ids:
        print(f"--- Syncing workshop mod {mod_id} ---")
        session.download_workshop(int(mod_id))
        mod_path = workshop_mod_path(mod_id)
        if os.path.isdir(mod_path):
            copy_mod_keys(mod_path)
            synced.append(mod_id)
        else:
            print(f"Workshop {mod_id} missing after sync.", file=sys.stderr)
    return synced


def main():
    preset_file = (
        sys.argv[1]
        if len(sys.argv) > 1
        else os.environ.get("MODLIST_FILE", "")
    )
    if not preset_file or not os.path.isfile(preset_file):
        return 0

    username = normalize_steam_username(os.environ.get("STEAM_USERNAME", "anonymous"))
    password = os.environ.get("STEAM_PASSWORD", "")

    try:
        require_workshop_steam_account(username, password)
        from api import SteamSession

        session = SteamSession.login(
            username,
            password,
            auth_code=os.environ.get("STEAM_GUARD_CODE", ""),
        )
        synced_ids = sync_workshop_mods(preset_file, session)
    except Exception as exc:
        print(f"Workshop sync failed: {exc}", file=sys.stderr)
        return 1

    print(" ".join(synced_ids))
    return 0 if synced_ids or not extract_workshop_ids(preset_file) else 1


if __name__ == "__main__":
    sys.exit(main())
