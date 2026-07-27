ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="space-engineers" \
      org.opencontainers.image.description="Space Engineers dedicated server (Wine)" \
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
    winetricks \
    cabextract \
    xlibre-xserver-xvfb \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 spaceengineers \
  && mkdir -p /opt/spaceengineers/dedicated /opt/spaceengineers/instances /opt/spaceengineers/plugins \
    /home/spaceengineers/steamcmd /tmp/.X11-unix \
  && chmod 1777 /tmp/.X11-unix \
  && cp -a /opt/steamcmd/. /home/spaceengineers/steamcmd/ \
  && chown -R spaceengineers:spaceengineers /opt/spaceengineers /home/spaceengineers

ENV SE_ROOT="/opt/spaceengineers" \
    SE_DEDICATED_DIR="/opt/spaceengineers/dedicated" \
    SE_INSTANCES_DIR="/opt/spaceengineers/instances" \
    SE_PLUGINS_DIR="/opt/spaceengineers/plugins" \
    STEAM_DIR="/home/spaceengineers/steamcmd" \
    WINEPREFIX="/opt/spaceengineers/.wine" \
    WINEARCH="win64" \
    WINEDEBUG="-all" \
    SteamAppId="244850"

COPY --chown=spaceengineers:spaceengineers --chmod=755 wine-setup.sh /home/spaceengineers/wine-setup.sh
COPY --chown=spaceengineers:spaceengineers --chmod=755 entrypoint.sh /home/spaceengineers/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

USER spaceengineers
WORKDIR ${SE_ROOT}

EXPOSE 27016/udp

HEALTHCHECK --interval=30s --timeout=10s --start-period=900s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/bin/bash", "/home/spaceengineers/entrypoint.sh"]
