#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${GB_INSTALL_DIR}"
    chown -R groundbranch:groundbranch "${GB_INSTALL_DIR}" /home/groundbranch
    exec runuser -u groundbranch -- /bin/bash /home/groundbranch/entrypoint.sh "$@"
fi

exec /bin/bash /home/groundbranch/entrypoint.sh "$@"
