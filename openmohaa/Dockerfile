ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

ARG OPENMOHAA_VERSION=v0.82.1

RUN pacman -Sy --noconfirm --needed \
    socat \
    unzip \
  && pacman -Scc --noconfirm \
  && useradd -m -u 1000 openmohaa \
  && mkdir -p /opt/openmohaa/lib/openmohaa /usr/local/share/mohaa \
  && curl -fsSL --retry 3 --retry-delay 2 \
    -o /tmp/openmohaa.zip \
    "https://github.com/openmoh/openmohaa/releases/download/${OPENMOHAA_VERSION}/openmohaa-${OPENMOHAA_VERSION}-linux-amd64.zip" \
  && unzip -q /tmp/openmohaa.zip -d /opt/openmohaa/lib/openmohaa \
  && chmod +x /opt/openmohaa/lib/openmohaa/omohaaded \
  && rm -f /tmp/openmohaa.zip \
  && chown -R openmohaa:openmohaa /opt/openmohaa /usr/local/share/mohaa /home/openmohaa

ENV MOHAA_INSTALL_DIR="/opt/openmohaa" \
    MOHAA_DATA_DIR="/usr/local/share/mohaa" \
    OPENMOHAA_VERSION="${OPENMOHAA_VERSION}" \
    MOH_GAME_PORT="12203" \
    MOH_GAMESPY_PORT="12300"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=openmohaa:openmohaa --chmod=755 entrypoint.sh /home/openmohaa/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${MOHAA_DATA_DIR}

EXPOSE 12203/udp 12300/udp

HEALTHCHECK --interval=30s --timeout=20s --start-period=60s --retries=3 \
  CMD ["/healthcheck.sh"]

ENTRYPOINT ["/docker-entrypoint.sh"]
