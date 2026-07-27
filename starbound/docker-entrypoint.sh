#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${STARBOUND_DIR}" /home/starbound/Steam
    chown -R starbound:starbound "${STARBOUND_DIR}" /home/starbound
    exec runuser -u starbound -- /bin/bash /home/starbound/entrypoint.sh "$@"
fi

exec /bin/bash /home/starbound/entrypoint.sh "$@"
