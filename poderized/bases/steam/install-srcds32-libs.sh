#!/bin/bash
# 32-bit libs required by Source srcds modules (for example replay_srv.so on TF2).
set -eu

src_dir="${1:?i386-linux-gnu source dir required}"
dest_dir="${2:-/usr/lib32}"

mkdir -p "${dest_dir}"

find "${src_dir}" -maxdepth 1 \( -type f -o -type l \) -name 'lib*.so*' \
    ! -name 'libc.so*' \
    ! -name 'libpthread.so*' \
    ! -name 'libm.so*' \
    ! -name 'libdl.so*' \
    ! -name 'librt.so*' \
    ! -name 'libresolv.so*' \
    ! -name 'libnss_*.so*' \
    -exec cp -a {} "${dest_dir}/" \;

chmod a+rX "${dest_dir}"/*.so* 2>/dev/null || true
