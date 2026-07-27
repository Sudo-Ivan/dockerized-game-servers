ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="the-forest" \
      org.opencontainers.image.description="The Forest dedicated server (native Linux)" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 theforest \
  && mkdir -p /opt/theforest /home/theforest/steamcmd \
  && cp -a /opt/steamcmd/. /home/theforest/steamcmd/ \
  && chown -R theforest:theforest /opt/theforest /home/theforest

ENV FOREST_DIR="/opt/theforest" \
    STEAM_DIR="/home/theforest/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=theforest:theforest --chmod=755 entrypoint.sh /home/theforest/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${FOREST_DIR}

EXPOSE 8766/tcp 8766/udp 27015/tcp 27015/udp 27016/tcp 27016/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=300s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
