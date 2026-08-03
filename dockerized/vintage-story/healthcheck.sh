#!/bin/sh
# Vintage Story process healthcheck.

set -eu

pgrep -f 'VintagestoryServer\.dll' >/dev/null 2>&1
