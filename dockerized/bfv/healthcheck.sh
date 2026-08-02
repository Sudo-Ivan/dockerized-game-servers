#!/bin/sh
set -eu
pgrep -f 'bfv_linded' >/dev/null 2>&1 || pgrep -f 'bfvietnam' >/dev/null 2>&1 || pgrep -f 'bfv_lnxded' >/dev/null 2>&1
