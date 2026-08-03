#!/bin/bash
set -eu

mkdir -p "${VS_ROOT}" "${VS_SERVER_DIR}" "${VS_DATA_DIR}"
exec /bin/bash /home/vintagestory/entrypoint.sh "$@"
