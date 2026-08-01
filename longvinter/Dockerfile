ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="longvinter" \
      org.opencontainers.image.description="Longvinter dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Sy --noconfirm --needed \
    icu \
    openssl \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 longvinter \
  && mkdir -p /opt/longvinter /home/longvinter/steamcmd /home/longvinter/Steam \
  && cp -a /opt/steamcmd/. /home/longvinter/steamcmd/ \
  && chown -R longvinter:longvinter /opt/longvinter /home/longvinter

ENV LONGVINTER_DIR="/opt/longvinter" \
    STEAM_DIR="/home/longvinter/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=longvinter:longvinter --chmod=755 entrypoint.sh /home/longvinter/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${LONGVINTER_DIR}

EXPOSE 7777/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=600s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
