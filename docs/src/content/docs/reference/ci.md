---
title: CI
description: Checks, image builds, and Minecraft versioned builds.
---

This page describes the automated checks and image builds that run on GitHub. You do not need any of this to run a server from published images. It is here if you fork the repo, contribute changes, or wonder when new images appear on GitHub Container Registry.

## Workflows

**ci** runs on pushes and pull requests when CI-related files change (see `.github/workflows/ci.yml`). You can also start it manually. It runs repository checks (`ci/ci-check.sh`), scans Dockerfiles with Trivy for MEDIUM, HIGH, and CRITICAL issues, and on pull requests with Docker-related diffs it builds shared base images locally to verify they compile. Those verify builds are not pushed to the registry.

**build** runs weekly (Sunday 06:00 UTC), when Dockerfiles, base images, or CI scripts change on master or main, and on manual trigger. The job list comes from `ci/image-matrix.sh` (`ci/github-matrix.py`). It builds and pushes images to GHCR through the reusable `docker-image` workflow, then scans them with Trivy. A CRITICAL finding fails the job.

**build-minecraft** is manual only. Pick Fabric, Vanilla, Forge, or NeoForge and a Minecraft version. Java is resolved from Mojang's javaVersion. Temurin Alpine JRE is pinned from Adoptium. Fabric loader and installer, and Forge promos, auto-fill when left blank. NeoForge resolves from Maven when omitted. The workflow publishes `minecraft-base`:javaN and `minecraft-flavor`:tag.

## What ci-check covers

- Image matrix path checks (`ci/image-matrix.sh`)
- Compose validation from the server catalog (`ci/server-catalog.sh`), so the list of servers stays in one place
- Reject fixed GHCR owners in first-party compose files
- Shell syntax over catalog-discovered server roots
- ShellCheck (`ci/shellcheck.sh`)
- Healthcheck presence and offline probes (`ci/test-healthchecks.sh`)
- Host tools catalog and tar round-trip (`ci/test-tools.sh`)
- Docs pnpm lockfile conventions
- Docs static build, internal link validation, and server catalog guide coverage (`ci/test-docs.sh`)
- Valid GitHub Actions matrix JSON from `ci/github-matrix.py`

## Example tags

After a versioned Fabric build for 26.2:

```text
__IMAGE_PREFIX__/minecraft-base:java25
__IMAGE_PREFIX__/minecraft-fabric:26.2
```

## Local resolve preview

Preview what a Minecraft build would resolve to before triggering the workflow:

```bash
./ci/resolve-minecraft-build.sh --flavor fabric --minecraft-version 26.2
./ci/resolve-minecraft-build.sh --flavor vanilla --minecraft-version 1.20.4
./ci/resolve-minecraft-build.sh --flavor forge --minecraft-version 1.21.8 --forge-channel latest
```

## Security scanning

Trivy is installed from a pinned GitHub release tarball with SHA-256 verification (`ci/install-trivy.sh`). This repo does not use aquasecurity/trivy-action after the March 2026 supply-chain compromise. Shared scan settings live in `dockerized/trivy.yaml`.

## Workflow security

Workflows follow [GitHub Actions secure use](https://docs.github.com/en/actions/reference/security/secure-use) practices:

- Default `permissions: contents: read`. Jobs that push to GHCR add `packages: write` only on those jobs.
- Third-party actions are pinned to full commit SHAs (with version comments).
- `actions/checkout` uses `persist-credentials: false` so the job token is not left in `.git/config`.
- Pull requests use the default `pull_request` trigger (not `pull_request_target`). Verify jobs use read-scoped `GITHUB_TOKEN`.
- `workflow_dispatch` inputs are passed into shell steps via `env`, not `${{ }}` interpolation in `run` scripts.
- `.github/CODEOWNERS` requires review for workflow changes.

In GitHub repository settings, prefer default workflow token read-only, restrict allowed actions, and avoid enabling "Allow GitHub Actions to create and approve pull requests" unless required.

## GHCR publish failures

Build logs that end with `denied: installation not allowed to Write organization package` mean the image compiled locally but `GITHUB_TOKEN` could not push to GHCR. Fix repository (and organization, if applicable) workflow **Read and write** permissions and grant this repository **Write** on the GHCR package via package **Manage Actions access**. PR verify jobs do not push (`push: false`).

Base images are always pushed so matrix jobs can reuse them. Manual builds can set the push input for game images.
