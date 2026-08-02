ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE} AS fetch
RUN LGSM_URL="http://linuxgsm.download/Quake3/quake3-1.32c-x86-full-linux.tar.xz" LGSM_MD5="b0e26d8919fe9313fb9d8ded2360f3db" bash -c 'set -eu; . /usr/local/bin/linuxgsm-tar-install.sh; lgsm_tar_install "${LGSM_URL}" "${LGSM_MD5}" /opt/quake3' \
  && chmod -R a+rX /opt/quake3 && chmod +x /opt/quake3/q3ded
ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/runtime-base:latest
FROM ${BASE_IMAGE}
RUN useradd -m -u 1000 quake3 && mkdir -p /opt/quake3 && chown -R quake3:quake3 /opt/quake3
COPY --from=fetch --chown=quake3:quake3 /opt/quake3 /usr/share/quake3-seed
ENV Q3_DIR="/opt/quake3" Q3_SEED_DIR="/usr/share/quake3-seed"
COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=quake3:quake3 --chmod=755 entrypoint.sh /home/quake3/entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh
WORKDIR ${Q3_DIR}
EXPOSE 27960/udp
HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 CMD ["/healthcheck.sh"]
STOPSIGNAL SIGTERM
ENTRYPOINT ["/docker-entrypoint.sh"]
