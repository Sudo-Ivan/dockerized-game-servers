#!/bin/sh
# Resolve image matrix rows for CI.
# Prints one TSV line per image: name context dockerfile base_name_or_empty

set -eu

emit() {
  name="$1"
  context="$2"
  dockerfile="$3"
  base="${4:-}"
  printf '%s\t%s\t%s\t%s\n' "${name}" "${context}" "${dockerfile}" "${base}"
}

emit "minecraft-base" "bases/minecraft" "bases/minecraft/Dockerfile" ""
emit "steam-base" "bases/steam" "bases/steam/Dockerfile" ""

emit "minecraft-fabric" "minecraft" "minecraft/fabric/Dockerfile" "minecraft-base"
emit "minecraft-vanilla" "minecraft" "minecraft/vanilla/Dockerfile" "minecraft-base"
emit "minecraft-forge" "minecraft" "minecraft/forge/Dockerfile" "minecraft-base"

emit "valheim" "valheim/vanilla" "valheim/vanilla/Dockerfile" "steam-base"
emit "valheim-plus" "valheim/plus" "valheim/plus/Dockerfile" "steam-base"
emit "ground-branch" "ground-branch" "ground-branch/Dockerfile" "steam-base"
emit "core-keeper" "core-keeper" "core-keeper/Dockerfile" "steam-base"
emit "factorio" "factorio" "factorio/Dockerfile" "steam-base"
emit "arma-3" "arma/arma-3" "arma/arma-3/Dockerfile" "steam-base"
