#!/bin/sh
# List registered servers from the shared catalog.

# shellcheck shell=sh

gs_cmd_list() {
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "id" "compose" "container" "volumes" "update_envs" "health" "first_party"
  gs_catalog_print
}
