ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

RUN pacman -Sy --noconfirm --needed \
    wine \
    samba \
  && pacman -Scc --noconfirm \
  && useradd -m -u 1000 groundbranch \
  && mkdir -p /opt/groundbranch /home/groundbranch/steamcmd \
  && cp -a /opt/steamcmd/. /home/groundbranch/steamcmd/ \
  && chown -R groundbranch:groundbranch /opt/groundbranch /home/groundbranch

ENV GB_INSTALL_DIR="/opt/groundbranch" \
    STEAM_DIR="/home/groundbranch/steamcmd" \
    WINEPREFIX="/opt/groundbranch/.wine" \
    WINEARCH="win64" \
    WINEDEBUG="-all" \
    SteamAppId="16900"

USER groundbranch
WORKDIR /home/groundbranch

COPY --chown=groundbranch:groundbranch --chmod=755 entrypoint.sh /home/groundbranch/entrypoint.sh

WORKDIR ${GB_INSTALL_DIR}

EXPOSE 7777/udp 27015/udp

ENTRYPOINT ["/bin/bash", "/home/groundbranch/entrypoint.sh"]
