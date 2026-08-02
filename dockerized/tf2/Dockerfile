ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="tf2" \
      org.opencontainers.image.description="Team Fortress 2 dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 tf2 \
  && mkdir -p /opt/tf2 /home/tf2/steamcmd /home/tf2/Steam \
  && cp -a /opt/steamcmd/. /home/tf2/steamcmd/ \
  && chown -R tf2:tf2 /opt/tf2 /home/tf2

ENV TF2_DIR="/opt/tf2" \
    STEAM_DIR="/home/tf2/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=tf2:tf2 --chmod=755 entrypoint.sh /home/tf2/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${TF2_DIR}

EXPOSE 27015/tcp 27015/udp 27005/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=600s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGINT

ENTRYPOINT ["/docker-entrypoint.sh"]
