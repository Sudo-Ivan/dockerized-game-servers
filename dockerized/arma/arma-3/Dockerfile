ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE} AS panel-builder

RUN pacman -Sy --noconfirm --needed go curl \
  && pacman -Scc --noconfirm

WORKDIR /build
COPY panel/ /build/
RUN chmod +x fetch-assets.sh \
  && ./fetch-assets.sh \
  && CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /gameserver-panel ./cmd/gameserver-panel

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

COPY --chown=arma3:arma3 arma/arma-3/patch-steam.py /home/arma3/patch-steam.py

RUN python -m venv /home/arma3/venv \
  && /home/arma3/venv/bin/pip install --no-cache-dir -U pip zstandard \
    "steam[client] @ git+https://github.com/brettmayson/valvepythonsteam" \
  && /home/arma3/venv/bin/python /home/arma3/patch-steam.py /home/arma3/venv \
  && rm -f /home/arma3/patch-steam.py \
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
  && mkdir -p /home/arma3/server /home/arma3/profiles /home/arma3/configs /home/arma3/cache /home/arma3/bin \
  && chown -R arma3:arma3 /home/arma3

ENV ARMA_DIR="/home/arma3/server" \
    STEAM_DIR="/home/arma3/steamcmd" \
    ARMA_CACHE_DIR="/home/arma3/cache" \
    PANEL_GAME="arma3" \
    PANEL_ADDR=":9283" \
    PANEL_AUTO_START="true" \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH="/home/arma3" \
    PATH="/home/arma3/bin:/home/arma3/venv/bin:/home/arma3/.local/bin:${PATH}"

COPY --from=panel-builder --chown=arma3:arma3 --chmod=755 /gameserver-panel /home/arma3/bin/arma-panel
COPY --from=builder --chown=arma3:arma3 /home/arma3/venv /home/arma3/venv
COPY --from=builder --chown=arma3:arma3 /home/arma3/steamcmd /home/arma3/steamcmd
COPY arma/arma-3/sync_mods.py /home/arma3/sync_mods.py
COPY arma/arma-3/modlist.py /home/arma3/modlist.py
COPY arma/arma-3/api/ /home/arma3/api/
COPY arma/arma-3/entrypoint.sh /home/arma3/entrypoint.sh
COPY arma/arma-3/docker-entrypoint.sh /docker-entrypoint.sh
COPY arma/arma-3/healthcheck.sh /healthcheck.sh

RUN chmod 755 /home/arma3/entrypoint.sh /docker-entrypoint.sh /healthcheck.sh \
  && chown arma3:arma3 /home/arma3/entrypoint.sh /home/arma3/sync_mods.py /home/arma3/modlist.py

WORKDIR ${ARMA_DIR}

EXPOSE 2302/udp 2303/udp 2304/udp 2305/udp 2306/udp 9283/tcp

HEALTHCHECK --interval=30s --timeout=5s --start-period=300s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
