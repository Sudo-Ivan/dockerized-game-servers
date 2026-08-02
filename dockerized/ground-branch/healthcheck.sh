#!/bin/sh
# Ground Branch process healthcheck.

set -eu

pgrep -f 'GroundBranchServer' >/dev/null 2>&1
