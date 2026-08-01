FROM debian:trixie-slim@sha256:020c0d20b9880058cbe785a9db107156c3c75c2ac944a6aa7ab59f2add76a7bd

LABEL org.opencontainers.image.title="runtime-base" \
      org.opencontainers.image.description="Shared Debian runtime for non-Steam non-Java game servers" \
      org.opencontainers.image.licenses="ISC"

COPY install-legacy32-libs.sh http-download.sh /tmp/
COPY http-download.sh linuxgsm-tar-install.sh /usr/local/bin/

# glibc runtime for download-and-run servers (Factorio, OpenMoHAA, LinuxGSM archives, etc.).
# Alpine/musl cannot run typical upstream Linux game binaries.
RUN chmod 755 /tmp/install-legacy32-libs.sh /tmp/http-download.sh \
    /usr/local/bin/http-download.sh /usr/local/bin/linuxgsm-tar-install.sh \
  && apt-get update \
  && dpkg --add-architecture i386 \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    tar \
    bash \
    xz-utils \
    unzip \
    util-linux \
    procps \
    libc6-i386 \
    lib32gcc-s1 \
    libstdc++6 \
    libstdc++6:i386 \
  && bash /tmp/install-legacy32-libs.sh \
  && rm -f /tmp/install-legacy32-libs.sh \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

STOPSIGNAL SIGTERM
