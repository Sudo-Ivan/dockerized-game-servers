#!/bin/sh
set -eu

pgrep -f 'DedicatedServer' >/dev/null 2>&1
