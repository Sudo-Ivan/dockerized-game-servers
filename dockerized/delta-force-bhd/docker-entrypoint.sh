#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${BHD_DIR}" /tmp/.X11-unix
    chmod 1777 /tmp/.X11-unix
    chown -R dfbhd:dfbhd "${BHD_DIR}" 2>/dev/null || true
    exec runuser -u dfbhd -- /bin/bash /home/dfbhd/entrypoint.sh "$@"
fi

exec /bin/bash /home/dfbhd/entrypoint.sh "$@"
