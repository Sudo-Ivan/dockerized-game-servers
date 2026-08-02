ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="7-days-to-die" \
      org.opencontainers.image.description="7 Days to Die dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Sy --noconfirm --needed \
    libpulse \
    alsa-lib \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 sevendtd \
  && mkdir -p /opt/7dtd /home/sevendtd/steamcmd \
  && cp -a /opt/steamcmd/. /home/sevendtd/steamcmd/ \
  && chown -R sevendtd:sevendtd /opt/7dtd /home/sevendtd

ENV SEVENDTD_DIR="/opt/7dtd" \
    STEAM_DIR="/home/sevendtd/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=sevendtd:sevendtd --chmod=755 entrypoint.sh /home/sevendtd/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${SEVENDTD_DIR}

EXPOSE 26900/tcp 26900/udp 26901/udp 26902/udp 26903/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=600s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
