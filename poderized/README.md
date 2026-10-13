# Poderized game servers

Container images, compose files, and server data layouts for dedicated game hosting. Built and run with Podman.

Each game has its own directory with a `Containerfile`, `compose.yml`, entrypoint scripts, and a `data/` volume mount. Shared base images live under `bases/` (`minecraft-base`, `steam-base`, `runtime-base`).

From the repository root:

```sh
podman compose -f poderized/minecraft/fabric/compose.yml up -d
```

The `gs` CLI in `tools/` reads compose paths from `ci/server-catalog.sh`, which points at files under this tree.

Trivy scan config for Containerfiles is in `trivy.yaml` in this directory.
