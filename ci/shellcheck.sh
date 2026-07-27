#!/bin/sh
# Run ShellCheck across catalog-discovered script roots.

set -eu

ROOT="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck not installed" >&2
  exit 1
fi

tmp="$(mktemp)"
roots_tmp="$(mktemp)"
./ci/script-roots.sh | sort -u >"${roots_tmp}"
while IFS= read -r root; do
  [ -n "${root}" ] || continue
  [ -d "${root}" ] || continue
  find "${root}" \( -path '*/data/*' -o -path '*/node_modules/*' \) -prune -o -type f \( \
    -name '*.sh' -o -name 'entrypoint.sh' -o -name 'docker-entrypoint.sh' -o -name 'runtime.sh' \
  \) -print >>"${tmp}" 2>/dev/null || true
done <"${roots_tmp}"
if [ -f tools/gs ]; then
  printf '%s\n' tools/gs >>"${tmp}"
fi
rm -f "${roots_tmp}"

sort -u "${tmp}" -o "${tmp}"
printf '%s\n' bases/steam/steamcmd-app-update.sh bases/runtime/linuxgsm-tar-install.sh bases/runtime/install-legacy32-libs.sh >>"${tmp}"
sort -u "${tmp}" -o "${tmp}"
fail=0
while IFS= read -r script; do
  [ -f "${script}" ] || continue
  # Sourced by tools/gs; checked via -x on the dispatcher
  case "${script}" in
    tools/lib/*|tools/cmd/*)
      continue
      ;;
  esac
  # SC1007: intentional CDPATH='' / CDPATH= clear idiom used repo-wide
  # SC1091: entrypoints source /opt/steamcmd/steamcmd-app-update.sh (exists in steam-base image only)
  sc_exclude="SC1007"
  if grep -q '/opt/steamcmd/steamcmd-app-update.sh' "${script}" 2>/dev/null; then
    sc_exclude="${sc_exclude},SC1091"
  fi
  if grep -q 'linuxgsm-tar-install.sh' "${script}" 2>/dev/null; then
    sc_exclude="${sc_exclude},SC1091"
  fi
  if ! shellcheck -x -e "${sc_exclude}" "${script}"; then
    echo "shellcheck failed: ${script}" >&2
    fail=1
  fi
done <"${tmp}"
rm -f "${tmp}"

if [ "${fail}" -ne 0 ]; then
  exit 1
fi

echo "shellcheck ok"
