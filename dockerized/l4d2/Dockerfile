ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="l4d2" \
      org.opencontainers.image.description="Left 4 Dead 2 dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 l4d2 \
  && mkdir -p /opt/l4d2 /home/l4d2/steamcmd \
  && cp -a /opt/steamcmd/. /home/l4d2/steamcmd/ \
  && chown -R l4d2:l4d2 /opt/l4d2 /home/l4d2

ENV L4D2_DIR="/opt/l4d2" \
    STEAM_DIR="/home/l4d2/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=l4d2:l4d2 --chmod=755 entrypoint.sh /home/l4d2/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${L4D2_DIR}

EXPOSE 27015/tcp 27015/udp 27005/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=600s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGINT

ENTRYPOINT ["/docker-entrypoint.sh"]
