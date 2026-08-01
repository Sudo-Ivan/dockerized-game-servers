#!/bin/bash
# 32-bit libs required by Source srcds modules (for example replay_srv.so on TF2).
set -eu

# shellcheck source=http-download.sh
. "$(dirname "$0")/http-download.sh"

LIBCURL_DEB_URL="${LIBCURL_DEB_URL:-http://deb.debian.org/debian/pool/main/c/curl/libcurl3-gnutls_7.88.1-10+deb12u15_i386.deb}"

tmpdir="$(mktemp -d)"
deb="${tmpdir}/libcurl3-gnutls_i386.deb"

cleanup() {
    rm -rf "${tmpdir}"
}
trap cleanup EXIT

http_download_file "${LIBCURL_DEB_URL}" "${deb}"
if [ -n "${LIBCURL_DEB_SHA256:-}" ]; then
    echo "${LIBCURL_DEB_SHA256}  ${deb}" | sha256sum -c -
fi

mkdir -p "${tmpdir}/extract" /usr/lib32
bsdtar -xf "${deb}" -C "${tmpdir}/extract"
cp -a "${tmpdir}/extract/usr/lib/i386-linux-gnu/libcurl-gnutls.so"* /usr/lib32/
chmod a+rX /usr/lib32/libcurl-gnutls.so*
