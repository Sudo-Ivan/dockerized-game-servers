#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${SE_DEDICATED_DIR}" "${SE_INSTANCES_DIR}" "${SE_PLUGINS_DIR}"
    chown -R spaceengineers:spaceengineers /opt/spaceengineers /home/spaceengineers
    exec runuser -u spaceengineers -- /bin/bash /home/spaceengineers/entrypoint.sh "$@"
fi

exec /bin/bash /home/spaceengineers/entrypoint.sh "$@"
