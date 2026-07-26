FROM archlinux:latest

LABEL org.opencontainers.image.description="Shared SteamCMD base for dedicated game servers"

RUN sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf \
  && pacman -Syu --noconfirm \
  && pacman -S --noconfirm --needed \
    lib32-gcc-libs \
    lib32-glibc \
    gcc-libs \
    curl \
    tar \
    ca-certificates \
  && pacman -Scc --noconfirm \
  && mkdir -p /opt/steamcmd \
  && curl -fsSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
    | tar -xz -C /opt/steamcmd \
  && /opt/steamcmd/steamcmd.sh +quit || true \
  && chmod -R a+rX /opt/steamcmd

ENV STEAMCMD_DIR="/opt/steamcmd"
