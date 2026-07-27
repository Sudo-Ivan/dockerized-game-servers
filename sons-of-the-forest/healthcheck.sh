#!/bin/sh
# Sons Of The Forest process healthcheck.

set -eu

pgrep -f 'SonsOfTheForestDS' >/dev/null 2>&1
