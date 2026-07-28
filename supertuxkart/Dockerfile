ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest

FROM debian:trixie-slim@sha256:020c0d20b9880058cbe785a9db107156c3c75c2ac944a6aa7ab59f2add76a7bd AS builder

ARG STK_VERSION=1.5
ARG STK_SRC_SHA256=33cf8841e4ff4082d80b9248014295bbbea61d14683e86dff100e3ab8f7b27cb

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    ca-certificates \
    curl \
    libcurl4-openssl-dev \
    libssl-dev \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL --retry 3 --retry-delay 2 \
    -o /tmp/stk-src.tar.gz \
    "https://github.com/supertuxkart/stk-code/releases/download/${STK_VERSION}/SuperTuxKart-${STK_VERSION}-src.tar.gz" \
  && echo "${STK_SRC_SHA256}  /tmp/stk-src.tar.gz" | sha256sum -c - \
  && mkdir -p /build \
  && tar -xzf /tmp/stk-src.tar.gz -C /build --strip-components=1 \
  && rm -f /tmp/stk-src.tar.gz

WORKDIR /build/cmake_build

RUN cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DSERVER_ONLY=ON \
    -DBUILD_RECORDER=off \
    -DCMAKE_INSTALL_PREFIX=/opt/supertuxkart \
  && make -j"$(nproc)" \
  && make install \
  && rm -rf /build

ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}

ARG STK_VERSION=1.5

LABEL org.opencontainers.image.title="supertuxkart" \
      org.opencontainers.image.description="SuperTuxKart dedicated server, compiled from source with SERVER_ONLY" \
      org.opencontainers.image.licenses="ISC"

RUN useradd -m -u 1000 supertuxkart \
  && mkdir -p /opt/supertuxkart/data \
  && chown -R supertuxkart:supertuxkart /opt/supertuxkart /home/supertuxkart

COPY --from=builder --chown=supertuxkart:supertuxkart /opt/supertuxkart /opt/supertuxkart

ENV STK_DIR="/opt/supertuxkart" \
    STK_DATA_DIR="/opt/supertuxkart/data" \
    STK_VERSION="${STK_VERSION}"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=supertuxkart:supertuxkart --chmod=755 entrypoint.sh /home/supertuxkart/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${STK_DATA_DIR}

EXPOSE 2759/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
