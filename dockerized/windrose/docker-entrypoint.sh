#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${WINDROSE_DIR}" /tmp/.X11-unix
    chmod 1777 /tmp/.X11-unix 2>/dev/null || true
    chown -R windrose:windrose "${WINDROSE_DIR}" 2>/dev/null || true
    exec runuser -u windrose -- /bin/bash /home/windrose/entrypoint.sh "$@"
fi

exec /bin/bash /home/windrose/entrypoint.sh "$@"
