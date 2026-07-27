#!/bin/sh
# Print unique directory roots that may contain shell scripts.
# Fixed roots plus dirname of each catalog compose path and image-matrix context.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

printf '%s\n' ci tools bases

./ci/server-catalog.sh | while IFS="$(printf '\t')" read -r id compose _container _volumes _update_envs _health _first_party; do
  [ -n "${id}" ] || continue
  dirname "${compose}"
done

./ci/image-matrix.sh | while IFS="$(printf '\t')" read -r name context dockerfile _base; do
  [ -n "${name}" ] || continue
  printf '%s\n' "${context}"
  dirname "${dockerfile}"
done
