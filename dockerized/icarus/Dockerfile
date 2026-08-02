ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="icarus" \
      org.opencontainers.image.description="Icarus dedicated server (Wine)" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Sy --noconfirm --needed --assume-installed NTSYNC-MODULE \
    wine \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 icarus \
  && mkdir -p /opt/icarus /home/icarus/steamcmd /home/icarus/Steam \
  && cp -a /opt/steamcmd/. /home/icarus/steamcmd/ \
  && chown -R icarus:icarus /opt/icarus /home/icarus

ENV ICARUS_DIR="/opt/icarus" \
    STEAM_DIR="/home/icarus/steamcmd" \
    WINEPREFIX="/opt/icarus/.wine" \
    WINEARCH="win64" \
    WINEDEBUG="-all" \
    SteamAppId="1149460"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=icarus:icarus --chmod=755 entrypoint.sh /home/icarus/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${ICARUS_DIR}

EXPOSE 17777/udp 27015/udp

HEALTHCHECK --interval=30s --timeout=10s --start-period=1200s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
