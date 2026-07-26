# Shared runtime helpers for Minecraft server containers.

JAVA_SECURE_FLAGS="-Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -XX:+ExitOnOutOfMemoryError"

mc_validate_https_url() {
  url="$1"
  shift

  case "${url}" in
    https://*) ;;
    *)
      echo "Only https URLs are allowed: ${url}" >&2
      return 1
      ;;
  esac

  if mc_url_allowed "${url}" "$@"; then
    return 0
  fi

  echo "URL host not allowed: ${url}" >&2
  return 1
}

mc_url_allowed() {
  url="$1"
  shift

  for host in "$@"; do
    case "${url}" in
      "https://${host}/"*) return 0 ;;
      "https://${host}") return 0 ;;
    esac
  done

  return 1
}

mc_ensure_run_user() {
  MC_RUN_USER=""

  if [ -n "${PUID:-}" ] && [ -n "${PGID:-}" ]; then
    if getent group "${PGID}" >/dev/null 2>&1; then
      group_name="$(getent group "${PGID}" | cut -d: -f1)"
    else
      group_name="minecraft"
      if command -v groupadd >/dev/null 2>&1; then
        groupadd -g "${PGID}" "${group_name}" 2>/dev/null || true
      else
        addgroup -g "${PGID}" -S "${group_name}" 2>/dev/null || true
      fi
    fi

    if getent passwd "${PUID}" >/dev/null 2>&1; then
      MC_RUN_USER="$(getent passwd "${PUID}" | cut -d: -f1)"
    else
      MC_RUN_USER="minecraft"
      if command -v useradd >/dev/null 2>&1; then
        useradd -u "${PUID}" -g "${PGID}" -m "${MC_RUN_USER}" 2>/dev/null || true
      else
        adduser -u "${PUID}" -G "${group_name}" -D -H "${MC_RUN_USER}" 2>/dev/null || true
      fi
    fi
    chown -R "${PUID}:${PGID}" /data
    return 0
  fi

  if [ "$(id -u)" -eq 0 ]; then
    chown -R minecraft:minecraft /data 2>/dev/null || true
    MC_RUN_USER="minecraft"
  fi
}

mc_run_java() {
  if [ "$(id -u)" -eq 0 ] && [ -n "${MC_RUN_USER:-}" ]; then
    java_cmd="java ${JAVA_SECURE_FLAGS} ${JVM_FLAGS} $(printf '%s ' "$@")"
    exec su -s /bin/sh "${MC_RUN_USER}" -c "cd /data && PATH=\"${PATH}\" exec ${java_cmd}"
  fi

  exec java ${JAVA_SECURE_FLAGS} ${JVM_FLAGS} "$@"
}
