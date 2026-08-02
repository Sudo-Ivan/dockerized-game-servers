ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="cs2" \
      org.opencontainers.image.description="Counter-Strike 2 dedicated server" \
      org.opencontainers.image.licenses="ISC"

RUN pacman -Sy --noconfirm --needed \
    icu \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 cs2 \
  && mkdir -p /opt/cs2 /home/cs2/steamcmd /home/cs2/Steam \
  && cp -a /opt/steamcmd/. /home/cs2/steamcmd/ \
  && chown -R cs2:cs2 /opt/cs2 /home/cs2

ENV CS2_DIR="/opt/cs2" \
    STEAM_DIR="/home/cs2/steamcmd"

COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=cs2:cs2 --chmod=755 entrypoint.sh /home/cs2/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${CS2_DIR}

EXPOSE 27015/tcp 27015/udp 27020/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=1800s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGINT

ENTRYPOINT ["/docker-entrypoint.sh"]
