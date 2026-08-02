#!/bin/sh
# Terraria process healthcheck.

set -eu

pgrep -f 'TerrariaServer' >/dev/null 2>&1
