ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="satisfactory" \
      org.opencontainers.image.description="Satisfactory dedicated server (native Linux)" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Sy --noconfirm --needed icu openssl \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 satisfactory \
  && mkdir -p /opt/satisfactory /home/satisfactory/steamcmd /home/satisfactory/Steam \
  && cp -a /opt/steamcmd/. /home/satisfactory/steamcmd/ \
  && chown -R satisfactory:satisfactory /opt/satisfactory /home/satisfactory

ENV SATISFACTORY_DIR="/opt/satisfactory" \
    STEAM_DIR="/home/satisfactory/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=satisfactory:satisfactory --chmod=755 entrypoint.sh /home/satisfactory/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${SATISFACTORY_DIR}

EXPOSE 7777/tcp 7777/udp 8888/tcp

HEALTHCHECK --interval=30s --timeout=5s --start-period=900s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
