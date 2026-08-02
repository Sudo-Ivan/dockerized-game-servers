#!/bin/bash
# Retry large or flaky HTTP downloads (curl 18 partial transfers, transient CDN errors).
set -eu

http_download_file() {
    local url="${1:?url required}"
    local dest="${2:?dest required}"
    local max_attempts="${HTTP_DOWNLOAD_RETRIES:-8}"
    local sleep_sec="${HTTP_DOWNLOAD_RETRY_DELAY:-5}"
    local attempt=1

    while [ "${attempt}" -le "${max_attempts}" ]; do
        rm -f "${dest}"
        if curl -fsSL \
            --connect-timeout 30 \
            --retry 5 \
            --retry-all-errors \
            --retry-delay 3 \
            -C - \
            "${url}" -o "${dest}" && [ -s "${dest}" ]; then
            return 0
        fi
        echo "Download attempt ${attempt}/${max_attempts} failed: ${url}" >&2
        if [ "${attempt}" -lt "${max_attempts}" ]; then
            sleep "${sleep_sec}"
            sleep_sec=$((sleep_sec + sleep_sec))
            if [ "${sleep_sec}" -gt 60 ]; then
                sleep_sec=60
            fi
        fi
        attempt=$((attempt + 1))
    done
    return 1
}
