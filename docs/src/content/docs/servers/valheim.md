---
title: Valheim
description: Valheim and Valheim Plus dedicated servers.
---

| Variant | Compose | Image |
| --- | --- | --- |
| Vanilla | valheim/vanilla | valheim |
| Plus | valheim/plus | valheim-plus |

:::note[Requirements]
- Set `SERVER_PASS` (via `-e` or a `.env` next to compose)
- Persist data under `/opt/valheim` in the container
- Publish UDP **2456–2458**
:::

## Docker run

Valheim:

```bash
docker run -d --name valheim --restart unless-stopped --init \
  -p 2456-2458:2456-2458/udp \
  -v "$PWD/valheim/vanilla/data:/opt/valheim" \
  -e SERVER_PASS=changeme \
  {{IMAGE_PREFIX}}/valheim:latest
```

Valheim Plus:

```bash
docker run -d --name valheim-plus --restart unless-stopped --init \
  -p 2456-2458:2456-2458/udp \
  -v "$PWD/valheim/plus/data:/opt/valheim" \
  -e SERVER_PASS=changeme \
  {{IMAGE_PREFIX}}/valheim-plus:latest
```
