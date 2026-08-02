#!/bin/sh
# Left 4 Dead 2 srcds process healthcheck.

set -eu

pgrep -f 'srcds_linux' >/dev/null 2>&1
