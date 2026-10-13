#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${CODWAW_DIR}"
    chown -R codwaw:codwaw "${CODWAW_DIR}" 2>/dev/null || true
    exec runuser -u codwaw -- /bin/bash /home/codwaw/entrypoint.sh "$@"
fi

exec /bin/bash /home/codwaw/entrypoint.sh "$@"
