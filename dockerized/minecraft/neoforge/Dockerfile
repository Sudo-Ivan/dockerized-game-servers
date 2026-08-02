ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-base:latest
FROM ${BASE_IMAGE}

ARG NEOFORGE_VERSION=26.2.0.35-beta

LABEL org.opencontainers.image.title="minecraft-neoforge" \
      org.opencontainers.image.description="Minecraft NeoForge dedicated server" \
      org.opencontainers.image.licenses="ISC"

USER root
COPY --chmod=755 neoforge/entrypoint.sh /entrypoint.sh
COPY --chmod=755 neoforge/healthcheck.sh /healthcheck.sh

ENV NEOFORGE_VERSION="${NEOFORGE_VERSION}" \
    JVM_FLAGS="-Xms3G -Xmx3G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
  CMD ["/healthcheck.sh"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/entrypoint.sh"]
