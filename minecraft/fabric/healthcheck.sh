#!/bin/sh
# Minecraft TCP listen probe via /proc/net/tcp (works on Alpine without bash).

set -eu

PORT="${SERVER_PORT:-25565}"
port_hex="$(printf '%04X' "${PORT}")"
found=0

for table in /proc/net/tcp /proc/net/tcp6; do
  [ -r "${table}" ] || continue
  if awk -v p="${port_hex}" '
    BEGIN { p = tolower(p) }
    {
      n = split($2, a, ":")
      if (n >= 2 && tolower(a[n]) == p && $4 == "0A") {
        found = 1
        exit 0
      }
    }
    END { exit !found }
  ' "${table}"; then
    found=1
    break
  fi
done

[ "${found}" -eq 1 ]
