---
title: Ground Branch
description: Ground Branch dedicated server (Wine).
---

Compose path: ground-branch. Image: ground-branch.

## Ports and volume

- UDP 7777 and UDP 27015
- Data volume: ground-branch/data mounted at /opt/groundbranch

Server config appears under ground-branch/data/GroundBranch/ServerConfig/ after first start. Optional map and mission via GB_MAP and GB_MISSION.

## Docker run

```bash
docker run -d --name ground-branch --restart unless-stopped --init \
  -p 7777:7777/udp -p 27015:27015/udp \
  -v "$PWD/ground-branch/data:/opt/groundbranch" \
  {{IMAGE_PREFIX}}/ground-branch:latest
```
