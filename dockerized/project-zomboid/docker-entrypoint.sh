#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${PZ_INSTALL_DIR}" "${PZ_HOME}" /home/zomboid/Steam
    chown -R zomboid:zomboid /opt/zomboid /home/zomboid
    exec runuser -u zomboid -- /bin/bash /home/zomboid/entrypoint.sh "$@"
fi

exec /bin/bash /home/zomboid/entrypoint.sh "$@"
