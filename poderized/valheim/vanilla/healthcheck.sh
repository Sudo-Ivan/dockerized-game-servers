#!/bin/sh
# Valheim process healthcheck.

set -eu

pgrep -f 'valheim_server' >/dev/null 2>&1
