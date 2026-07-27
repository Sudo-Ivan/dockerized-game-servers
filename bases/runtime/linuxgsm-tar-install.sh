#!/bin/bash
# Fetch and verify LinuxGSM-hosted server archives (same URLs as LinuxGSM install_server_files.sh).
set -eu

lgsm_tar_install() {
    local url="${1:?url required}"
    local expected_md5="${2:?md5 required}"
    local dest="${3:?dest required}"
    local archive
    archive="$(mktemp)"

    curl -fsSL --retry 3 --retry-delay 2 "${url}" -o "${archive}"
    if ! echo "${expected_md5}  ${archive}" | md5sum -c -; then
        echo "LGSM archive md5 mismatch for ${url}" >&2
        rm -f "${archive}"
        return 1
    fi

    mkdir -p "${dest}"
    case "${archive}" in
        *.tar.xz)
            tar -xJf "${archive}" -C "${dest}"
            ;;
        *.tar.gz)
            tar -xzf "${archive}" -C "${dest}"
            ;;
        *)
            tar -xf "${archive}" -C "${dest}"
            ;;
    esac
    rm -f "${archive}"
}

# Copy baked image seed into the data volume once (retries after interrupted copies).
lgsm_volume_seed() {
    local dir="${1:?dir required}"
    local seed="${2:?seed required}"
    local marker_file="${3:?marker file name required}"

    if [ -f "${dir}/.lgsm-seed-complete" ] && [ -e "${dir}/${marker_file}" ]; then
        return 0
    fi

    echo "--- Seeding server files into ${dir} ---"
    mkdir -p "${dir}"
    shopt -s dotglob nullglob
    local item base
    for item in "${dir}"/*; do
        [ -e "${item}" ] || continue
        base="$(basename "${item}")"
        if [ "${base}" = ".gitkeep" ]; then
            continue
        fi
        rm -rf "${item}"
    done
    shopt -u dotglob nullglob

    cp -a "${seed}/." "${dir}/"
    touch "${dir}/.lgsm-seed-complete"
}
