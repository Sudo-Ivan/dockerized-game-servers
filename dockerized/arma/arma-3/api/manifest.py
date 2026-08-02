"""Manifest caching for Steam CDN operations."""

import os
import json
import time

from .config import MANIFEST_CACHE_FILE, CACHE_EXPIRY_SECONDS


class ManifestCache:
    """Handles caching of Steam CDN manifest data."""

    def __init__(self, cache_file=None, expiry_seconds=None):
        self.cache_file = cache_file or MANIFEST_CACHE_FILE
        self.expiry_seconds = expiry_seconds or CACHE_EXPIRY_SECONDS

    def load(self):
        if not os.path.exists(self.cache_file):
            return None

        try:
            with open(self.cache_file, "r") as f:
                cache_data = json.load(f)

            if time.time() - cache_data.get("timestamp", 0) > self.expiry_seconds:
                print("Manifest cache expired, will refetch...")
                return None

            return cache_data.get("manifests", [])
        except (json.JSONDecodeError, FileNotFoundError):
            print("Cache file corrupted or missing, will refetch...")
            return None

    def save(self, manifests):
        cache_dir = os.path.dirname(self.cache_file)
        if cache_dir:
            os.makedirs(cache_dir, exist_ok=True)

        manifest_data = []
        for manifest in manifests:
            manifest_data.append({
                "name": manifest.name,
                "gid": manifest.gid,
                "depot_id": manifest.depot_id,
            })

        cache_data = {
            "timestamp": time.time(),
            "manifests": manifest_data,
        }

        with open(self.cache_file, "w") as f:
            json.dump(cache_data, f, indent=2)

        print(f"Manifest data cached to {self.cache_file}")
