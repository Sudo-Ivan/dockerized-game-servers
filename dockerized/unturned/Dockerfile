ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="unturned" \
      org.opencontainers.image.description="Unturned dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 unturned \
  && mkdir -p /opt/unturned /home/unturned/steamcmd /home/unturned/Steam \
  && cp -a /opt/steamcmd/. /home/unturned/steamcmd/ \
  && chown -R unturned:unturned /opt/unturned /home/unturned

ENV UNTURNED_DIR="/opt/unturned" \
    STEAM_DIR="/home/unturned/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=unturned:unturned --chmod=755 entrypoint.sh /home/unturned/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${UNTURNED_DIR}

EXPOSE 27015/udp 27016/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=600s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
