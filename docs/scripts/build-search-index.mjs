#!/usr/bin/env node
import { mkdirSync, writeFileSync } from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { buildSearchIndex } from '../src/lib/search-index.mjs'

const docsDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const outDir = path.join(docsDir, 'public')
const outFile = path.join(outDir, 'search-index.json')

mkdirSync(outDir, { recursive: true })
const index = buildSearchIndex()
writeFileSync(outFile, `${JSON.stringify(index)}\n`)
console.log(`search index wrote ${index.documents.length} documents to public/search-index.json`)
