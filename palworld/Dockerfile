ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="palworld" \
      org.opencontainers.image.description="Palworld dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Sy --noconfirm --needed \
    icu \
    openssl \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 palworld \
  && mkdir -p /opt/palworld /home/palworld/steamcmd \
  && cp -a /opt/steamcmd/. /home/palworld/steamcmd/ \
  && chown -R palworld:palworld /opt/palworld /home/palworld

ENV PALWORLD_DIR="/opt/palworld" \
    STEAM_DIR="/home/palworld/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=palworld:palworld --chmod=755 entrypoint.sh /home/palworld/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${PALWORLD_DIR}

EXPOSE 8211/udp

USER palworld

HEALTHCHECK --interval=30s --timeout=5s --start-period=900s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
