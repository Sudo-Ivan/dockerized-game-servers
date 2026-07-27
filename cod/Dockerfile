ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE} AS fetch

RUN LGSM_URL="http://linuxgsm.download/CallOfDuty/cod-lnxded-1.5b-full.tar.xz" \
    LGSM_MD5="ee0ad1ccbfa1fd27fde01a4a431a5c2f" \
    bash -c 'set -eu; . /usr/local/bin/linuxgsm-tar-install.sh; lgsm_tar_install "${LGSM_URL}" "${LGSM_MD5}" /opt/cod' \
  && chmod -R a+rX /opt/cod \
  && chmod +x /opt/cod/cod_lnxded

ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="cod" \
      org.opencontainers.image.description="Call of Duty dedicated server (LinuxGSM files)" \
      org.opencontainers.image.licenses="ISC"

RUN useradd -m -u 1000 cod \
  && mkdir -p /opt/cod \
  && chown -R cod:cod /opt/cod

COPY --from=fetch --chown=cod:cod /opt/cod /usr/share/cod-seed

ENV COD_DIR="/opt/cod" \
    COD_SEED_DIR="/usr/share/cod-seed"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=cod:cod --chmod=755 entrypoint.sh /home/cod/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${COD_DIR}

EXPOSE 28960/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

USER cod

ENTRYPOINT ["/docker-entrypoint.sh"]
