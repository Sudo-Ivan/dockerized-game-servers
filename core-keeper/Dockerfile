ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="core-keeper" \
      org.opencontainers.image.description="Core Keeper dedicated server" \
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
    xlibre-xserver-xvfb \
    libxi \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 corekeeper \
  && mkdir -p /opt/corekeeper/server /opt/corekeeper/data /home/corekeeper/steamcmd /tmp/.X11-unix \
  && chmod 1777 /tmp/.X11-unix \
  && cp -a /opt/steamcmd/. /home/corekeeper/steamcmd/ \
  && chown -R corekeeper:corekeeper /opt/corekeeper /home/corekeeper

ENV CK_INSTALL_DIR="/opt/corekeeper/server" \
    CK_DATA_DIR="/opt/corekeeper/data" \
    STEAM_DIR="/home/corekeeper/steamcmd" \
    CK_APP_ID="1963720" \
    CK_STEAMWORKS_APP_ID="1007"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=corekeeper:corekeeper --chmod=755 entrypoint.sh /home/corekeeper/entrypoint.sh
COPY --chown=corekeeper:corekeeper --chmod=755 ready.sh /home/corekeeper/ready.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR /opt/corekeeper

HEALTHCHECK --interval=30s --timeout=5s --start-period=300s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
