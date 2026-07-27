#!/usr/bin/env node
import { readdirSync, readFileSync, statSync } from 'node:fs'
import path from 'node:path'

const root = path.resolve('dist')
const tokens = ['{{IMAGE_PREFIX}}', '{{GITHUB_URL}}', '{{DOCS_URL}}', '{{REPO}}', '{{IMAGE_OWNER}}']
const hits = []

function walk(dir) {
	for (const name of readdirSync(dir)) {
		const full = path.join(dir, name)
		const st = statSync(full)
		if (st.isDirectory()) {
			walk(full)
			continue
		}
		if (!name.endsWith('.html')) continue
		const text = readFileSync(full, 'utf8')
		for (const token of tokens) {
			if (text.includes(token)) hits.push(`${full}: ${token}`)
		}
	}
}

walk(root)

if (hits.length) {
	console.error('Unresolved docs tokens:')
	for (const hit of hits) console.error(`  ${hit}`)
	process.exit(1)
}

console.log('docs token check ok')
