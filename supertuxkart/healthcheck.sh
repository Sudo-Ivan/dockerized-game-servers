#!/bin/sh
# SuperTuxKart process healthcheck.

set -eu

pgrep -f '/opt/supertuxkart/bin/supertuxkart' >/dev/null 2>&1
