ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="arma-reforger" \
      org.opencontainers.image.description="Arma Reforger dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Sy --noconfirm --needed \
    curl \
    openssl \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 armar \
  && mkdir -p /opt/arma-reforger /home/armar/steamcmd /home/armar/Steam \
  && cp -a /opt/steamcmd/. /home/armar/steamcmd/ \
  && chown -R armar:armar /opt/arma-reforger /home/armar

ENV ARMAR_DIR="/opt/arma-reforger" \
    STEAM_DIR="/home/armar/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=armar:armar --chmod=755 entrypoint.sh /home/armar/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${ARMAR_DIR}

EXPOSE 2001/udp 17777/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=1200s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

USER armar

ENTRYPOINT ["/docker-entrypoint.sh"]
