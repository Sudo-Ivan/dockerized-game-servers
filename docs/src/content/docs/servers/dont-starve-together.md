---
title: Don't Starve Together
description: Don't Starve Together dedicated server (native Linux, Master and Caves shards).
---

On first start the container downloads the Don't Starve Together Linux dedicated server (Steam app 343050) into your data folder. It runs a Master shard and, by default, a Caves shard in the same container. Cluster config and saves live under klei/DoNotStarveTogether/ once the server has started.

:::note[Before you start]
- Keep a data folder for the installed server and Klei cluster data
- Open UDP ports 10999 (Master), 11000 (Caves), and 27016 (Steam master listing)
- Set DST_CLUSTER_TOKEN to a Klei cluster token from https://accounts.klei.com/ for online play
- The compose file sets a 4 GB memory limit. Give the host at least that much RAM
- Anonymous Steam login works for the dedicated server install
:::

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 10999 | UDP | Master shard game port (DST_MASTER_PORT) |
| 11000 | UDP | Caves shard game port (DST_CAVES_PORT) |
| 27016 | UDP | Steam master server port for the Master shard (DST_STEAM_MASTER_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| STEAM_USERNAME | anonymous | Steam login used during the install step |
| STEAM_PASSWORD | (empty) | Steam password |
| STEAM_GUARD_CODE | (empty) | Steam Guard code |
| DST_APP_ID | 343050 | Steam app ID to install |
| DST_FORCE_UPDATE | false | Re-download the server from Steam on next start |
| DST_CLUSTER | Cluster_1 | Cluster folder name under klei/DoNotStarveTogether/ |
| DST_CLUSTER_TOKEN | (empty) | Klei cluster token, written to cluster_token.txt on first start |
| DST_ENABLE_CAVES | true | Start a Caves shard alongside the Master shard |
| DST_MAX_PLAYERS | 6 | Player cap written to cluster.ini on first start |
| DST_GAME_MODE | survival | Game mode written to cluster.ini on first start |
| DST_MASTER_PORT | 10999 | Master shard UDP port |
| DST_CAVES_PORT | 11000 | Caves shard UDP port |
| DST_STEAM_MASTER_PORT | 27016 | Steam master port for the Master shard |
| DST_EXTRA_ARGS | (empty) | Extra flags appended to both shard launch commands |

## Cluster config

The container writes cluster.ini, Master/server.ini, and Caves/server.ini on first start if they are missing. DST_CLUSTER_TOKEN is written to cluster_token.txt once when the file does not exist. After that, edit cluster files on the host directly.

```text
dont-starve-together/data/klei/DoNotStarveTogether/Cluster_1/
```

Stop the container before editing, then start it again for changes to take effect.

## Data folder

Your data folder mounts to /opt/dst inside the container. It holds the installed server binaries plus Klei cluster data under klei/DoNotStarveTogether/.

## Compose

```bash
docker compose -f dont-starve-together/docker-compose.yml up -d
```

## Docker run

```bash
docker run -d --name dont-starve-together --restart unless-stopped --init \
  -p 10999:10999/udp -p 11000:11000/udp -p 27016:27016/udp \
  -v "$PWD/dont-starve-together/data:/opt/dst" \
  -e DST_CLUSTER_TOKEN="your-klei-cluster-token" \
  {{IMAGE_PREFIX}}/dont-starve-together:latest
```

## Updates

Set DST_FORCE_UPDATE to true and recreate the container, or use the update command described in [Ops](/guides/ops/).

## Health check

The container reports healthy while the dontstarve_dedicated_server process is running. Startup gets a 900 second grace period.
