ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="valheim" \
      org.opencontainers.image.description="Valheim dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Sy --noconfirm --needed \
    libpulse \
    alsa-lib \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 valheim \
  && mkdir -p /opt/valheim /home/valheim/steamcmd \
  && cp -a /opt/steamcmd/. /home/valheim/steamcmd/ \
  && chown -R valheim:valheim /opt/valheim /home/valheim

ENV VALHEIM_DIR="/opt/valheim" \
    STEAM_DIR="/home/valheim/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=valheim:valheim --chmod=755 entrypoint.sh /home/valheim/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${VALHEIM_DIR}

EXPOSE 2456/udp 2457/udp 2458/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=300s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
