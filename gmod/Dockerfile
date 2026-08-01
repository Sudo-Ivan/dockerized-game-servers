ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="gmod" \
      org.opencontainers.image.description="Garry's Mod dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 gmod \
  && mkdir -p /opt/gmod /home/gmod/steamcmd /home/gmod/Steam \
  && cp -a /opt/steamcmd/. /home/gmod/steamcmd/ \
  && chown -R gmod:gmod /opt/gmod /home/gmod

ENV GMOD_DIR="/opt/gmod" \
    STEAM_DIR="/home/gmod/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=gmod:gmod --chmod=755 entrypoint.sh /home/gmod/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${GMOD_DIR}

EXPOSE 27015/tcp 27015/udp 27005/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=900s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGINT

ENTRYPOINT ["/docker-entrypoint.sh"]
