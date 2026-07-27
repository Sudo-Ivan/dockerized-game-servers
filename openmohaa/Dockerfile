ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE} AS fetch

ARG OPENMOHAA_VERSION=v0.82.1

RUN mkdir -p /opt/openmohaa/lib/openmohaa \
  && curl -fsSL --retry 3 --retry-delay 2 \
    -o /tmp/openmohaa.zip \
    "https://github.com/openmoh/openmohaa/releases/download/${OPENMOHAA_VERSION}/openmohaa-${OPENMOHAA_VERSION}-linux-amd64.zip" \
  && unzip -q /tmp/openmohaa.zip -d /opt/openmohaa/lib/openmohaa \
  && chmod +x /opt/openmohaa/lib/openmohaa/omohaaded \
  && printf '%s\n' "${OPENMOHAA_VERSION}" > /opt/openmohaa/.installed-version \
  && rm -f /tmp/openmohaa.zip \
  && rm -rf /tmp/* /var/tmp/*

ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}

ARG OPENMOHAA_VERSION=v0.82.1

LABEL org.opencontainers.image.title="openmohaa" \
      org.opencontainers.image.description="OpenMoHAA dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    socat \
    libstdc++6 \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 openmohaa \
  && mkdir -p /opt/openmohaa /usr/local/share/mohaa \
  && chown -R openmohaa:openmohaa /opt/openmohaa /usr/local/share/mohaa /home/openmohaa

COPY --from=fetch --chown=openmohaa:openmohaa /opt/openmohaa /opt/openmohaa

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

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
