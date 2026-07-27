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
  while IFS="$(printf '\t')" read -r id compose container volumes update_envs health first_party; do
    [ -n "${id}" ] || continue
    if [ "${id}" = "${want}" ]; then
      GS_ID="${id}"
      GS_COMPOSE="${compose}"
      GS_CONTAINER="${container}"
      GS_VOLUMES="${volumes}"
      GS_UPDATE_ENVS="${update_envs}"
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
