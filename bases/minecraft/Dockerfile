FROM alpine:3.23 AS temurin

ARG TARGETARCH
ARG TEMURIN_VERSION=25.0.3_9
ARG TEMURIN_RELEASE=jdk-25.0.3%2B9

RUN apk add --no-cache ca-certificates curl tar \
  && case "${TARGETARCH:-amd64}" in \
    amd64) temurin_arch="x64" ;; \
    arm64) temurin_arch="aarch64" ;; \
    *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
  esac \
  && curl -fsSL "https://github.com/adoptium/temurin25-binaries/releases/download/${TEMURIN_RELEASE}/OpenJDK25U-jre_${temurin_arch}_alpine-linux_hotspot_${TEMURIN_VERSION}.tar.gz" -o /tmp/temurin.tar.gz \
  && curl -fsSL "https://github.com/adoptium/temurin25-binaries/releases/download/${TEMURIN_RELEASE}/OpenJDK25U-jre_${temurin_arch}_alpine-linux_hotspot_${TEMURIN_VERSION}.tar.gz.sha256.txt" -o /tmp/temurin.sha256.txt \
  && echo "$(awk '{print $1}' /tmp/temurin.sha256.txt)  /tmp/temurin.tar.gz" | sha256sum -c - \
  && mkdir -p /opt/java \
  && tar -xzf /tmp/temurin.tar.gz -C /opt/java --strip-components=1 \
  && rm /tmp/temurin.tar.gz /tmp/temurin.sha256.txt

FROM alpine:3.23

RUN apk add --no-cache ca-certificates curl jq shadow \
  && addgroup -g 1000 minecraft \
  && adduser -D -u 1000 -G minecraft -h /home/minecraft minecraft

COPY --from=temurin /opt/java /opt/java
COPY runtime.sh /runtime.sh
RUN chmod +x /runtime.sh

WORKDIR /data
RUN chown minecraft:minecraft /data

EXPOSE 25565

ENV JAVA_HOME="/opt/java" \
    PATH="/opt/java/bin:${PATH}" \
    HOME="/data"

USER minecraft
