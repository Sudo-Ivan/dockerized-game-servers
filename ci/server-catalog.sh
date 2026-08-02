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

emit "fabric" "dockerized/minecraft/fabric/docker-compose.yml" "fabric" "data" "FABRIC_FORCE_DOWNLOAD" "tcp" "1"
emit "vanilla" "dockerized/minecraft/vanilla/docker-compose.yml" "vanilla" "data" "VANILLA_FORCE_DOWNLOAD" "tcp" "1"
emit "forge" "dockerized/minecraft/forge/docker-compose.yml" "forge" "data" "FORGE_FORCE_INSTALL" "tcp" "1"
emit "neoforge" "dockerized/minecraft/neoforge/docker-compose.yml" "neoforge" "data" "NEOFORGE_FORCE_INSTALL" "tcp" "1"
emit "valheim" "dockerized/valheim/vanilla/docker-compose.yml" "valheim" "data" "VALHEIM_FORCE_UPDATE" "process" "1"
emit "valheim-plus" "dockerized/valheim/plus/docker-compose.yml" "valheim-plus" "data" "VALHEIM_FORCE_UPDATE,VALHEIM_PLUS_FORCE_INSTALL" "process" "1"
emit "ground-branch" "dockerized/ground-branch/docker-compose.yml" "ground-branch" "data" "GB_FORCE_UPDATE" "process" "1"
emit "space-engineers" "dockerized/space-engineers/docker-compose.yml" "space-engineers" "data" "SE_FORCE_UPDATE" "process" "1"
emit "core-keeper" "dockerized/core-keeper/docker-compose.yml" "core-keeper" "data" "CK_FORCE_UPDATE" "gameid" "1"
emit "factorio" "dockerized/factorio/docker-compose.yml" "factorio" "data" "FACTORIO_FORCE_UPDATE" "process" "1"
emit "7-days-to-die" "dockerized/7-days-to-die/docker-compose.yml" "7-days-to-die" "data" "SEVENDTD_FORCE_UPDATE" "process" "1"
emit "project-zomboid" "dockerized/project-zomboid/docker-compose.yml" "project-zomboid" "data" "PZ_FORCE_UPDATE" "process" "1"
emit "terraria" "dockerized/terraria/docker-compose.yml" "terraria" "data" "TERRARIA_FORCE_UPDATE" "process" "1"
emit "l4d2" "dockerized/l4d2/docker-compose.yml" "l4d2" "data" "L4D2_FORCE_UPDATE" "process" "1"
emit "insurgency-source" "dockerized/insurgency-source/docker-compose.yml" "insurgency-source" "data" "INS_SOURCE_FORCE_UPDATE" "process" "1"
emit "insurgency-sandstorm" "dockerized/insurgency-sandstorm/docker-compose.yml" "insurgency-sandstorm" "data" "INS_SANDSTORM_FORCE_UPDATE" "process" "1"
emit "cs-source" "dockerized/cs-source/docker-compose.yml" "cs-source" "data" "CSS_FORCE_UPDATE" "process" "1"
emit "kf2" "dockerized/kf2/docker-compose.yml" "kf2" "data" "KF2_FORCE_UPDATE" "process" "1"
emit "icarus" "dockerized/icarus/docker-compose.yml" "icarus" "data" "ICARUS_FORCE_UPDATE" "process" "1"
emit "the-forest" "dockerized/the-forest/docker-compose.yml" "the-forest" "data" "FOREST_FORCE_UPDATE" "process" "1"
emit "sons-of-the-forest" "dockerized/sons-of-the-forest/docker-compose.yml" "sons-of-the-forest" "data" "SOTF_FORCE_UPDATE" "process" "1"
emit "sniper-elite-4" "dockerized/sniper-elite-4/docker-compose.yml" "sniper-elite-4" "data" "SE4_FORCE_UPDATE" "process" "1"
emit "supertuxkart" "dockerized/supertuxkart/docker-compose.yml" "supertuxkart" "data" "-" "process" "1"
emit "bf1942" "dockerized/bf1942/docker-compose.yml" "bf1942" "data" "-" "process" "1"
emit "bfv" "dockerized/bfv/docker-compose.yml" "bfv" "data" "-" "process" "1"
emit "cod" "dockerized/cod/docker-compose.yml" "cod" "data" "-" "process" "1"
emit "cod2" "dockerized/cod2/docker-compose.yml" "cod2" "data" "-" "process" "1"
emit "codwaw" "dockerized/codwaw/docker-compose.yml" "codwaw" "data" "-" "process" "1"
emit "cod4" "dockerized/cod4/docker-compose.yml" "cod4" "data" "-" "process" "1"
emit "quake3" "dockerized/quake3/docker-compose.yml" "quake3" "data" "-" "process" "1"
emit "rtcw" "dockerized/rtcw/docker-compose.yml" "rtcw" "data" "-" "process" "1"
emit "etl" "dockerized/etl/docker-compose.yml" "etl" "data" "ETL_FORCE_UPDATE" "process" "1"
emit "eco" "dockerized/eco/docker-compose.yml" "eco" "data" "ECO_FORCE_UPDATE" "process" "1"
emit "palworld" "dockerized/palworld/docker-compose.yml" "palworld" "data" "PALWORLD_FORCE_UPDATE" "process" "1"
emit "starbound" "dockerized/starbound/docker-compose.yml" "starbound" "data" "STARBOUND_FORCE_UPDATE" "process" "1"
emit "longvinter" "dockerized/longvinter/docker-compose.yml" "longvinter" "data" "LONGVINTER_FORCE_UPDATE" "process" "1"
emit "barotrauma" "dockerized/barotrauma/docker-compose.yml" "barotrauma" "data" "BAROTRAUMA_FORCE_UPDATE" "process" "1"
emit "unturned" "dockerized/unturned/docker-compose.yml" "unturned" "data" "UNTURNED_FORCE_UPDATE" "process" "1"
emit "tf2" "dockerized/tf2/docker-compose.yml" "tf2" "data" "TF2_FORCE_UPDATE" "process" "1"
emit "cs2" "dockerized/cs2/docker-compose.yml" "cs2" "data" "CS2_FORCE_UPDATE" "process" "1"
emit "dod-source" "dockerized/dod-source/docker-compose.yml" "dod-source" "data" "DOD_FORCE_UPDATE" "process" "1"
emit "gmod" "dockerized/gmod/docker-compose.yml" "gmod" "data" "GMOD_FORCE_UPDATE" "process" "1"
emit "delta-force-bhd" "dockerized/delta-force-bhd/docker-compose.yml" "delta-force-bhd" "data" "-" "process" "1"
emit "dont-starve-together" "dockerized/dont-starve-together/docker-compose.yml" "dont-starve-together" "data" "DST_FORCE_UPDATE" "process" "1"
emit "v-rising" "dockerized/v-rising/docker-compose.yml" "v-rising" "data" "VRISING_FORCE_UPDATE" "process" "1"
emit "enshrouded" "dockerized/enshrouded/docker-compose.yml" "enshrouded" "data" "ENSHROUDED_FORCE_UPDATE" "process" "1"
emit "satisfactory" "dockerized/satisfactory/docker-compose.yml" "satisfactory" "data" "SATISFACTORY_FORCE_UPDATE" "process" "1"
emit "windrose" "dockerized/windrose/docker-compose.yml" "windrose" "data" "WINDROSE_FORCE_UPDATE" "process" "1"
emit "vein" "dockerized/vein/docker-compose.yml" "vein" "data" "VEIN_FORCE_UPDATE" "process" "1"
emit "openmohaa" "dockerized/openmohaa/docker-compose.yml" "openmohaa" "data" "OPENMOHAA_FORCE_UPDATE" "process" "1"
emit "arma-3" "dockerized/arma/arma-3/docker-compose.yml" "arma3" "server,configs,profiles" "-" "process" "1"
emit "arma-reforger" "dockerized/arma/reforger/docker-compose.yml" "arma-reforger" "data" "ARMAR_FORCE_UPDATE" "process" "1"
emit "dayz" "dockerized/dayz/docker-compose.yml" "dayz" "data" "DAYZ_FORCE_UPDATE" "process" "1"
emit "hytale" "dockerized/hytale/docker-compose.yml" "hytale-server" "data" "-" "none" "0"
emit "stardew-valley" "dockerized/stardew-valley/docker-compose.yml" "stardew-valley-server" "data" "-" "none" "0"
emit "azerothcore" "dockerized/azerothcore/docker-compose.yml" "azerothcore-worldserver" "data" "-" "none" "0"
