ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE} AS fetch

ARG ETL_BUNDLE_URL="https://github.com/GameServerManagers/etlserver-build/releases/download/latest/etlegacy-latest-i386-et-260b.tar.xz"
ARG ETL_BUNDLE_MD5="283dcd02bf3f03637044792550f16b0e"

RUN ETL_BUNDLE_URL="${ETL_BUNDLE_URL}" ETL_BUNDLE_MD5="${ETL_BUNDLE_MD5}" bash -c 'set -eu; . /usr/local/bin/linuxgsm-tar-install.sh; lgsm_tar_install "${ETL_BUNDLE_URL}" "${ETL_BUNDLE_MD5}" /opt/etl' \
  && chmod -R a+rX /opt/etl \
  && chmod +x /opt/etl/etlded

ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="etl" \
      org.opencontainers.image.description="ET: Legacy dedicated server (GameServerManagers etlserver-build)" \
      org.opencontainers.image.licenses="ISC"

RUN useradd -m -u 1000 etl \
  && mkdir -p /opt/etl \
  && chown -R etl:etl /opt/etl

COPY --from=fetch --chown=etl:etl /opt/etl /usr/share/etl-seed

ENV ETL_DIR="/opt/etl" \
    ETL_SEED_DIR="/usr/share/etl-seed" \
    ETL_BUNDLE_URL="https://github.com/GameServerManagers/etlserver-build/releases/download/latest/etlegacy-latest-i386-et-260b.tar.xz" \
    ETL_BUNDLE_MD5="283dcd02bf3f03637044792550f16b0e"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=etl:etl --chmod=755 entrypoint.sh /home/etl/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${ETL_DIR}

EXPOSE 27960/udp 27961/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

USER etl

ENTRYPOINT ["/docker-entrypoint.sh"]
