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
emit "space-engineers" "space-engineers/docker-compose.yml" "space-engineers" "data" "SE_FORCE_UPDATE" "process" "1"
emit "core-keeper" "core-keeper/docker-compose.yml" "core-keeper" "data" "CK_FORCE_UPDATE" "gameid" "1"
emit "factorio" "factorio/docker-compose.yml" "factorio" "data" "FACTORIO_FORCE_UPDATE" "process" "1"
emit "7-days-to-die" "7-days-to-die/docker-compose.yml" "7-days-to-die" "data" "SEVENDTD_FORCE_UPDATE" "process" "1"
emit "project-zomboid" "project-zomboid/docker-compose.yml" "project-zomboid" "data" "PZ_FORCE_UPDATE" "process" "1"
emit "terraria" "terraria/docker-compose.yml" "terraria" "data" "TERRARIA_FORCE_UPDATE" "process" "1"
emit "l4d2" "l4d2/docker-compose.yml" "l4d2" "data" "L4D2_FORCE_UPDATE" "process" "1"
emit "insurgency-source" "insurgency-source/docker-compose.yml" "insurgency-source" "data" "INS_SOURCE_FORCE_UPDATE" "process" "1"
emit "insurgency-sandstorm" "insurgency-sandstorm/docker-compose.yml" "insurgency-sandstorm" "data" "INS_SANDSTORM_FORCE_UPDATE" "process" "1"
emit "palworld" "palworld/docker-compose.yml" "palworld" "data" "PALWORLD_FORCE_UPDATE" "process" "1"
emit "starbound" "starbound/docker-compose.yml" "starbound" "data" "STARBOUND_FORCE_UPDATE" "process" "1"
emit "openmohaa" "openmohaa/docker-compose.yml" "openmohaa" "data" "OPENMOHAA_FORCE_UPDATE" "process" "1"
emit "arma-3" "arma/arma-3/docker-compose.yml" "arma3" "server,configs,profiles" "-" "process" "1"
emit "hytale" "hytale/docker-compose.yml" "hytale-server" "data" "-" "none" "0"
emit "stardew-valley" "stardew-valley/docker-compose.yml" "stardew-valley-server" "data" "-" "none" "0"
