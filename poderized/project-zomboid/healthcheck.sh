#!/bin/sh
# Project Zomboid process healthcheck.

set -eu

pgrep -f 'ProjectZomboid64' >/dev/null 2>&1
