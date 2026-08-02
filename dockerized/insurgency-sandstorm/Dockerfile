ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="insurgency-sandstorm" \
      org.opencontainers.image.description="Insurgency: Sandstorm dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 inssandstorm \
  && mkdir -p /opt/insurgency-sandstorm /home/inssandstorm/steamcmd /home/inssandstorm/Steam \
  && cp -a /opt/steamcmd/. /home/inssandstorm/steamcmd/ \
  && chown -R inssandstorm:inssandstorm /opt/insurgency-sandstorm /home/inssandstorm

ENV INS_SANDSTORM_DIR="/opt/insurgency-sandstorm" \
    STEAM_DIR="/home/inssandstorm/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=inssandstorm:inssandstorm --chmod=755 entrypoint.sh /home/inssandstorm/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${INS_SANDSTORM_DIR}

EXPOSE 27102/udp 27131/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=900s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
