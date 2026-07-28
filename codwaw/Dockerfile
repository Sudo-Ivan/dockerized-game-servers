ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE} AS fetch

RUN LGSM_URL="http://linuxgsm.download/CallOfDutyWorldAtWar/codwaw-lnxded-1.7-full.tar.xz" \
    LGSM_MD5="2c6be1bb66ea631b9b2e7ae6216c6680" \
    bash -c 'set -eu; . /usr/local/bin/linuxgsm-tar-install.sh; lgsm_tar_install "${LGSM_URL}" "${LGSM_MD5}" /opt/codwaw' \
  && chmod -R a+rX /opt/codwaw \
  && chmod +x /opt/codwaw/codwaw_lnxded

ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="codwaw" \
      org.opencontainers.image.description="Call of Duty: World at War dedicated server (LinuxGSM files)" \
      org.opencontainers.image.licenses="ISC"

RUN useradd -m -u 1000 codwaw \
  && mkdir -p /opt/codwaw \
  && chown -R codwaw:codwaw /opt/codwaw

COPY --from=fetch --chown=codwaw:codwaw /opt/codwaw /usr/share/codwaw-seed

ENV CODWAW_DIR="/opt/codwaw" \
    CODWAW_SEED_DIR="/usr/share/codwaw-seed"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=codwaw:codwaw --chmod=755 entrypoint.sh /home/codwaw/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${CODWAW_DIR}

EXPOSE 28960/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
