---
title: CI
description: Checks, image builds, and Minecraft versioned builds.
---

## Workflows

- ci on push and pull request when CI-relevant paths change (see `.github/workflows/ci.yml`), plus manual runs. It runs repository checks (`ci/ci-check.sh`), Trivy Dockerfile config scans (MEDIUM, HIGH, and CRITICAL), and on pull requests with Docker-related diffs local Docker builds for shared base images (no registry push).
- build runs weekly (Sunday 06:00 UTC), on Dockerfile, base, or ci path changes to master or main, and manually. The job matrix comes from `ci/image-matrix.sh` (`ci/github-matrix.py`). It builds and pushes GHCR images through the reusable `docker-image` workflow, then Trivy-scans them (CRITICAL fails the job).
- build-minecraft is manual only. Pick Fabric, Vanilla, or Forge plus a Minecraft version. Java is resolved from Mojang's javaVersion. Temurin Alpine JRE is pinned from Adoptium. Fabric loader and installer, and Forge promos, auto-fill when left blank. Publishes minecraft-base:javaN and minecraft-flavor:tag (tag defaults to the MC version, or mc-forge for Forge).

## What ci-check covers

- Image matrix path checks (`ci/image-matrix.sh`)
- Compose validation from `ci/server-catalog.sh` (no hardcoded compose list)
- Reject fixed GHCR owners in first-party compose files
- Shell syntax over catalog-discovered roots
- ShellCheck (`ci/shellcheck.sh`)
- Healthcheck presence and offline probes (`ci/test-healthchecks.sh`)
- Host tools catalog and tar round-trip (`ci/test-tools.sh`)
- Docs pnpm lockfile conventions
- Valid GitHub Actions matrix JSON from `ci/github-matrix.py`

## Example tags

After a versioned Fabric build for 26.2:

```text
__IMAGE_PREFIX__/minecraft-base:java25
__IMAGE_PREFIX__/minecraft-fabric:26.2
```

## Local resolve preview

```bash
./ci/resolve-minecraft-build.sh --flavor fabric --minecraft-version 26.2
./ci/resolve-minecraft-build.sh --flavor vanilla --minecraft-version 1.20.4
./ci/resolve-minecraft-build.sh --flavor forge --minecraft-version 1.21.8 --forge-channel latest
```

## Security scanning

Trivy is installed from a pinned GitHub release tarball with SHA-256 verification (ci/install-trivy.sh). This repo does not use aquasecurity/trivy-action after the March 2026 supply-chain compromise. Shared scan settings live in trivy.yaml.

## Workflow security

Workflows follow [GitHub Actions secure use](https://docs.github.com/en/actions/reference/security/secure-use) practices:

- Default `permissions: contents: read`. Jobs that push to GHCR add `packages: write` only on those jobs.
- Third-party actions are pinned to full commit SHAs (with version comments).
- `actions/checkout` uses `persist-credentials: false` so the job token is not left in `.git/config`.
- Pull requests use the default `pull_request` trigger (not `pull_request_target`). Verify jobs use read-scoped `GITHUB_TOKEN`.
- `workflow_dispatch` inputs are passed into shell steps via `env`, not `${{ }}` interpolation in `run` scripts.
- `.github/CODEOWNERS` requires review for workflow changes.

In GitHub repository settings, prefer default workflow token read-only, restrict allowed actions, and avoid enabling "Allow GitHub Actions to create and approve pull requests" unless required.

Base images are always pushed so matrix jobs can reuse them. Manual builds can set the push input for game images.
