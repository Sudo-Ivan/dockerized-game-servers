---
title: Tools
description: Browser-based generators for server configs and Docker commands.
---

Interactive generators that build config files and Docker commands for the servers in this repository. Everything runs client-side in your browser. Nothing you type is uploaded or stored anywhere.

| Tool | Produces |
| --- | --- |
| [Arma 3 Config Generator](arma-3-config-generator/) | `server.cfg` for the [Arma 3](../servers/arma-3/) image |
| [Minecraft server.properties Generator](minecraft-server-properties-generator/) | `server.properties` for the [Minecraft](../servers/minecraft/) images |
| [Docker Run / Compose Generator](docker-run-generator/) | `docker run` commands and `docker-compose.yml` snippets for any server |

:::note[Client-side only]
Forms on these pages render output in your browser with plain JavaScript. Reloading the page resets the form.
:::

## Requesting a tool

Open an issue on [GitHub]({{GITHUB_URL}}/issues) if a generator for another server would help.
