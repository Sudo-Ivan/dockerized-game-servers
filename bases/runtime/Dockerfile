FROM debian:trixie-slim@sha256:020c0d20b9880058cbe785a9db107156c3c75c2ac944a6aa7ab59f2add76a7bd

LABEL org.opencontainers.image.title="runtime-base" \
      org.opencontainers.image.description="Shared Debian runtime for non-Steam non-Java game servers" \
      org.opencontainers.image.licenses="ISC"

# glibc runtime for download-and-run servers (Factorio, OpenMoHAA, etc.).
# Alpine/musl cannot run typical upstream Linux game binaries.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    tar \
    bash \
    xz-utils \
    unzip \
    util-linux \
    procps \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

STOPSIGNAL SIGTERM
