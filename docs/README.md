# Docs site

Starlight (Astro) site for this repository. Pages build to static HTML and stay readable without JavaScript.

Owner, repo, GHCR prefix, and Pages URLs resolve from git remote or GITHUB_REPOSITORY at build time.

## Requirements

- Node.js 22.13+
- pnpm 11.17.0+ (pinned in package.json)

## Local preview

```bash
cd docs
pnpm install
pnpm run dev
```

## Build

```bash
cd docs
pnpm install --frozen-lockfile
pnpm audit --prod
pnpm run build
```

Build writes public assets then emits static HTML to dist/:

- Fuse.js search index (search-index.json)
- Markdown export zip (dgs-docs.zip)
- robots.txt and generated site identity for SEO/JSON-LD
- Web app manifest and service worker (network-first HTML so docs do not stay stale)
- SVG favicon and app icon

Search UI and the PWA service worker load only for JavaScript clients. GitHub Pages deploys from .github/workflows/docs.yml with full git history so last-updated dates resolve.
