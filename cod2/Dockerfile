ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE} AS fetch

RUN LGSM_URL="http://linuxgsm.download/CallOfDuty2/cod2-lnxded-1.3-full.tar.xz" \
    LGSM_MD5="b8c4c611f01627dd43348e78478a3d41" \
    bash -c 'set -eu; . /usr/local/bin/linuxgsm-tar-install.sh; lgsm_tar_install "${LGSM_URL}" "${LGSM_MD5}" /opt/cod2' \
  && chmod -R a+rX /opt/cod2 \
  && chmod +x /opt/cod2/cod2_lnxded

ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="cod2" \
      org.opencontainers.image.description="Call of Duty 2 dedicated server (LinuxGSM files)" \
      org.opencontainers.image.licenses="ISC"

RUN useradd -m -u 1000 cod2 \
  && mkdir -p /opt/cod2 \
  && chown -R cod2:cod2 /opt/cod2

COPY --from=fetch --chown=cod2:cod2 /opt/cod2 /usr/share/cod2-seed

ENV COD2_DIR="/opt/cod2" \
    COD2_SEED_DIR="/usr/share/cod2-seed"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=cod2:cod2 --chmod=755 entrypoint.sh /home/cod2/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${COD2_DIR}

EXPOSE 28960/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

USER cod2

ENTRYPOINT ["/docker-entrypoint.sh"]
