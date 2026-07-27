#!/bin/sh
set -eu

pgrep -f 'etlded' >/dev/null 2>&1
