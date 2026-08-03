ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="vintage-story" \
      org.opencontainers.image.description="Vintage Story dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN apt-get update \
  && apt-get install -y --no-install-recommends libicu76 \
  && rm -rf /var/lib/apt/lists/* \
  && curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
  && bash /tmp/dotnet-install.sh --runtime dotnet --channel 10.0 --install-dir /usr/share/dotnet \
  && rm -f /tmp/dotnet-install.sh \
  && useradd -m -u 1000 vintagestory \
  && mkdir -p /opt/vintage-story/server /opt/vintage-story/data \
  && chown -R vintagestory:vintagestory /opt/vintage-story /home/vintagestory

ENV VS_ROOT="/opt/vintage-story" \
    VS_SERVER_DIR="/opt/vintage-story/server" \
    VS_DATA_DIR="/opt/vintage-story/data" \
    VS_VERSION="1.22.6" \
    VS_BRANCH="stable" \
    DOTNET_ROOT="/usr/share/dotnet" \
    PATH="/usr/share/dotnet:${PATH}"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=vintagestory:vintagestory --chmod=755 entrypoint.sh /home/vintagestory/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${VS_ROOT}

USER vintagestory

EXPOSE 42420/tcp 42420/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=300s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
