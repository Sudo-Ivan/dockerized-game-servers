#!/bin/sh
# Core Keeper health: server process up and GameID.txt present.

set -eu

CK_INSTALL_DIR="${CK_INSTALL_DIR:-/opt/corekeeper/server}"

if [ "${CK_HEALTH_SKIP_PROCESS:-0}" != "1" ]; then
  if ! pgrep -f CoreKeeperServer >/dev/null 2>&1; then
    exit 1
  fi
fi

[ -s "${CK_INSTALL_DIR}/GameID.txt" ]
