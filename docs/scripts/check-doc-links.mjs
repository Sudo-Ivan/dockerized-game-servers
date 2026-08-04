#!/usr/bin/env node
/**
 * Validate internal markdown links under docs/src/content/docs.
 */
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const docsDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const contentRoot = path.join(docsDir, 'src/content/docs')
const distRoot = path.join(docsDir, 'dist')

const LINK_RE = /\]\(([^)]+)\)/g
const SKIP_PREFIX = /^(https?:|mailto:|#)/

// Broken when {{...}} tokens were replaced with dockerized/... by mistake.
const CORRUPT_TOKEN_RE =
	/dockerized\/(code>|code\b|empty|codec|anonymous|changeme|false|true|minecraft:|starbound_server|enshrouded_server|dayzOffline)/

/**
 * @param {string} dir
 * @param {string[]} files
 */
function walkMd(dir, files = []) {
	for (const name of readdirSync(dir)) {
		const full = path.join(dir, name)
		const st = statSync(full)
		if (st.isDirectory()) {
			walkMd(full, files)
			continue
		}
		if (name.endsWith('.md') || name.endsWith('.mdx')) files.push(full)
	}
	return files
}

/**
 * @param {string} href
 */
function stripHref(href) {
	let h = href.trim()
	if (SKIP_PREFIX.test(h)) return null
	const hash = h.indexOf('#')
	if (hash >= 0) h = h.slice(0, hash)
	const query = h.indexOf('?')
	if (query >= 0) h = h.slice(0, query)
	h = h.trim()
	if (!h) return null
	return h
}

/**
 * @param {string} fromFile
 * @param {string} href
 */
function resolveMarkdownTarget(fromFile, href) {
	let h = stripHref(href)
	if (!h) return null

	if (h.startsWith('/')) {
		h = h.replace(/^\//, '').replace(/\/$/, '')
		if (!h) return path.join(contentRoot, 'index.md')
		const sibling = path.join(contentRoot, `${h}.md`)
		if (existsSync(sibling)) return sibling
		const dirIndex = path.join(contentRoot, h, 'index.md')
		if (existsSync(dirIndex)) return dirIndex
		return sibling
	}

	let resolved = path.normalize(path.join(path.dirname(fromFile), h))
	if (h.endsWith('/')) {
		resolved = resolved.replace(/[/\\]$/, '')
	}
	if (!resolved.endsWith('.md') && !resolved.endsWith('.mdx')) {
		if (existsSync(`${resolved}.md`)) resolved = `${resolved}.md`
		else if (existsSync(`${resolved}.mdx`)) resolved = `${resolved}.mdx`
		else if (existsSync(path.join(resolved, 'index.md'))) resolved = path.join(resolved, 'index.md')
		else if (existsSync(path.join(resolved, 'index.mdx'))) resolved = path.join(resolved, 'index.mdx')
		else resolved = `${resolved}.md`
	}
	return resolved
}

/**
 * @param {string} slugPath
 */
function distHtmlForSlug(slugPath) {
	const slug = slugPath.replace(/^\//, '').replace(/\/$/, '')
	if (!slug) return path.join(distRoot, 'index.html')
	if (slug === '404') return path.join(distRoot, '404.html')
	return path.join(distRoot, slug, 'index.html')
}

/** @type {string[]} */
const errors = []

for (const file of walkMd(contentRoot)) {
	const text = readFileSync(file, 'utf8')
	if (CORRUPT_TOKEN_RE.test(text)) {
		errors.push(`${path.relative(contentRoot, file)}: corrupted token (dockerized/... where a template value or HTML tag was expected)`)
	}
	for (const match of text.matchAll(LINK_RE)) {
		const href = match[1]
		if (href.includes('{{')) continue
		const target = resolveMarkdownTarget(file, href)
		if (!target) continue
		if (!existsSync(target)) {
			errors.push(`${path.relative(contentRoot, file)}: broken link (${href}) -> ${path.relative(contentRoot, target)}`)
		}
	}
}

if (existsSync(distRoot)) {
	for (const file of walkMd(contentRoot)) {
		const rel = path.relative(contentRoot, file).replace(/\.mdx?$/, '').replace(/\\/g, '/')
		// A directory's `index.md` (nested or top-level) maps to the directory itself.
		const slug = rel === 'index' ? '' : rel.replace(/\/index$/, '')
		const htmlPath = distHtmlForSlug(slug)
		if (!existsSync(htmlPath)) {
			errors.push(`dist missing page for ${rel || 'index'} (expected ${path.relative(docsDir, htmlPath)})`)
		}
	}
}

if (errors.length) {
	console.error('doc link check failed:')
	for (const err of errors) console.error(`  ${err}`)
	process.exit(1)
}

console.log('doc link check ok')
