FROM alpine:3.23@sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40 AS temurin

ARG TARGETARCH
ARG TEMURIN_MAJOR=25
ARG TEMURIN_VERSION=25.0.3_9
ARG TEMURIN_RELEASE=jdk-25.0.3+9

RUN apk add --no-cache ca-certificates curl tar \
  && case "${TARGETARCH:-amd64}" in \
    amd64) temurin_arch="x64" ;; \
    arm64) temurin_arch="aarch64" ;; \
    *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
  esac \
  && release_path="$(printf '%s' "${TEMURIN_RELEASE}" | sed 's/+/%2B/g')" \
  && curl -fsSL "https://github.com/adoptium/temurin${TEMURIN_MAJOR}-binaries/releases/download/${release_path}/OpenJDK${TEMURIN_MAJOR}U-jre_${temurin_arch}_alpine-linux_hotspot_${TEMURIN_VERSION}.tar.gz" -o /tmp/temurin.tar.gz \
  && curl -fsSL "https://github.com/adoptium/temurin${TEMURIN_MAJOR}-binaries/releases/download/${release_path}/OpenJDK${TEMURIN_MAJOR}U-jre_${temurin_arch}_alpine-linux_hotspot_${TEMURIN_VERSION}.tar.gz.sha256.txt" -o /tmp/temurin.sha256.txt \
  && echo "$(awk '{print $1}' /tmp/temurin.sha256.txt)  /tmp/temurin.tar.gz" | sha256sum -c - \
  && mkdir -p /opt/java \
  && tar -xzf /tmp/temurin.tar.gz -C /opt/java --strip-components=1 \
  && rm -f /tmp/temurin.tar.gz /tmp/temurin.sha256.txt

FROM alpine:3.23@sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40

ARG TEMURIN_MAJOR=25

LABEL org.opencontainers.image.title="minecraft-base" \
      org.opencontainers.image.description="Shared Alpine + Temurin JRE base for Minecraft servers" \
      org.opencontainers.image.licenses="ISC"

RUN apk add --no-cache ca-certificates curl jq shadow \
  && addgroup -g 1000 minecraft \
  && adduser -D -u 1000 -G minecraft -h /home/minecraft minecraft \
  && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

COPY --from=temurin /opt/java /opt/java
COPY --chmod=755 runtime.sh /runtime.sh

WORKDIR /data
RUN chown minecraft:minecraft /data

EXPOSE 25565

ENV JAVA_HOME="/opt/java" \
    PATH="/opt/java/bin:${PATH}" \
    HOME="/data" \
    MC_JAVA_MAJOR="${TEMURIN_MAJOR}"

STOPSIGNAL SIGTERM
