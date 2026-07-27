#!/bin/sh
# Backup game volume directories into a tar.gz archive.

# shellcheck shell=sh

gs_tar_backup() {
  archive="$1"
  compose="$2"
  volumes_csv="$3"
  compose_dir="${GS_ROOT}/$(gs_compose_dir "${compose}")"
  archive_dir="$(dirname "${archive}")"
  mkdir -p "${archive_dir}"

  old_ifs="${IFS}"
  IFS=','
  # shellcheck disable=SC2086
  set -- ${volumes_csv}
  IFS="${old_ifs}"

  [ "$#" -gt 0 ] || gs_die "no volumes configured for backup"

  # shellcheck disable=SC2086
  tar -C "${compose_dir}" -czf "${archive}" "$@"
}

gs_cmd_backup() {
  game="${1:-}"
  [ -n "${game}" ] || gs_die "usage: tools/gs backup <game> [dir]"
  shift
  out_root="${1:-${GS_BACKUP_DIR:-${GS_ROOT}/backups}}"

  gs_catalog_lookup "${game}"
  gs_load_repo_meta
  gs_require_cmd tar

  stamp="$(gs_timestamp)"
  archive="${out_root}/${GS_ID}/${stamp}.tar.gz"

  if [ "${GS_TEST_MODE:-0}" != "1" ]; then
    gs_require_cmd docker
    gs_log "Stopping ${GS_CONTAINER}"
    docker compose -f "${GS_ROOT}/${GS_COMPOSE}" stop
  fi

  gs_log "Creating ${archive}"
  gs_tar_backup "${archive}" "${GS_COMPOSE}" "${GS_VOLUMES}"

  if [ "${GS_TEST_MODE:-0}" != "1" ]; then
    gs_log "Starting ${GS_CONTAINER}"
    docker compose -f "${GS_ROOT}/${GS_COMPOSE}" start
  fi

  gs_log "Backup written: ${archive}"
}
