#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${DOD_DIR}"
    chown -R dodsource:dodsource "${DOD_DIR}" 2>/dev/null || true
    exec runuser -u dodsource -- /bin/bash /home/dodsource/entrypoint.sh "$@"
fi

exec /bin/bash /home/dodsource/entrypoint.sh "$@"
