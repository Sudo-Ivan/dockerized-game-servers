#!/bin/sh
set -eu

pgrep -f 'srcds_linux' >/dev/null 2>&1 || pgrep -f 'srcds_run' >/dev/null 2>&1
