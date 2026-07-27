#!/bin/sh
# OpenMoHAA UDP query healthcheck (ioquake3-style disconnect header).

set -eu

header=$(printf '\xff\xff\xff\xff\x01disconnect')
message='none'
query_port="${MOH_GAME_PORT:-12203}"
data=""

while [ -z "${data}" ]; do
    data=$(printf '%s' "${message}" | socat - UDP:127.0.0.1:"${query_port}" 2>/dev/null) || {
        echo "healthcheck: socat failed" >&2
        exit 1
    }
    if [ -n "${data}" ]; then
        break
    fi
    sleep 1
done

if [ "${data}" != "${header}" ]; then
    echo "healthcheck: unexpected response" >&2
    exit 1
fi

exit 0
