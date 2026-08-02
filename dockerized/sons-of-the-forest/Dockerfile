ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="sons-of-the-forest" \
      org.opencontainers.image.description="Sons Of The Forest dedicated server (Wine)" \
      org.opencontainers.image.licenses="ISC"

# NTSYNC-MODULE is a host kernel feature. Do not pull the linux package into the image.
RUN pacman -Sy --noconfirm --needed --assume-installed NTSYNC-MODULE \
    wine \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 sotf \
  && mkdir -p /opt/sotf /home/sotf/steamcmd \
  && cp -a /opt/steamcmd/. /home/sotf/steamcmd/ \
  && chown -R sotf:sotf /opt/sotf /home/sotf

ENV SOTF_DIR="/opt/sotf" \
    STEAM_DIR="/home/sotf/steamcmd" \
    WINEPREFIX="/opt/sotf/.wine" \
    WINEARCH="win64" \
    WINEDEBUG="-all" \
    SteamAppId="1326470"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=sotf:sotf --chmod=755 entrypoint.sh /home/sotf/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${SOTF_DIR}

EXPOSE 8766/udp 27016/udp 9700/udp

HEALTHCHECK --interval=30s --timeout=10s --start-period=900s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
