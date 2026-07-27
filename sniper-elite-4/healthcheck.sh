#!/bin/sh
# Sniper Elite 4 process healthcheck.

set -eu

pgrep -f 'SniperElite4_Dedicated' >/dev/null 2>&1
