#!/bin/sh
# Palworld dedicated server process healthcheck.

set -eu

if pgrep -f 'PalServer-Linux-Shipping' >/dev/null 2>&1; then
    exit 0
fi
pgrep -f 'Pal-Linux-Shipping' >/dev/null 2>&1
