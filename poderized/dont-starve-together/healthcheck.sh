#!/bin/sh
set -eu

pgrep -f 'dontstarve_dedicated_server' >/dev/null 2>&1
