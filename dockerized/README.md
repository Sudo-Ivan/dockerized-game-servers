# Dockerized game servers

Docker images, compose files, and server data layouts for dedicated game hosting.

Each game has its own directory with a `Dockerfile`, `docker-compose.yml`, entrypoint scripts, and a `data/` volume mount. Shared base images live under `bases/` (`minecraft-base`, `steam-base`, `runtime-base`).

The shared web panel lives under `panel/` (`gameserverpanel` Go module). Game images that ship a panel build from `dockerized/panel` and select a game module with `PANEL_GAME` (Arma 3 uses `arma3`).

From the repository root:

```sh
docker compose -f dockerized/minecraft/fabric/docker-compose.yml up -d
```

The `gs` CLI in `tools/` reads compose paths from `ci/server-catalog.sh`, which points at files under this tree.

Trivy scan config for Dockerfiles is in `trivy.yaml` in this directory.
