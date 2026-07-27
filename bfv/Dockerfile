ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE} AS fetch
RUN LGSM_URL="http://linuxgsm.download/BattlefieldVietnam/bfv_linded-v1.21-20041207_patch.tar.xz" LGSM_MD5="e3b4962cdd9d41e23c6fed65101bccde" bash -c 'set -eu; . /usr/local/bin/linuxgsm-tar-install.sh; lgsm_tar_install "${LGSM_URL}" "${LGSM_MD5}" /opt/bfv' \
  && chmod -R a+rX /opt/bfv && chmod +x /opt/bfv/start.sh
ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}
LABEL org.opencontainers.image.title="bfv" org.opencontainers.image.licenses="ISC"
RUN useradd -m -u 1000 bfv && mkdir -p /opt/bfv && chown -R bfv:bfv /opt/bfv
COPY --from=fetch --chown=bfv:bfv /opt/bfv /usr/share/bfv-seed
ENV BFV_DIR="/opt/bfv" BFV_SEED_DIR="/usr/share/bfv-seed"
COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=bfv:bfv --chmod=755 entrypoint.sh /home/bfv/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh
WORKDIR ${BFV_DIR}
EXPOSE 4755/udp
EXPOSE 27900/udp
HEALTHCHECK --interval=30s --timeout=5s --start-period=180s --retries=3 CMD ["/healthcheck.sh"]
STOPSIGNAL SIGTERM
USER bfv
ENTRYPOINT ["/docker-entrypoint.sh"]
