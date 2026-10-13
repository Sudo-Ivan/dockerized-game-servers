#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${ARMA_DIR}" /home/arma3/profiles /home/arma3/configs /home/arma3/cache
    chown -R arma3:arma3 /home/arma3
    exec runuser -u arma3 -- /bin/bash /home/arma3/entrypoint.sh "$@"
fi

exec /bin/bash /home/arma3/entrypoint.sh "$@"
