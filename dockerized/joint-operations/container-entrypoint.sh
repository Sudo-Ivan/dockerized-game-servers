#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${JO_DIR}" /tmp/.X11-unix
    chmod 1777 /tmp/.X11-unix
    chown -R jointops:jointops "${JO_DIR}" 2>/dev/null || true
    exec runuser -u jointops -- /bin/bash /home/jointops/entrypoint.sh "$@"
fi

exec /bin/bash /home/jointops/entrypoint.sh "$@"
