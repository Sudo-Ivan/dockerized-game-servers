ARG BASE_IMAGE=ghcr.io/sudo-ivan/dockerized-game-servers/minecraft-base:latest
FROM ${BASE_IMAGE}

ARG FABRIC_MINECRAFT_VERSION=26.2
ARG FABRIC_LOADER_VERSION=0.19.3
ARG FABRIC_INSTALLER_VERSION=1.1.1

USER root
COPY --chmod=755 fabric/entrypoint.sh /entrypoint.sh

ENV FABRIC_MINECRAFT_VERSION="${FABRIC_MINECRAFT_VERSION}" \
    FABRIC_LOADER_VERSION="${FABRIC_LOADER_VERSION}" \
    FABRIC_INSTALLER_VERSION="${FABRIC_INSTALLER_VERSION}" \
    JVM_FLAGS="-Xms2G -Xmx2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"

USER minecraft
ENTRYPOINT ["/entrypoint.sh"]
