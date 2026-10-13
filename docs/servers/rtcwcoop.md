---
title: RTCW Cooperative
description: RTCWCoop dedicated server for the Return to Castle Wolfenstein co-op single player campaign.
---

# RTCW Cooperative

This image ships the [RTCWCoop](https://github.com/rtcwcoop/rtcwcoop) 1.0.2 dedicated binary, the coopmain mod files, and all of the 1.41 RTCW data packs that can be redistributed (pak0.pk3, mp_* packs, sp_pak2 through sp_pak4). It plays the full co-op single player campaign with friends.

!!! note "Before you start"

    - You must own Return to Castle Wolfenstein
    - Copy sp_pak1.pk3 from your RTCW install into the data folder before the first start, the server refuses to run without it
    - Keep a data folder for the server install and coopmain/server.cfg
    - Open UDP port 27960 (or the port you set with RTCWCOOP_PORT, on both host and container)

## Required game file

The co-op engine needs one retail file that cannot be bundled. Copy `sp_pak1.pk3` from the `Main` folder of your RTCW install (Steam library or the original CD) into:

```text
poderized/rtcwcoop/data/main/sp_pak1.pk3
```

Every other file the campaign needs is seeded into the data volume on first start. A file copied in before the first run is kept, the seed only fills in what is missing.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 27960 | UDP | Game traffic (RTCWCOOP_PORT) |

## Settings

| Setting | Default | What it does |
| --- | --- | --- |
| RTCWCOOP_IP | 0.0.0.0 | Bind address |
| RTCWCOOP_PORT | 27960 | Game UDP port, applied on every start |
| RTCWCOOP_MAXPLAYERS | 8 | Max players, written into server.cfg only when that file is first created |
| RTCWCOOP_STARTMAP | escape1 | Campaign map loaded at boot, applied on every start |
| RTCWCOOP_HOSTNAME | RTCWCoop Campaign Server | Server browser name, written into server.cfg only when that file is first created |
| RTCWCOOP_EXTRA_ARGS | (empty) | Extra launch flags appended to the start command |

RTCWCOOP_MAXPLAYERS and RTCWCOOP_HOSTNAME only matter when coopmain/server.cfg is generated for the first time. The campaign is built for small groups, so the default max is 8 rather than the 32 a normal Wolfenstein server would use.

## Data folder

Your data folder mounts to /opt/rtcwcoop inside the container. On first start the image copies its bundled files in without overwriting anything you placed there.

coopmain/server.cfg is created once if it does not exist:

```text
set sv_hostname "<RTCWCOOP_HOSTNAME>"
set rcon_password "changeme"
set g_allowvote 1
set sv_maxclients <RTCWCOOP_MAXPLAYERS>
```

The default rcon password is changeme. Edit poderized/rtcwcoop/data/coopmain/server.cfg on the host with the container stopped to change it.

## Updates

There is no one-command update for this server. The RTCWCoop 1.0.2 release from 2017 is the current stable release. Delete the `.rtcwcoop-seed-complete` marker and your seeded files to re-seed the volume, or rebuild the image for newer assets.

## Health check

The container reports healthy while the rtcwcoopded process is running. Startup gets a 120 second grace period.

## Compose

```bash
podman compose -f poderized/rtcwcoop/compose.yml up -d
```

## podman run

```bash
podman run -d --name rtcwcoop --restart unless-stopped --init \
  -p 27960:27960/udp \
  -v "$PWD/poderized/rtcwcoop/data:/opt/rtcwcoop" \
  -e RTCWCOOP_PORT=27960 \
  -e RTCWCOOP_MAXPLAYERS=8 \
  -e RTCWCOOP_STARTMAP=escape1 \
  -e RTCWCOOP_HOSTNAME="RTCWCoop Campaign Server" \
  {{IMAGE_PREFIX}}/rtcwcoop:latest
```
