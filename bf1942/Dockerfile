ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE} AS fetch
RUN LGSM_URL="http://linuxgsm.download/BattleField1942/bf1942_lnxded-1.61-hacked-to-1.612.full.tar.xz" LGSM_MD5="4223bf4ed85f5162c24b2cba51249b9e" bash -c 'set -eu; . /usr/local/bin/linuxgsm-tar-install.sh; lgsm_tar_install "${LGSM_URL}" "${LGSM_MD5}" /opt/bf1942' \
  && chmod -R a+rX /opt/bf1942 && chmod +x /opt/bf1942/start.sh
ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}
LABEL org.opencontainers.image.title="bf1942" org.opencontainers.image.licenses="ISC"
RUN useradd -m -u 1000 bf1942 && mkdir -p /opt/bf1942 && chown -R bf1942:bf1942 /opt/bf1942
COPY --from=fetch --chown=bf1942:bf1942 /opt/bf1942 /usr/share/bf1942-seed
ENV BF1942_DIR="/opt/bf1942" BF1942_SEED_DIR="/usr/share/bf1942-seed"
COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=bf1942:bf1942 --chmod=755 entrypoint.sh /home/bf1942/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh
WORKDIR ${BF1942_DIR}
EXPOSE 14567/udp
EXPOSE 23000/tcp
HEALTHCHECK --interval=30s --timeout=5s --start-period=180s --retries=3 CMD ["/healthcheck.sh"]
STOPSIGNAL SIGTERM
USER bf1942
ENTRYPOINT ["/docker-entrypoint.sh"]
