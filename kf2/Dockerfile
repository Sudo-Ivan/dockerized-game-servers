ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="kf2" \
      org.opencontainers.image.description="Killing Floor 2 dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 kf2 \
  && mkdir -p /opt/kf2 /home/kf2/steamcmd /home/kf2/Steam \
  && cp -a /opt/steamcmd/. /home/kf2/steamcmd/ \
  && chown -R kf2:kf2 /opt/kf2 /home/kf2

ENV KF2_DIR="/opt/kf2" \
    STEAM_DIR="/home/kf2/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=kf2:kf2 --chmod=755 entrypoint.sh /home/kf2/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${KF2_DIR}

EXPOSE 7777/udp 27015/udp 8080/tcp 20560/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=900s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

USER kf2

ENTRYPOINT ["/docker-entrypoint.sh"]
