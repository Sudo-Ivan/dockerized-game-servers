#!/bin/sh
# Arma 3 process healthcheck.

set -eu

pgrep -f 'arma3server_x64' >/dev/null 2>&1
