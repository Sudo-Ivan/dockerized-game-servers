FROM archlinux:latest@sha256:592e11bd99ab579f933a0cb77a8f66e2f3ae57f5eafacf13aea44a6e98ef21ae AS steamcmd

ARG STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
ARG STEAMCMD_SHA256="cebf0046bfd08cf45da6bc094ae47aa39ebf4155e5ede41373b579b8f1071e7c"

RUN pacman -Syu --noconfirm \
  && pacman -S --noconfirm --needed curl ca-certificates tar \
  && mkdir -p /opt/steamcmd \
  && curl -fsSL "${STEAMCMD_URL}" -o /tmp/steamcmd_linux.tar.gz \
  && echo "${STEAMCMD_SHA256}  /tmp/steamcmd_linux.tar.gz" | sha256sum -c - \
  && tar -xzf /tmp/steamcmd_linux.tar.gz -C /opt/steamcmd \
  && rm -f /tmp/steamcmd_linux.tar.gz \
  && /opt/steamcmd/steamcmd.sh +quit || true \
  && chmod -R a+rX /opt/steamcmd \
  && pacman -Scc --noconfirm

FROM archlinux:latest@sha256:592e11bd99ab579f933a0cb77a8f66e2f3ae57f5eafacf13aea44a6e98ef21ae

LABEL org.opencontainers.image.title="steam-base" \
      org.opencontainers.image.description="Shared SteamCMD base for dedicated game servers" \
      org.opencontainers.image.licenses="ISC"

# XLibre Arch repo (community X11 server). Used by game images that need Xvfb/X11.
# https://github.com/xlibre-arch/xlibre-arch
# https://github.com/x11libre/xserver
RUN sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf \
  && pacman -Syu --noconfirm \
  && pacman -S --noconfirm --needed \
    lib32-gcc-libs \
    lib32-glibc \
    gcc-libs \
    curl \
    tar \
    ca-certificates \
  && rm -f /usr/bin/captree \
  && pacman-key --init \
  && pacman-key --populate archlinux \
  && curl -fsSL "https://xlibre-arch.github.io/xlibre-archlinux.asc" \
    -o /tmp/xlibre-archlinux.asc \
  && pacman-key --add /tmp/xlibre-archlinux.asc \
  && pacman-key --lsign-key B97F7C613F359424 \
  && rm -f /tmp/xlibre-archlinux.asc \
  && printf '\n[xlibre]\nServer = https://packages.xlibre.net/arch/stable/$arch\n' >> /etc/pacman.conf \
  && pacman -Sy --noconfirm \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/*

COPY --from=steamcmd /opt/steamcmd /opt/steamcmd
COPY steamcmd-app-update.sh /opt/steamcmd/steamcmd-app-update.sh

ENV STEAMCMD_DIR="/opt/steamcmd"
