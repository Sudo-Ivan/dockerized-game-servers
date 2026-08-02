ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="v-rising" \
      org.opencontainers.image.description="V Rising dedicated server (Wine)" \
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
  && useradd -m -u 1000 vrising \
  && mkdir -p /opt/vrising /home/vrising/steamcmd /tmp/.X11-unix \
  && cp -a /opt/steamcmd/. /home/vrising/steamcmd/ \
  && chmod 1777 /tmp/.X11-unix \
  && chown -R vrising:vrising /opt/vrising /home/vrising

ENV VRISING_DIR="/opt/vrising" \
    STEAM_DIR="/home/vrising/steamcmd" \
    WINEPREFIX="/opt/vrising/.wine" \
    WINEARCH="win64" \
    WINEDEBUG="-all"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=vrising:vrising --chmod=755 entrypoint.sh /home/vrising/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${VRISING_DIR}

EXPOSE 9876/udp 9877/tcp 9877/udp

HEALTHCHECK --interval=30s --timeout=10s --start-period=900s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
