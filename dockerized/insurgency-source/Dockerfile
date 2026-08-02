ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="insurgency-source" \
      org.opencontainers.image.description="Insurgency (Source) dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 inssource \
  && mkdir -p /opt/insurgency-source /home/inssource/steamcmd /home/inssource/Steam \
  && cp -a /opt/steamcmd/. /home/inssource/steamcmd/ \
  && chown -R inssource:inssource /opt/insurgency-source /home/inssource

ENV INS_SOURCE_DIR="/opt/insurgency-source" \
    STEAM_DIR="/home/inssource/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=inssource:inssource --chmod=755 entrypoint.sh /home/inssource/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${INS_SOURCE_DIR}

EXPOSE 27015/tcp 27015/udp 27016/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=600s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGINT

ENTRYPOINT ["/docker-entrypoint.sh"]
