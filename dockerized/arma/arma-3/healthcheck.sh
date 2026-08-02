#!/bin/sh
# Arma 3 healthcheck: panel up and server process when auto-started.

set -eu

python3 -c "import os, urllib.request; urllib.request.urlopen('http://127.0.0.1:'+os.environ.get('PANEL_PORT','9283')+'/health', timeout=3)"

if [ "${PANEL_AUTO_START:-true}" = "true" ]; then
  pgrep -f 'arma3server_x64' >/dev/null 2>&1
fi
