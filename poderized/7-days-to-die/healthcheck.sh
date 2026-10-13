#!/bin/sh
# 7 Days to Die process healthcheck.

set -eu

pgrep -f '7DaysToDieServer' >/dev/null 2>&1
