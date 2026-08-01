#!/bin/bash
# Legacy i386 (and matching amd64) libs for LinuxGSM-era game server binaries.
set -eu

# shellcheck source=bases/runtime/http-download.sh
. "$(dirname "$0")/http-download.sh"

DEB_MIRROR="${DEB_MIRROR:-http://deb.debian.org/debian/pool/main}"

fetch_install() {
    local relpath="${1:?}"
    local deb
    deb="$(mktemp)"
    http_download_file "${DEB_MIRROR}/${relpath}" "${deb}"
    dpkg -i "${deb}" || apt-get install -yf --no-install-recommends
    rm -f "${deb}"
}

fetch_install "g/gcc-3.3/libstdc++5_3.3.6-34_i386.deb"
fetch_install "n/ncurses/libtinfo5_6.4-4_i386.deb"
fetch_install "n/ncurses/libncurses5_6.4-4_i386.deb"
fetch_install "g/gcc-3.3/libstdc++5_3.3.6-34_amd64.deb"
fetch_install "n/ncurses/libtinfo5_6.4-4_amd64.deb"
fetch_install "n/ncurses/libncurses5_6.4-4_amd64.deb"
