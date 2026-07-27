ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="eco" \
      org.opencontainers.image.description="Eco dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 eco \
  && mkdir -p /opt/eco /home/eco/steamcmd /home/eco/Steam \
  && cp -a /opt/steamcmd/. /home/eco/steamcmd/ \
  && chown -R eco:eco /opt/eco /home/eco

ENV ECO_DIR="/opt/eco" \
    STEAM_DIR="/home/eco/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=eco:eco --chmod=755 entrypoint.sh /home/eco/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${ECO_DIR}

EXPOSE 3000/udp 3001/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=900s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

USER eco

ENTRYPOINT ["/docker-entrypoint.sh"]
