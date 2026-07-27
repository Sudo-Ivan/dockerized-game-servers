import { readdirSync, readFileSync, statSync } from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { resolveRepo } from './repo.mjs'

const docsRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../content/docs')

/**
 * @param {string} text
 * @param {Record<string, string>} tokens
 */
function applyTokens(text, tokens) {
	let next = text
	for (const [token, replacement] of Object.entries(tokens)) {
		next = next.split(token).join(replacement)
	}
	return next
}

/**
 * @param {string} raw
 */
function parseMarkdownDoc(raw) {
	let body = raw
	/** @type {Record<string, string>} */
	const data = {}

	if (raw.startsWith('---\n')) {
		const end = raw.indexOf('\n---\n', 4)
		if (end !== -1) {
			const fm = raw.slice(4, end)
			body = raw.slice(end + 5)
			for (const line of fm.split('\n')) {
				const i = line.indexOf(':')
				if (i <= 0) continue
				const key = line.slice(0, i).trim()
				let value = line.slice(i + 1).trim()
				if (
					(value.startsWith('"') && value.endsWith('"')) ||
					(value.startsWith("'") && value.endsWith("'"))
				) {
					value = value.slice(1, -1)
				}
				data[key] = value
			}
		}
	}

	const plain = body
		.replace(/```[\s\S]*?```/g, ' ')
		.replace(/`([^`]+)`/g, '$1')
		.replace(/!\[[^\]]*\]\([^)]+\)/g, ' ')
		.replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
		.replace(/^#{1,6}\s+/gm, '')
		.replace(/[*_>~|-]+/g, ' ')
		.replace(/\s+/g, ' ')
		.trim()

	return { data, plain }
}

/**
 * @param {string} filePath
 * @param {string} base
 */
function fileToHref(filePath, base) {
	const rel = path.relative(docsRoot, filePath).split(path.sep).join('/')
	if (rel === '404.md' || rel === 'offline.md' || rel === 'error.md' || rel === 'gone.md') {
		return null
	}
	const withoutExt = rel.replace(/\.mdx?$/, '')
	const slug = withoutExt === 'index' ? '' : withoutExt.replace(/\/index$/, '')
	const prefix = base.endsWith('/') ? base.slice(0, -1) : base
	if (!slug) return `${prefix}/`
	return `${prefix}/${slug}/`
}

/**
 * Build the Fuse.js search corpus from Markdown docs.
 * @returns {{ generatedAt: string, documents: Array<{ title: string, description: string, body: string, href: string, category: string }> }}
 */
export function buildSearchIndex() {
	const repo = resolveRepo()
	const tokens = {
		'{{IMAGE_PREFIX}}': repo.imagePrefix,
		'{{GITHUB_URL}}': repo.githubUrl,
		'{{DOCS_URL}}': repo.docsUrl,
		'{{REPO}}': repo.repo,
		'{{IMAGE_OWNER}}': repo.imageOwner,
	}

	/** @type {string[]} */
	const files = []
	const walk = (dir) => {
		for (const name of readdirSync(dir)) {
			const full = path.join(dir, name)
			const st = statSync(full)
			if (st.isDirectory()) {
				walk(full)
				continue
			}
			if (name.endsWith('.md') || name.endsWith('.mdx')) files.push(full)
		}
	}
	walk(docsRoot)

	const documents = []
	for (const file of files.sort()) {
		const href = fileToHref(file, repo.siteBase)
		if (!href) continue
		const raw = applyTokens(readFileSync(file, 'utf8'), tokens)
		const { data, plain } = parseMarkdownDoc(raw)
		const title = data.title || path.basename(file, path.extname(file))
		let category = 'Overview'
		if (href.includes('/servers/')) category = 'Server'
		else if (href.includes('/guides/')) category = 'Guide'
		else if (href.includes('/reference/')) category = 'Reference'
		documents.push({
			title,
			description: data.description || '',
			body: plain,
			href,
			category,
		})
	}

	return {
		generatedAt: new Date().toISOString(),
		documents,
	}
}
