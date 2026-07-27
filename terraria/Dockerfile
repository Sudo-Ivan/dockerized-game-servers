ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="terraria" \
      org.opencontainers.image.description="Terraria dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 terraria \
  && mkdir -p /opt/terraria /home/terraria/steamcmd \
  && cp -a /opt/steamcmd/. /home/terraria/steamcmd/ \
  && chown -R terraria:terraria /opt/terraria /home/terraria

ENV TERRARIA_DIR="/opt/terraria" \
    STEAM_DIR="/home/terraria/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=terraria:terraria --chmod=755 entrypoint.sh /home/terraria/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${TERRARIA_DIR}

EXPOSE 7777/tcp

USER terraria

HEALTHCHECK --interval=30s --timeout=5s --start-period=300s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
