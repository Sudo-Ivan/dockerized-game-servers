# Docs site

Starlight (Astro) site for this repository. Pages build to static HTML and stay readable without JavaScript.

Owner, repo, GHCR prefix, and Pages URLs resolve from git remote or GITHUB_REPOSITORY at build time.

## Requirements

- Node.js 22.12+
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

Build writes a Fuse.js search index to public/search-index.json, then emits static HTML to dist/. Search UI loads only for JavaScript clients. GitHub Pages deploys from .github/workflows/docs.yml.
