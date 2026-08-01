ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="barotrauma" \
      org.opencontainers.image.description="Barotrauma dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Sy --noconfirm --needed \
    icu \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 barotrauma \
  && mkdir -p /opt/barotrauma /home/barotrauma/steamcmd /home/barotrauma/Steam \
  && cp -a /opt/steamcmd/. /home/barotrauma/steamcmd/ \
  && chown -R barotrauma:barotrauma /opt/barotrauma /home/barotrauma

ENV BAROTRAUMA_DIR="/opt/barotrauma" \
    STEAM_DIR="/home/barotrauma/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=barotrauma:barotrauma --chmod=755 entrypoint.sh /home/barotrauma/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${BAROTRAUMA_DIR}

EXPOSE 27015/udp 27016/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=600s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
