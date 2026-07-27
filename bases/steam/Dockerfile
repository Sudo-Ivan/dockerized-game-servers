FROM archlinux:latest@sha256:592e11bd99ab579f933a0cb77a8f66e2f3ae57f5eafacf13aea44a6e98ef21ae

LABEL org.opencontainers.image.description="Shared SteamCMD base for dedicated game servers"

# XLibre Arch repo (community X11 server). Used by game images that need Xvfb/X11.
# https://github.com/xlibre-arch/xlibre-arch
# https://github.com/x11libre/xserver
ENV XLIBRE_KEY_ID="B97F7C613F359424"

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
  && pacman-key --lsign-key "${XLIBRE_KEY_ID}" \
  && rm -f /tmp/xlibre-archlinux.asc \
  && printf '\n[xlibre]\nServer = https://packages.xlibre.net/arch/stable/$arch\n' >> /etc/pacman.conf \
  && pacman -Sy --noconfirm \
  && pacman -Scc --noconfirm \
  && mkdir -p /opt/steamcmd \
  && curl -fsSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
    | tar -xz -C /opt/steamcmd \
  && /opt/steamcmd/steamcmd.sh +quit || true \
  && chmod -R a+rX /opt/steamcmd

ENV STEAMCMD_DIR="/opt/steamcmd"
