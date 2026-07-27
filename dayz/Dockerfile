ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="dayz" \
      org.opencontainers.image.description="DayZ dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Sy --noconfirm --needed \
    openssl \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 dayz \
  && mkdir -p /opt/dayz /home/dayz/steamcmd /home/dayz/Steam \
  && cp -a /opt/steamcmd/. /home/dayz/steamcmd/ \
  && chown -R dayz:dayz /opt/dayz /home/dayz

ENV DAYZ_DIR="/opt/dayz" \
    STEAM_DIR="/home/dayz/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=dayz:dayz --chmod=755 entrypoint.sh /home/dayz/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${DAYZ_DIR}

EXPOSE 2302/udp 2303/udp 2304/udp 2305/udp 2306/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=1200s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

USER dayz

ENTRYPOINT ["/docker-entrypoint.sh"]
