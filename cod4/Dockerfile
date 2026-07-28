ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE} AS fetch
RUN LGSM_URL="http://linuxgsm.download/CallOfDuty4/cod4x18_lnxded.tar.xz" LGSM_MD5="d255b59b9756d7dbead67718208512ee" bash -c 'set -eu; . /usr/local/bin/linuxgsm-tar-install.sh; lgsm_tar_install "${LGSM_URL}" "${LGSM_MD5}" /opt/cod4' \
  && chmod -R a+rX /opt/cod4 && chmod +x /opt/cod4/cod4x18_dedrun
ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}
LABEL org.opencontainers.image.title="cod4" \
      org.opencontainers.image.description="Call of Duty 4 dedicated (CoD4x)" \
      org.opencontainers.image.licenses="ISC"
RUN useradd -m -u 1000 cod4 && mkdir -p /opt/cod4 && chown -R cod4:cod4 /opt/cod4
COPY --from=fetch --chown=cod4:cod4 /opt/cod4 /usr/share/cod4-seed
ENV COD4_DIR="/opt/cod4" COD4_SEED_DIR="/usr/share/cod4-seed"
COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=cod4:cod4 --chmod=755 entrypoint.sh /home/cod4/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh
WORKDIR ${COD4_DIR}
EXPOSE 28960/udp
HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 CMD ["/healthcheck.sh"]
STOPSIGNAL SIGTERM
ENTRYPOINT ["/docker-entrypoint.sh"]
