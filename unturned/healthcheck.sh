#!/bin/sh
set -eu

pgrep -f 'Unturned_Headless' >/dev/null 2>&1 || pgrep -f 'Unturned' >/dev/null 2>&1
