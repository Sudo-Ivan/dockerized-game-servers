ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="sniper-elite-4" \
      org.opencontainers.image.description="Sniper Elite 4 dedicated server (Wine)" \
      org.opencontainers.image.licenses="ISC"

# NTSYNC-MODULE is a host kernel feature. Do not pull the linux package into the image.
RUN pacman -Sy --noconfirm --needed --assume-installed NTSYNC-MODULE \
    wine \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 se4 \
  && mkdir -p /opt/se4 /home/se4/steamcmd \
  && cp -a /opt/steamcmd/. /home/se4/steamcmd/ \
  && chown -R se4:se4 /opt/se4 /home/se4

ENV SE4_DIR="/opt/se4" \
    STEAM_DIR="/home/se4/steamcmd" \
    WINEPREFIX="/opt/se4/.wine" \
    WINEARCH="win64" \
    WINEDEBUG="-all" \
    SteamAppId="312660"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=se4:se4 --chmod=755 entrypoint.sh /home/se4/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${SE4_DIR}

EXPOSE 27000/udp 27005/udp 27010/tcp 27015/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=300s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

USER se4

ENTRYPOINT ["/docker-entrypoint.sh"]
