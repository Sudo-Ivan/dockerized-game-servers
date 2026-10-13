#!/bin/sh
# Starbound dedicated server process healthcheck.

set -eu

pgrep -f 'starbound_server' >/dev/null 2>&1
