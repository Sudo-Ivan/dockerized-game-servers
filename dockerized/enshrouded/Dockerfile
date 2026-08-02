ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="enshrouded" \
      org.opencontainers.image.description="Enshrouded dedicated server (Wine)" \
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
  && useradd -m -u 1000 enshrouded \
  && mkdir -p /opt/enshrouded /home/enshrouded/steamcmd /tmp/.X11-unix \
  && cp -a /opt/steamcmd/. /home/enshrouded/steamcmd/ \
  && chmod 1777 /tmp/.X11-unix \
  && chown -R enshrouded:enshrouded /opt/enshrouded /home/enshrouded

ENV ENSHROUDED_DIR="/opt/enshrouded" \
    STEAM_DIR="/home/enshrouded/steamcmd" \
    WINEPREFIX="/opt/enshrouded/.wine" \
    WINEARCH="win64" \
    WINEDEBUG="-all"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=enshrouded:enshrouded --chmod=755 entrypoint.sh /home/enshrouded/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${ENSHROUDED_DIR}

EXPOSE 15636/udp 15637/udp

HEALTHCHECK --interval=30s --timeout=10s --start-period=900s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
