#!/bin/sh
set -eu

pgrep -f 'FactoryServer-Linux-Shipping' >/dev/null 2>&1 \
    || pgrep -f 'FactoryServer.sh' >/dev/null 2>&1
