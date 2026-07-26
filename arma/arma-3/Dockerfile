ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/steam-base:latest
FROM ${BASE_IMAGE}

RUN pacman -Sy --noconfirm --needed \
    python \
    python-pip \
    python-virtualenv \
    git \
    findutils \
    bash \
  && pacman -Scc --noconfirm \
  && useradd -m arma3

ENV ARMA_DIR="/home/arma3/server" \
    STEAM_DIR="/home/arma3/steamcmd" \
    ARMA_CACHE_DIR="/home/arma3/cache" \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH="/home/arma3" \
    PATH="/home/arma3/venv/bin:/home/arma3/.local/bin:${PATH}"

USER arma3
WORKDIR /home/arma3

RUN python -m venv /home/arma3/venv \
  && /home/arma3/venv/bin/pip install --no-cache-dir -U pip zstandard \
    "steam[client] @ git+https://github.com/brettmayson/valvepythonsteam" \
  && mkdir -p "${STEAM_DIR}" /home/arma3/profiles /home/arma3/configs /home/arma3/cache \
  && cp -a /opt/steamcmd/. "${STEAM_DIR}/" \
  && ("${STEAM_DIR}/steamcmd.sh" +quit || true)

COPY --chown=arma3:arma3 sync_mods.py /home/arma3/sync_mods.py
COPY --chown=arma3:arma3 api/ /home/arma3/api/
COPY --chown=arma3:arma3 --chmod=755 entrypoint.sh /home/arma3/entrypoint.sh

WORKDIR ${ARMA_DIR}

EXPOSE 2302/udp 2303/udp 2304/udp 2305/udp 2306/udp

ENTRYPOINT ["/bin/bash", "/home/arma3/entrypoint.sh"]
