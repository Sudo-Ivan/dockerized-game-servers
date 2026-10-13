#!/usr/bin/env python3
"""Offline checks for Arma 3 launcher modlist parsing and workshop auth rules."""

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))

from api.config import normalize_steam_username, require_workshop_steam_account
from modlist import extract_workshop_ids

FIXTURE = ROOT / "fixtures" / "modlist.html"
EXPECTED_IDS = [
    "3499977893",
    "1724884525",
    "3641926249",
    "1544955993",
    "1660970010",
    "450814997",
    "583496184",
    "583544987",
    "497661914",
    "541888371",
    "497660133",
    "333310405",
    "2034363662",
    "825179978",
    "2938312887",
    "1537745369",
    "2886141254",
    "1883956552",
    "1804716719",
    "1208517358",
    "2129532219",
    "3702603652",
    "3639557777",
    "843425103",
    "843593391",
    "843632231",
    "843577117",
    "2853200431",
    "3686863566",
]


def main():
    if not FIXTURE.is_file():
        print(f"missing fixture: {FIXTURE}", file=sys.stderr)
        return 1

    ids = extract_workshop_ids(str(FIXTURE))
    if ids != EXPECTED_IDS:
        print("modlist ID mismatch", file=sys.stderr)
        print(f"expected {len(EXPECTED_IDS)} ids, got {len(ids)}", file=sys.stderr)
        missing = set(EXPECTED_IDS) - set(ids)
        extra = set(ids) - set(EXPECTED_IDS)
        if missing:
            print(f"missing: {sorted(missing)}", file=sys.stderr)
        if extra:
            print(f"extra: {sorted(extra)}", file=sys.stderr)
        return 1

    cases = [
        ("", "anonymous"),
        ("anonymous", "anonymous"),
        ("  ANONYMOUS  ", "anonymous"),
        ("myuser", "myuser"),
    ]
    for raw, want in cases:
        got = normalize_steam_username(raw)
        if got != want:
            print(f"normalize_steam_username({raw!r}) = {got!r}, want {want!r}", file=sys.stderr)
            return 1

    workshop_cases = [
        ("anonymous", "", "anonymous login cannot download"),
        ("", "", "anonymous login cannot download"),
        ("myuser", "", "STEAM_PASSWORD"),
    ]
    for user, passwd, needle in workshop_cases:
        try:
            require_workshop_steam_account(user, passwd)
            print(f"require_workshop_steam_account({user!r}, ...) should have failed", file=sys.stderr)
            return 1
        except RuntimeError as exc:
            if needle not in str(exc):
                print(f"unexpected workshop auth error: {exc}", file=sys.stderr)
                return 1

    print(f"test_modlist ok ({len(ids)} workshop ids, offline only)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
