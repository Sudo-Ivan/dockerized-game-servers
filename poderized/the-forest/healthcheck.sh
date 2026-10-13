#!/bin/sh
# The Forest process healthcheck.

set -eu

pgrep -f 'TheForestDedicatedServer' >/dev/null 2>&1
