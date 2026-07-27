#!/usr/bin/env node
/**
 * Every first-party server catalog id must have a matching servers/*.md guide.
 */
import { execFileSync } from 'node:child_process'
import { existsSync } from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const docsDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const repoRoot = path.resolve(docsDir, '..')
const serversDir = path.join(docsDir, 'src/content/docs/servers')

/** @type {Record<string, string>} */
const DOC_SLUG_BY_CATALOG_ID = {
	fabric: 'minecraft',
	vanilla: 'minecraft',
	forge: 'minecraft',
	neoforge: 'minecraft',
	'valheim-plus': 'valheim',
}

const catalog = execFileSync(path.join(repoRoot, 'ci/server-catalog.sh'), {
	encoding: 'utf8',
	cwd: repoRoot,
})
	.split('\n')
	.map((line) => line.trim())
	.filter(Boolean)
	.map((line) => {
		const [id, , , , , , firstParty] = line.split('\t')
		return { id, firstParty }
	})

/** @type {string[]} */
const missing = []

for (const { id, firstParty } of catalog) {
	if (firstParty !== '1') continue
	const slug = DOC_SLUG_BY_CATALOG_ID[id] || id
	const docPath = path.join(serversDir, `${slug}.md`)
	if (!existsSync(docPath)) {
		missing.push(`${id} -> servers/${slug}.md`)
	}
}

if (missing.length) {
	console.error('doc catalog check failed (missing server guides):')
	for (const row of missing) console.error(`  ${row}`)
	process.exit(1)
}

console.log(`doc catalog check ok (${catalog.filter((r) => r.firstParty === '1').length} first-party servers)`)
