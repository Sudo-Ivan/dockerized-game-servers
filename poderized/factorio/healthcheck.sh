#!/bin/sh
# Factorio process healthcheck.

set -eu

pgrep -x factorio >/dev/null 2>&1 || pgrep -f '/bin/x64/factorio' >/dev/null 2>&1
