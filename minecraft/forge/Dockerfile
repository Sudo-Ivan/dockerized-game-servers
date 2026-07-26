ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-base:latest
FROM ${BASE_IMAGE}

ARG FORGE_MINECRAFT_VERSION=1.21.11
ARG FORGE_VERSION=61.0.8

USER root
COPY --chmod=755 forge/entrypoint.sh /entrypoint.sh

ENV FORGE_MINECRAFT_VERSION="${FORGE_MINECRAFT_VERSION}" \
    FORGE_VERSION="${FORGE_VERSION}" \
    JVM_FLAGS="-Xms2G -Xmx2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"

USER minecraft
ENTRYPOINT ["/entrypoint.sh"]
