"""Configuration constants and utilities for the Steam API module."""

import os

ARMA3_SERVER_APP_ID = 233780
SESSION_RESET_THRESHOLD = 3

ARMA_DIR = os.environ.get("ARMA_DIR", "/home/arma3/server")
CACHE_DIR = os.environ.get("ARMA_CACHE_DIR", "/home/arma3/cache")
MANIFEST_CACHE_FILE = os.path.join(CACHE_DIR, "manifests.json")
CACHE_EXPIRY_SECONDS = 5 * 60

WORKSHOP_ROOT = os.path.join(ARMA_DIR, "workshop")
DEPOT_ROOT = ARMA_DIR
INDEX_ROOT = os.path.join(CACHE_DIR, "index")
WORKSHOP_INDEX_DIR = os.path.join(INDEX_ROOT, "workshop")
DEPOT_INDEX_DIR = os.path.join(INDEX_ROOT, "depot")

STATE_VERSION = "1.0"
COMBINATION_METHOD = "file-hash-asc"

DEFAULT_CONFIG = {
    "cdn_client_retries": 3,
    "cdn_client_base_delay": 1.5,
    "cdn_op_retries": 3,
    "cdn_op_base_delay": 1.5,
    "download_max_workers": 4,
    "download_chunk_size": 4 * 1024 * 1024,
    "download_progress_interval": 60,
}

_ENV_INT_KEYS = {
    "cdn_client_retries": "ARMA_CDN_CLIENT_RETRIES",
    "cdn_op_retries": "ARMA_CDN_OP_RETRIES",
    "download_max_workers": "ARMA_DOWNLOAD_MAX_WORKERS",
    "download_chunk_size": "ARMA_DOWNLOAD_CHUNK_SIZE",
    "download_progress_interval": "ARMA_DOWNLOAD_PROGRESS_INTERVAL",
}

_ENV_FLOAT_KEYS = {
    "cdn_client_base_delay": "ARMA_CDN_CLIENT_BASE_DELAY",
    "cdn_op_base_delay": "ARMA_CDN_OP_BASE_DELAY",
}

CDLC_IDS = {
    "csla": 233793,
    "gm": 233792,
    "vn": 233794,
    "ws": 233795,
    "spe": 233788,
    "rf": 233799,
    "ef": 233798,
}


def _env_int(key, default):
    value = os.environ.get(key)
    try:
        return int(value) if value not in (None, "") else default
    except ValueError:
        return default


def _env_float(key, default):
    value = os.environ.get(key)
    try:
        return float(value) if value not in (None, "") else default
    except ValueError:
        return default


def normalize_steam_username(value):
    username = (value or "").strip()
    if not username or username.lower() == "anonymous":
        return "anonymous"
    return username


def require_workshop_steam_account(username, password):
    """Workshop CDN sync needs a real Steam account, not anonymous login."""
    if normalize_steam_username(username) == "anonymous":
        raise RuntimeError(
            "Workshop mod sync requires STEAM_USERNAME and STEAM_PASSWORD "
            "(anonymous login cannot download subscribed workshop items)"
        )
    if not (password or "").strip():
        raise RuntimeError(
            "Workshop mod sync requires STEAM_PASSWORD when STEAM_USERNAME is set"
        )


def resolve_config(config=None):
    """Merge caller config, environment, and defaults without mutating inputs."""
    merged = DEFAULT_CONFIG.copy()

    for cfg_key, env_key in _ENV_INT_KEYS.items():
        merged[cfg_key] = _env_int(env_key, merged[cfg_key])
    for cfg_key, env_key in _ENV_FLOAT_KEYS.items():
        merged[cfg_key] = _env_float(env_key, merged[cfg_key])

    if config:
        merged.update({k: v for k, v in config.items() if v is not None})
    return merged
