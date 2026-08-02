ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="cs-source" \
      org.opencontainers.image.description="Counter-Strike: Source dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 cssource \
  && mkdir -p /opt/cs-source /home/cssource/steamcmd /home/cssource/Steam \
  && cp -a /opt/steamcmd/. /home/cssource/steamcmd/ \
  && chown -R cssource:cssource /opt/cs-source /home/cssource

ENV CSS_DIR="/opt/cs-source" \
    STEAM_DIR="/home/cssource/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=cssource:cssource --chmod=755 entrypoint.sh /home/cssource/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${CSS_DIR}

EXPOSE 27015/tcp 27015/udp 27005/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=600s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGINT

ENTRYPOINT ["/docker-entrypoint.sh"]
