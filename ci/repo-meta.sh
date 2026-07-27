#!/bin/sh
# Resolve repository identity without hardcoding owner or name.
# Usage:
#   eval "$(./ci/repo-meta.sh)"
#   ./ci/repo-meta.sh --print
#
# Env overrides (highest priority):
#   GITHUB_REPOSITORY  owner/repo (GitHub Actions sets this)
#   IMAGE_OWNER        owner/repo for GHCR (defaults to GITHUB_REPOSITORY)
#   SITE_URL           full Pages origin (example: https://owner.github.io)
#   SITE_BASE          Pages base path (example: /repo)
#   GITHUB_SERVER_URL  defaults to https://github.com

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"

github_server_url="${GITHUB_SERVER_URL:-https://github.com}"
github_server_url="${github_server_url%/}"

repo="${GITHUB_REPOSITORY:-}"

if [ -z "${repo}" ] && command -v git >/dev/null 2>&1; then
  remote="$(git -C "${ROOT}" remote get-url origin 2>/dev/null || true)"
  case "${remote}" in
    git@*:* )
      repo="${remote#*:}"
      repo="${repo%.git}"
      ;;
    https://*/*|http://*/*|ssh://*/*)
      repo="${remote#*://}"
      repo="${repo#*/}"
      repo="${repo%.git}"
      ;;
  esac
fi

if [ -z "${repo}" ]; then
  echo "Unable to resolve repository as owner/repo." >&2
  echo "Set GITHUB_REPOSITORY or configure git remote origin." >&2
  exit 1
fi

owner="${repo%%/*}"
name="${repo#*/}"

if [ -z "${owner}" ] || [ -z "${name}" ] || [ "${owner}" = "${repo}" ]; then
  echo "Invalid repository value: ${repo}" >&2
  exit 1
fi

# GHCR paths are lowercase.
image_owner="$(printf '%s' "${IMAGE_OWNER:-${repo}}" | tr '[:upper:]' '[:lower:]')"
image_prefix="ghcr.io/${image_owner}"
github_url="${github_server_url}/${repo}"
pages_owner="$(printf '%s' "${owner}" | tr '[:upper:]' '[:lower:]')"
site_url="${SITE_URL:-https://${pages_owner}.github.io}"
site_base="${SITE_BASE:-/${name}}"
docs_url="${site_url}${site_base}/"

print_meta() {
  printf 'REPO=%s\n' "${repo}"
  printf 'OWNER=%s\n' "${owner}"
  printf 'NAME=%s\n' "${name}"
  printf 'IMAGE_OWNER=%s\n' "${image_owner}"
  printf 'IMAGE_PREFIX=%s\n' "${image_prefix}"
  printf 'GITHUB_URL=%s\n' "${github_url}"
  printf 'SITE_URL=%s\n' "${site_url}"
  printf 'SITE_BASE=%s\n' "${site_base}"
  printf 'DOCS_URL=%s\n' "${docs_url}"
}

case "${1:-}" in
  --print|"")
    print_meta
    ;;
  *)
    echo "Usage: $0 [--print]" >&2
    exit 2
    ;;
esac
