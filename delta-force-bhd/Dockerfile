ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="delta-force-bhd" \
      org.opencontainers.image.description="Delta Force: Black Hawk Down multiplayer host (Wine, BYO game files)" \
      org.opencontainers.image.licenses="ISC"

RUN if ! grep -q '^\[xlibre\]' /etc/pacman.conf; then \
      curl -fsSL "https://xlibre-arch.github.io/xlibre-archlinux.asc" \
        -o /tmp/xlibre-archlinux.asc \
      && pacman-key --add /tmp/xlibre-archlinux.asc \
      && pacman-key --lsign-key B97F7C613F359424 \
      && rm -f /tmp/xlibre-archlinux.asc \
      && printf '\n[xlibre]\nServer = https://packages.xlibre.net/arch/stable/$arch\n' >> /etc/pacman.conf; \
    fi \
  && pacman -Sy --noconfirm --needed \
    wine \
    xlibre-xserver-xvfb \
    libxi \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 dfbhd \
  && mkdir -p /opt/dfbhd /tmp/.X11-unix \
  && chmod 1777 /tmp/.X11-unix \
  && chown -R dfbhd:dfbhd /opt/dfbhd /home/dfbhd

ENV BHD_DIR="/opt/dfbhd" \
    WINEPREFIX="/opt/dfbhd/.wine" \
    WINEARCH="win32" \
    WINEDEBUG="-all"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=dfbhd:dfbhd --chmod=755 entrypoint.sh /home/dfbhd/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${BHD_DIR}

EXPOSE 3568/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=300s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
