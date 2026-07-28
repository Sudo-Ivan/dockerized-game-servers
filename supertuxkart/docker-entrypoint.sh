#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${STK_DATA_DIR}"
    chown -R supertuxkart:supertuxkart "${STK_DATA_DIR}"
    exec runuser -u supertuxkart -- /bin/bash /home/supertuxkart/entrypoint.sh "$@"
fi

exec /bin/bash /home/supertuxkart/entrypoint.sh "$@"
