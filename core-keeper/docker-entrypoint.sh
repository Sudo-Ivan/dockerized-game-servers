#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${CK_INSTALL_DIR}" "${CK_DATA_DIR}" /tmp/.X11-unix
    chmod 1777 /tmp/.X11-unix
    chown -R corekeeper:corekeeper /opt/corekeeper /home/corekeeper
    exec runuser -u corekeeper -- /bin/bash /home/corekeeper/entrypoint.sh "$@"
fi

exec /bin/bash /home/corekeeper/entrypoint.sh "$@"
