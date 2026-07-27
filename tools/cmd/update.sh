#!/bin/sh
# One-shot game binary/content update via FORCE_* env overrides.

# shellcheck shell=sh

gs_cmd_update() {
  game=""
  do_backup=0
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --backup)
        do_backup=1
        shift
        ;;
      -*)
        gs_die "unknown option: $1"
        ;;
      *)
        if [ -n "${game}" ]; then
          gs_die "usage: tools/gs update <game> [--backup]"
        fi
        game="$1"
        shift
        ;;
    esac
  done
  [ -n "${game}" ] || gs_die "usage: tools/gs update <game> [--backup]"

  gs_catalog_lookup "${game}"
  gs_load_repo_meta

  if [ -z "${GS_UPDATE_ENVS}" ]; then
    gs_die "${GS_ID} has no update_envs in the server catalog"
  fi

  if [ "${do_backup}" -eq 1 ]; then
    gs_cmd_backup "${GS_ID}"
  fi

  old_ifs="${IFS}"
  IFS=','
  # shellcheck disable=SC2086
  set -- ${GS_UPDATE_ENVS}
  IFS="${old_ifs}"

  export_args=""
  for env_name in "$@"; do
    [ -n "${env_name}" ] || continue
    export_args="${export_args}${env_name}=true "
    # Export for compose variable substitution
    # shellcheck disable=SC2086
    eval "export ${env_name}=true"
  done

  if [ "${GS_DRY_RUN:-0}" = "1" ] || [ "${GS_TEST_MODE:-0}" = "1" ]; then
    gs_log "DRY RUN update ${GS_ID}: ${export_args}docker compose -f ${GS_COMPOSE} up -d --force-recreate"
    return 0
  fi

  gs_require_cmd docker
  gs_log "Updating ${GS_ID} (${export_args})"
  docker compose -f "${GS_ROOT}/${GS_COMPOSE}" up -d --force-recreate

  # Wait briefly for healthy when Docker reports health
  tries=0
  max_tries=60
  while [ "${tries}" -lt "${max_tries}" ]; do
    status="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "${GS_CONTAINER}" 2>/dev/null || true)"
    case "${status}" in
      healthy|running)
        if [ "${status}" = "healthy" ] || [ "${tries}" -ge 5 ]; then
          # Prefer healthy; if no healthcheck, accept running after a short delay
          if [ "${status}" = "healthy" ]; then
            gs_log "Container ${GS_CONTAINER} is healthy"
            return 0
          fi
        fi
        ;;
      unhealthy)
        gs_die "container ${GS_CONTAINER} became unhealthy during update"
        ;;
      *)
        ;;
    esac
    tries=$((tries + 1))
    sleep 5
  done

  # No HEALTHCHECK images still count as success if running
  status="$(docker inspect --format '{{.State.Status}}' "${GS_CONTAINER}" 2>/dev/null || true)"
  [ "${status}" = "running" ] || gs_die "update timed out waiting for ${GS_CONTAINER} (status=${status})"
  gs_log "Container ${GS_CONTAINER} is running"
}
