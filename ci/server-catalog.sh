#!/bin/sh
# Runnable server catalog for CI and tools.
# Prints one TSV line per server:
#   id  compose  container  volumes  update_envs  health  first_party
#
# volumes / update_envs are comma-separated (empty update_envs allowed).
# health: tcp | process | gameid | none
# first_party: 1 = image we build, 0 = external

set -eu

emit() {
  id="$1"
  compose="$2"
  container="$3"
  volumes="$4"
  update_envs="$5"
  health="$6"
  first_party="$7"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "${id}" "${compose}" "${container}" "${volumes}" "${update_envs}" "${health}" "${first_party}"
}

emit "fabric" "minecraft/fabric/docker-compose.yml" "fabric" "data" "FABRIC_FORCE_DOWNLOAD" "tcp" "1"
emit "vanilla" "minecraft/vanilla/docker-compose.yml" "vanilla" "data" "VANILLA_FORCE_DOWNLOAD" "tcp" "1"
emit "forge" "minecraft/forge/docker-compose.yml" "forge" "data" "FORGE_FORCE_INSTALL" "tcp" "1"
emit "valheim" "valheim/vanilla/docker-compose.yml" "valheim" "data" "VALHEIM_FORCE_UPDATE" "process" "1"
emit "valheim-plus" "valheim/plus/docker-compose.yml" "valheim-plus" "data" "VALHEIM_FORCE_UPDATE,VALHEIM_PLUS_FORCE_INSTALL" "process" "1"
emit "ground-branch" "ground-branch/docker-compose.yml" "ground-branch" "data" "GB_FORCE_UPDATE" "process" "1"
emit "core-keeper" "core-keeper/docker-compose.yml" "core-keeper" "data" "CK_FORCE_UPDATE" "gameid" "1"
emit "factorio" "factorio/docker-compose.yml" "factorio" "data" "FACTORIO_FORCE_UPDATE" "process" "1"
emit "openmohaa" "openmohaa/docker-compose.yml" "openmohaa" "data" "OPENMOHAA_FORCE_UPDATE" "process" "1"
emit "arma-3" "arma/arma-3/docker-compose.yml" "arma3" "server,configs,profiles" "" "process" "1"
emit "hytale" "hytale/docker-compose.yml" "hytale-server" "data" "" "none" "0"
