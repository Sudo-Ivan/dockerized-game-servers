ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

RUN pacman -Sy --noconfirm --needed \
    xlibre-xserver-xvfb \
    libxi \
  && pacman -Scc --noconfirm \
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

ENTRYPOINT ["/docker-entrypoint.sh"]
