#!/bin/sh
# Valheim Plus process healthcheck.

set -eu

pgrep -f 'valheim_server' >/dev/null 2>&1
