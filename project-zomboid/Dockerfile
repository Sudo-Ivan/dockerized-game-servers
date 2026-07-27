ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="project-zomboid" \
      org.opencontainers.image.description="Project Zomboid dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 zomboid \
  && mkdir -p /opt/zomboid/server /opt/zomboid/home /home/zomboid/steamcmd \
  && cp -a /opt/steamcmd/. /home/zomboid/steamcmd/ \
  && chown -R zomboid:zomboid /opt/zomboid /home/zomboid

ENV PZ_INSTALL_DIR="/opt/zomboid/server" \
    PZ_HOME="/opt/zomboid/home" \
    STEAM_DIR="/home/zomboid/steamcmd" \
    SteamAppId="380870"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=zomboid:zomboid --chmod=755 entrypoint.sh /home/zomboid/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${PZ_INSTALL_DIR}

EXPOSE 16261/udp 16262/udp

USER zomboid

HEALTHCHECK --interval=30s --timeout=5s --start-period=600s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGINT

ENTRYPOINT ["/docker-entrypoint.sh"]
