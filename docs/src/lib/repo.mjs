import { execFileSync } from 'node:child_process'
import { fileURLToPath } from 'node:url'
import path from 'node:path'

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..')

function fromShell() {
	const out = execFileSync(path.join(root, 'ci/repo-meta.sh'), ['--print'], {
		encoding: 'utf8',
		env: process.env,
	})
	/** @type {Record<string, string>} */
	const meta = {}
	for (const line of out.split('\n')) {
		const i = line.indexOf('=')
		if (i <= 0) continue
		meta[line.slice(0, i)] = line.slice(i + 1)
	}
	return meta
}

/** @returns {{ repo: string, owner: string, name: string, imageOwner: string, imagePrefix: string, githubUrl: string, siteUrl: string, siteBase: string, docsUrl: string }} */
export function resolveRepo() {
	const meta = fromShell()
	return {
		repo: meta.REPO,
		owner: meta.OWNER,
		name: meta.NAME,
		imageOwner: meta.IMAGE_OWNER,
		imagePrefix: meta.IMAGE_PREFIX,
		githubUrl: meta.GITHUB_URL,
		siteUrl: meta.SITE_URL,
		siteBase: meta.SITE_BASE,
		docsUrl: meta.DOCS_URL,
	}
}

/**
 * Replace build-time tokens in markdown text and code nodes.
 * @param {Record<string, string>} tokens
 */
export function remarkRepoTokens(tokens) {
	const entries = Object.entries(tokens)
	const replace = (value) => {
		let next = value
		for (const [token, replacement] of entries) {
			next = next.split(token).join(replacement)
		}
		return next
	}

	return () => (tree) => {
		const walk = (node) => {
			if (!node || typeof node !== 'object') return
			if (
				(node.type === 'text' || node.type === 'code' || node.type === 'inlineCode') &&
				typeof node.value === 'string'
			) {
				node.value = replace(node.value)
			}
			if (Array.isArray(node.children)) {
				for (const child of node.children) walk(child)
			}
		}
		walk(tree)
	}
}
