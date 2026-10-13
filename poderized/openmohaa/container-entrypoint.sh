#!/bin/sh
set -eu

if [ "$(id -u)" -eq 0 ]; then
    chown -R openmohaa:openmohaa "${MOHAA_DATA_DIR}" /home/openmohaa
    exec runuser -u openmohaa -- /bin/bash /home/openmohaa/entrypoint.sh "$@"
fi

exec /bin/bash /home/openmohaa/entrypoint.sh "$@"
