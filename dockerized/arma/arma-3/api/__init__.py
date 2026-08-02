"""Steam CDN sync for Arma 3 workshop and depot content."""

from .config import CDLC_IDS, DEFAULT_CONFIG, ARMA3_SERVER_APP_ID

__all__ = [
    "SteamSession",
    "CDLC_IDS",
    "DEFAULT_CONFIG",
    "ARMA3_SERVER_APP_ID",
]


def __getattr__(name):
    if name == "SteamSession":
        from .session import SteamSession

        return SteamSession
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
