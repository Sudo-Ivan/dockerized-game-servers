#!/bin/sh
# Catalog accessors for tools/gs.

# shellcheck shell=sh

gs_catalog_print() {
  "${GS_ROOT}/ci/server-catalog.sh"
}

# Sets GS_ID GS_COMPOSE GS_CONTAINER GS_VOLUMES GS_UPDATE_ENVS GS_HEALTH GS_FIRST_PARTY
gs_catalog_lookup() {
  want="$1"
  found=0
  while IFS= read -r line || [ -n "${line}" ]; do
    [ -n "${line}" ] || continue
    id="$(printf '%s\n' "${line}" | awk -F'\t' '{print $1}')"
    compose="$(printf '%s\n' "${line}" | awk -F'\t' '{print $2}')"
    container="$(printf '%s\n' "${line}" | awk -F'\t' '{print $3}')"
    volumes="$(printf '%s\n' "${line}" | awk -F'\t' '{print $4}')"
    update_envs="$(printf '%s\n' "${line}" | awk -F'\t' '{print $5}')"
    health="$(printf '%s\n' "${line}" | awk -F'\t' '{print $6}')"
    first_party="$(printf '%s\n' "${line}" | awk -F'\t' '{print $7}')"
    [ -n "${id}" ] || continue
    if [ "${id}" = "${want}" ]; then
      GS_ID="${id}"
      GS_COMPOSE="${compose}"
      GS_CONTAINER="${container}"
      GS_VOLUMES="${volumes}"
      if [ "${update_envs}" = "-" ]; then
        GS_UPDATE_ENVS=""
      else
        GS_UPDATE_ENVS="${update_envs}"
      fi
      GS_HEALTH="${health}"
      GS_FIRST_PARTY="${first_party}"
      found=1
      break
    fi
  done <<EOF
$(gs_catalog_print)
EOF
  [ "${found}" -eq 1 ] || gs_die "unknown game id: ${want}"
}
