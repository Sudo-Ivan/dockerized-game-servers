"""Parse Arma 3 launcher HTML mod presets (no Steam dependencies)."""

import re

WORKSHOP_ID_PATTERN = re.compile(r"filedetails/\?id=(\d+)")


def extract_workshop_ids(file_path):
    with open(file_path, encoding="utf-8") as f:
        html = f.read()
    seen = set()
    ordered = []
    for match in WORKSHOP_ID_PATTERN.finditer(html):
        mod_id = match.group(1)
        if mod_id not in seen:
            seen.add(mod_id)
            ordered.append(mod_id)
    return ordered
