#!/bin/sh
# Longvinter dedicated server process healthcheck.

set -eu

if pgrep -f 'LongvinterServer-Linux-Shipping' >/dev/null 2>&1; then
    exit 0
fi
pgrep -f 'Longvinter-Linux-Shipping' >/dev/null 2>&1
