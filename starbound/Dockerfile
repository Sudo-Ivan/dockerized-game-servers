ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="starbound" \
      org.opencontainers.image.description="Starbound dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 starbound \
  && mkdir -p /opt/starbound /home/starbound/steamcmd \
  && cp -a /opt/steamcmd/. /home/starbound/steamcmd/ \
  && chown -R starbound:starbound /opt/starbound /home/starbound

ENV STARBOUND_DIR="/opt/starbound" \
    STEAM_DIR="/home/starbound/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=starbound:starbound --chmod=755 entrypoint.sh /home/starbound/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${STARBOUND_DIR}

EXPOSE 21025/tcp

HEALTHCHECK --interval=30s --timeout=5s --start-period=600s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
