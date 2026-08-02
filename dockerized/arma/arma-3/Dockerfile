ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE} AS builder

RUN pacman -Sy --noconfirm --needed \
    python \
    python-pip \
    python-virtualenv \
    git \
    findutils \
    bash \
  && pacman -Scc --noconfirm \
  && useradd -m -u 1000 arma3

USER arma3
WORKDIR /home/arma3

RUN python -m venv /home/arma3/venv \
  && /home/arma3/venv/bin/pip install --no-cache-dir -U pip zstandard \
    "steam[client] @ git+https://github.com/brettmayson/valvepythonsteam" \
  && mkdir -p /home/arma3/steamcmd /home/arma3/profiles /home/arma3/configs /home/arma3/cache \
  && cp -a /opt/steamcmd/. /home/arma3/steamcmd/ \
  && (/home/arma3/steamcmd/steamcmd.sh +quit || true) \
  && find /home/arma3/venv -type d -name '__pycache__' -prune -exec rm -rf {} + 2>/dev/null || true \
  && rm -rf /home/arma3/.cache /tmp/*

ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="arma-3" \
      org.opencontainers.image.description="Arma 3 dedicated server" \
      org.opencontainers.image.licenses="ISC"

# Runtime only. Build tools (pip, git, virtualenv) stay in the builder stage.
RUN pacman -Sy --noconfirm --needed \
    python \
    findutils \
    bash \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/* /tmp/* /var/tmp/* \
  && useradd -m -u 1000 arma3 \
  && mkdir -p /home/arma3/server /home/arma3/profiles /home/arma3/configs /home/arma3/cache \
  && chown -R arma3:arma3 /home/arma3

ENV ARMA_DIR="/home/arma3/server" \
    STEAM_DIR="/home/arma3/steamcmd" \
    ARMA_CACHE_DIR="/home/arma3/cache" \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH="/home/arma3" \
    PATH="/home/arma3/venv/bin:/home/arma3/.local/bin:${PATH}"

COPY --from=builder --chown=arma3:arma3 /home/arma3/venv /home/arma3/venv
COPY --from=builder --chown=arma3:arma3 /home/arma3/steamcmd /home/arma3/steamcmd
COPY --chown=arma3:arma3 sync_mods.py /home/arma3/sync_mods.py
COPY --chown=arma3:arma3 modlist.py /home/arma3/modlist.py
COPY --chown=arma3:arma3 api/ /home/arma3/api/
COPY --chown=arma3:arma3 --chmod=755 entrypoint.sh /home/arma3/entrypoint.sh
COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chmod=755 healthcheck.sh /healthcheck.sh

WORKDIR ${ARMA_DIR}

EXPOSE 2302/udp 2303/udp 2304/udp 2305/udp 2306/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=300s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
