ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="vein" \
      org.opencontainers.image.description="VEIN dedicated server (Wine)" \
      org.opencontainers.image.licenses="ISC"

RUN if ! grep -q '^\[xlibre\]' /etc/pacman.conf; then \
      curl -fsSL "https://xlibre-arch.github.io/xlibre-archlinux.asc" \
        -o /tmp/xlibre-archlinux.asc \
      && pacman-key --add /tmp/xlibre-archlinux.asc \
      && pacman-key --lsign-key B97F7C613F359424 \
      && rm -f /tmp/xlibre-archlinux.asc \
      && printf '\n[xlibre]\nServer = https://packages.xlibre.net/arch/stable/$arch\n' >> /etc/pacman.conf; \
    fi \
  && pacman -Sy --noconfirm --needed --assume-installed NTSYNC-MODULE \
    wine \
    xlibre-xserver-xvfb \
    libxi \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 vein \
  && mkdir -p /opt/vein /home/vein/steamcmd /tmp/.X11-unix \
  && cp -a /opt/steamcmd/. /home/vein/steamcmd/ \
  && chmod 1777 /tmp/.X11-unix \
  && chown -R vein:vein /opt/vein /home/vein

ENV VEIN_DIR="/opt/vein" \
    STEAM_DIR="/home/vein/steamcmd" \
    WINEPREFIX="/opt/vein/.wine" \
    WINEARCH="win64" \
    WINEDEBUG="-all"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=vein:vein --chmod=755 entrypoint.sh /home/vein/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${VEIN_DIR}

EXPOSE 7777/udp 27015/udp

HEALTHCHECK --interval=30s --timeout=10s --start-period=900s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
