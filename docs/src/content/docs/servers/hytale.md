---
title: Hytale
description: Hytale server via an external image.
---

Compose path: hytale. This entry uses the external image deinfreu/hytale-server.

## Notes

- UDP 5520
- Data volume: hytale/data → /home/container
- Bind /etc/machine-id read-only
- Set SERVER_IP and SERVER_PORT

## Docker run

```bash
docker run -d --name hytale-server --restart unless-stopped \
  -p 5520:5520/udp \
  -v "$PWD/hytale/data:/home/container" \
  -v /etc/machine-id:/etc/machine-id:ro \
  -e SERVER_IP=0.0.0.0 \
  -e SERVER_PORT=5520 \
  deinfreu/hytale-server:latest
```
