#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${L4D2_DIR}" /home/l4d2/Steam
    chown -R l4d2:l4d2 "${L4D2_DIR}" /home/l4d2
    exec runuser -u l4d2 -- /bin/bash /home/l4d2/entrypoint.sh "$@"
fi

exec /bin/bash /home/l4d2/entrypoint.sh "$@"
