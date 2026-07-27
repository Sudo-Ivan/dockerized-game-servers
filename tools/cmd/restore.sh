#!/bin/sh
# Restore game volume directories from a tar.gz archive.

# shellcheck shell=sh

gs_cmd_restore() {
  game="${1:-}"
  archive="${2:-}"
  [ -n "${game}" ] && [ -n "${archive}" ] || gs_die "usage: tools/gs restore <game> <archive>"

  gs_catalog_lookup "${game}"
  gs_load_repo_meta
  gs_require_cmd tar

  case "${archive}" in
    /*) ;;
    *) archive="${PWD}/${archive}" ;;
  esac
  [ -f "${archive}" ] || gs_die "archive not found: ${archive}"

  compose_dir="$(gs_compose_dir "${GS_COMPOSE}")"
  compose_abs="${GS_ROOT}/${compose_dir}"

  if [ "${GS_TEST_MODE:-0}" != "1" ]; then
    gs_require_cmd docker
    gs_log "Stopping ${GS_CONTAINER}"
    docker compose -f "${GS_ROOT}/${GS_COMPOSE}" stop
  fi

  old_ifs="${IFS}"
  IFS=','
  # shellcheck disable=SC2086
  set -- ${GS_VOLUMES}
  IFS="${old_ifs}"
  for vol in "$@"; do
    [ -n "${vol}" ] || continue
    mkdir -p "${compose_abs}/${vol}"
  done

  gs_log "Extracting ${archive} into ${compose_abs}"
  tar -C "${compose_abs}" -xzf "${archive}"

  if [ "${GS_TEST_MODE:-0}" != "1" ]; then
    gs_log "Starting ${GS_CONTAINER}"
    docker compose -f "${GS_ROOT}/${GS_COMPOSE}" start
  fi

  gs_log "Restore complete for ${GS_ID}"
}
