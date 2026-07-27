ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="factorio" \
      org.opencontainers.image.description="Factorio dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN useradd -m -u 1000 factorio \
  && mkdir -p /opt/factorio \
  && chown -R factorio:factorio /opt/factorio /home/factorio

ENV FACTORIO_DIR="/opt/factorio" \
    FACTORIO_VERSION="stable"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=factorio:factorio --chmod=755 entrypoint.sh /home/factorio/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${FACTORIO_DIR}

EXPOSE 34197/udp 27015/tcp

HEALTHCHECK --interval=30s --timeout=5s --start-period=300s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
