ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

RUN pacman -Sy --noconfirm --needed \
    xz \
  && pacman -Scc --noconfirm \
  && useradd -m -u 1000 factorio \
  && mkdir -p /opt/factorio \
  && chown -R factorio:factorio /opt/factorio /home/factorio

ENV FACTORIO_DIR="/opt/factorio" \
    FACTORIO_VERSION="stable"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=factorio:factorio --chmod=755 entrypoint.sh /home/factorio/entrypoint.sh

WORKDIR ${FACTORIO_DIR}

EXPOSE 34197/udp 27015/tcp

ENTRYPOINT ["/docker-entrypoint.sh"]
