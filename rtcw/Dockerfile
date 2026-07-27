ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE} AS fetch

RUN LGSM_URL="http://linuxgsm.download/ReturnToCastleWolfenstein/iortcw-1.51c-x86_64-server-linux-20190507.tar.xz" \
    LGSM_MD5="df6ff664d37dd0d22787848bdb3cac5f" \
    bash -c 'set -eu; . /usr/local/bin/linuxgsm-tar-install.sh; lgsm_tar_install "${LGSM_URL}" "${LGSM_MD5}" /opt/rtcw' \
  && chmod -R a+rX /opt/rtcw \
  && chmod +x /opt/rtcw/iowolfded.x86_64

ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="rtcw" \
      org.opencontainers.image.description="Return to Castle Wolfenstein dedicated server (ioRTCW / LinuxGSM files)" \
      org.opencontainers.image.licenses="ISC"

RUN useradd -m -u 1000 rtcw \
  && mkdir -p /opt/rtcw \
  && chown -R rtcw:rtcw /opt/rtcw

COPY --from=fetch --chown=rtcw:rtcw /opt/rtcw /usr/share/rtcw-seed

ENV RTCW_DIR="/opt/rtcw" \
    RTCW_SEED_DIR="/usr/share/rtcw-seed"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=rtcw:rtcw --chmod=755 entrypoint.sh /home/rtcw/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${RTCW_DIR}

EXPOSE 27960/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

USER rtcw

ENTRYPOINT ["/docker-entrypoint.sh"]
