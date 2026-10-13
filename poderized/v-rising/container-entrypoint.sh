#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${VRISING_DIR}" /tmp/.X11-unix
    chmod 1777 /tmp/.X11-unix 2>/dev/null || true
    chown -R vrising:vrising "${VRISING_DIR}" 2>/dev/null || true
    exec runuser -u vrising -- /bin/bash /home/vrising/entrypoint.sh "$@"
fi

exec /bin/bash /home/vrising/entrypoint.sh "$@"
