"""Steam session management with automatic retry and session reset."""

import os
import time
import threading

import steam.monkey

steam.monkey.patch_minimal()

from steam.client import SteamClient
from steam.client.cdn import CDNClient

from .config import (
    SESSION_RESET_THRESHOLD,
    WORKSHOP_ROOT,
    WORKSHOP_INDEX_DIR,
    normalize_steam_username,
    resolve_config,
)
from .sync import ContentSyncer


_cached_cdn_client = None
_cached_steam_client_id = None


def _get_cdn_client(client, config=None):
    global _cached_cdn_client, _cached_steam_client_id

    resolved = resolve_config(config)
    retries = resolved["cdn_client_retries"]
    base_delay = resolved["cdn_client_base_delay"]

    if _cached_cdn_client and _cached_steam_client_id == id(client):
        return _cached_cdn_client

    last_error = None
    for attempt in range(1, retries + 1):
        try:
            cdn_client = CDNClient(client)
            _cached_cdn_client = cdn_client
            _cached_steam_client_id = id(client)
            return cdn_client
        except Exception as exc:
            last_error = exc
            print(f"CDNClient init failed (attempt {attempt}/{retries}): {exc}")
            if attempt < retries:
                time.sleep(base_delay * attempt)

    print(
        f"CDNClient could not be initialized after {retries} attempts; "
        f"giving up. Last error: {last_error}"
    )
    return None


def _clear_cdn_cache():
    global _cached_cdn_client, _cached_steam_client_id
    _cached_cdn_client = None
    _cached_steam_client_id = None


class SteamSession:
    """Steam and CDN client facade with retry and session reset."""

    def __init__(self, username, password, config=None, auth_code=""):
        self._username = normalize_steam_username(username)
        self._password = password or ""
        self._auth_code = (auth_code or "").strip()
        self._config = config
        self._client = None
        self._cdn_client = None
        self._consecutive_failures = 0
        self._lock = threading.Lock()

    def _reset_session(self):
        print("Performing full Steam session reset...")
        self._client = None
        self._cdn_client = None
        self._consecutive_failures = 0
        _clear_cdn_cache()
        self._ensure_connected()

    def _login(self):
        self._client = SteamClient()
        if self._username == "anonymous":
            self._client.anonymous_login()
            print("Logged in to Steam anonymously")
        else:
            login_kwargs = {}
            if self._auth_code:
                if len(self._auth_code) == 5 and self._auth_code.isalnum():
                    login_kwargs["two_factor_code"] = self._auth_code
                else:
                    login_kwargs["auth_code"] = self._auth_code
            self._client.login(self._username, self._password, **login_kwargs)
            user = self._client.user
            display_name = user.name if user and getattr(user, "name", None) else self._username
            print("Logged in to Steam as", display_name)

    def _ensure_connected(self):
        if self._client is None:
            self._login()

        if self._cdn_client is None:
            resolved = resolve_config(self._config)
            self._cdn_client = _get_cdn_client(self._client, resolved)
            if self._cdn_client is None:
                raise RuntimeError("Failed to initialize CDN client")

    def _record_success(self):
        with self._lock:
            self._consecutive_failures = 0

    def _record_failure(self):
        with self._lock:
            self._consecutive_failures += 1
            if self._consecutive_failures >= SESSION_RESET_THRESHOLD:
                print(f"Hit {self._consecutive_failures} consecutive failures, resetting session...")
                self._reset_session()
                return True
            return False

    def _execute_cdn_op(self, op_name, func, *args, **kwargs):
        resolved = resolve_config(self._config)
        retries = resolved["cdn_op_retries"]
        base_delay = resolved["cdn_op_base_delay"]

        max_session_resets = 2
        session_reset_count = 0
        last_error = None

        while session_reset_count <= max_session_resets:
            self._ensure_connected()

            for attempt in range(1, retries + 1):
                try:
                    result = func(self._cdn_client, *args, **kwargs)
                    self._record_success()
                    return result
                except Exception as exc:
                    last_error = exc
                    print(f"{op_name} failed (attempt {attempt}/{retries}): {exc}")

                    should_retry = self._record_failure()
                    if should_retry:
                        session_reset_count += 1
                        print(f"Session reset #{session_reset_count}, retrying {op_name}...")
                        break

                    if attempt < retries:
                        time.sleep(base_delay * attempt)
            else:
                raise RuntimeError(f"{op_name} failed after {retries} attempts: {last_error}")

        raise RuntimeError(f"{op_name} failed after {max_session_resets} session resets: {last_error}")

    def get_manifest_for_workshop_item(self, workshop_id):
        return self._execute_cdn_op(
            "get_manifest_for_workshop_item",
            lambda cdn, wid: cdn.get_manifest_for_workshop_item(wid),
            workshop_id,
        )

    def download_workshop(self, workshop_id):
        resolved_config = resolve_config(self._config)
        workshop_manifest = self.get_manifest_for_workshop_item(workshop_id)
        files = [f for f in workshop_manifest.iter_files() if f.is_file]
        destination = os.path.join(WORKSHOP_ROOT, str(workshop_id))

        syncer = ContentSyncer(WORKSHOP_INDEX_DIR, config=resolved_config)
        syncer.sync(files, destination, workshop_id, f"Workshop {workshop_id}")

    @staticmethod
    def login(username, password, config=None, auth_code=""):
        session = SteamSession(username, password, config=config, auth_code=auth_code)
        session._ensure_connected()
        return session
