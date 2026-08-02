ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="dont-starve-together" \
      org.opencontainers.image.description="Don't Starve Together dedicated server (Master + Caves)" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Sy --noconfirm --needed libcurl-gnutls \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 dst \
  && mkdir -p /opt/dst /home/dst/steamcmd /home/dst/Steam \
  && cp -a /opt/steamcmd/. /home/dst/steamcmd/ \
  && chown -R dst:dst /opt/dst /home/dst

ENV DST_DIR="/opt/dst" \
    STEAM_DIR="/home/dst/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=dst:dst --chmod=755 entrypoint.sh /home/dst/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${DST_DIR}

EXPOSE 10999/udp 11000/udp 27016/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=900s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
