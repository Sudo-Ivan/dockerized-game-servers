#!/usr/bin/env node
/**
 * Resolve and download sidebar icons for each servers/*.md page.
 *
 * Resolution order per page:
 * 1. Optional frontmatter iconUrl / steamAppId
 * 2. Steam app IDs discovered from matching compose/entrypoint files
 * 3. Steam store search by page title (exact name match)
 * 4. Wikipedia page thumbnail by title (with a few aliases)
 *
 * Writes public/game-icons/* and src/generated/game-icons.mjs
 */
import { execFileSync } from 'node:child_process'
import {
	existsSync,
	mkdirSync,
	readdirSync,
	readFileSync,
	rmSync,
	writeFileSync,
} from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { resolveRepo } from '../src/lib/repo.mjs'

const docsDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const repoRoot = path.resolve(docsDir, '..')
const serversDir = path.join(docsDir, 'src/content/docs/servers')
const iconsDir = path.join(docsDir, 'public/game-icons')
const generatedDir = path.join(docsDir, 'src/generated')

const UA =
	'dockerized-game-servers-docs/1.0 (+https://github.com/Sudo-Ivan/dockerized-game-servers)'

const STEAM_CDN = 'https://cdn.cloudflare.steamstatic.com/steam/apps'
const STEAM_ASSETS = ['library_600x900.jpg', 'capsule_sm_120.jpg', 'header.jpg', 'capsule_231x87.jpg']

/** App IDs that are redistributables or tooling, never game art. */
const SKIP_APP_IDS = new Set(['1007'])

/**
 * @param {string} name
 */
function isPreferredAppEnv(name) {
	if (/STEAMWORKS/i.test(name)) return false
	return /(?:GAME|STEAM)_APP_ID$/.test(name) && !/STEAMWORKS_APP_ID$/.test(name)
}

/**
 * @param {string} name
 */
function isFallbackAppEnv(name) {
	if (/STEAMWORKS/i.test(name)) return false
	if (isPreferredAppEnv(name)) return false
	return /_APP_ID$/.test(name)
}

/** Wikipedia titles when the docs title is not a useful page name. */
const WIKI_TITLE_ALIASES = {
	openmohaa: 'Medal of Honor: Allied Assault',
	l4d2: 'Left 4 Dead 2',
	'7-days-to-die': '7 Days to Die',
	'arma-3': 'Arma 3',
	'cs-source': 'Counter-Strike: Source',
	kf2: 'Killing Floor 2',
	'insurgency-source': 'Insurgency (2014 video game)',
	'insurgency-sandstorm': 'Insurgency: Sandstorm',
	'ground-branch': 'Ground Branch',
	'core-keeper': 'Core Keeper',
	'project-zomboid': 'Project Zomboid',
	'stardew-valley': 'Stardew Valley',
	'space-engineers': 'Space Engineers',
}

/** Direct icon URLs when Steam and Wikipedia have nothing usable. */
const DIRECT_ICON_URLS = {
	minecraft: 'https://minecraft.wiki/images/Grass_Block_JE7_BE6.png',
}

/**
 * @param {string} text
 */
function parseFrontmatter(text) {
	if (!text.startsWith('---\n')) return { attrs: {}, body: text }
	const end = text.indexOf('\n---\n', 4)
	if (end < 0) return { attrs: {}, body: text }
	const raw = text.slice(4, end)
	/** @type {Record<string, string>} */
	const attrs = {}
	for (const line of raw.split('\n')) {
		const m = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/)
		if (!m) continue
		attrs[m[1]] = m[2].trim().replace(/^['"]|['"]$/g, '')
	}
	return { attrs, body: text.slice(end + 5) }
}

/**
 * @param {string} composePath
 */
function catalogEntries() {
	const out = execFileSync(path.join(repoRoot, 'ci/server-catalog.sh'), {
		encoding: 'utf8',
		cwd: repoRoot,
	})
	return out
		.split('\n')
		.map((line) => line.trim())
		.filter(Boolean)
		.map((line) => {
			const [id, compose] = line.split('\t')
			return { id, compose }
		})
}

/**
 * @param {string} slug
 * @param {{ id: string, compose: string }[]} catalog
 */
function rootsForSlug(slug, catalog) {
	/** @type {Set<string>} */
	const roots = new Set()
	const direct = path.join(repoRoot, slug)
	if (existsSync(direct)) roots.add(direct)

	for (const entry of catalog) {
		const composeDir = path.dirname(path.join(repoRoot, entry.compose))
		const match =
			entry.id === slug ||
			entry.id.startsWith(`${slug}-`) ||
			entry.compose === `${slug}/docker-compose.yml` ||
			entry.compose.startsWith(`${slug}/`) ||
			entry.compose.includes(`/${slug}/`)
		if (match) roots.add(composeDir)
	}

	// Minecraft docs cover fabric/vanilla/forge variants.
	if (slug === 'minecraft') {
		for (const variant of ['fabric', 'vanilla', 'forge']) {
			const dir = path.join(repoRoot, 'minecraft', variant)
			if (existsSync(dir)) roots.add(dir)
		}
	}
	if (slug === 'valheim') {
		for (const variant of ['vanilla', 'plus']) {
			const dir = path.join(repoRoot, 'valheim', variant)
			if (existsSync(dir)) roots.add(dir)
		}
	}
	return [...roots]
}

/**
 * @param {string} dir
 * @param {string[]} files
 */
function walkFiles(dir, files = []) {
	if (!existsSync(dir)) return files
	for (const name of readdirSync(dir, { withFileTypes: true })) {
		if (name.name === 'data' || name.name === 'node_modules' || name.name.startsWith('.')) {
			continue
		}
		const full = path.join(dir, name.name)
		if (name.isDirectory()) {
			walkFiles(full, files)
			continue
		}
		if (
			name.name === 'docker-compose.yml' ||
			name.name === 'entrypoint.sh' ||
			name.name === 'docker-entrypoint.sh'
		) {
			files.push(full)
		}
	}
	return files
}

/**
 * @param {string} text
 * @returns {{ preferred: string[], fallback: string[] }}
 */
function extractAppIds(text) {
	/** @type {string[]} */
	const preferred = []
	/** @type {string[]} */
	const fallback = []

	const pushUnique = (list, id) => {
		if (!/^\d{2,10}$/.test(id) || SKIP_APP_IDS.has(id)) return
		if (!list.includes(id)) list.push(id)
	}

	for (const m of text.matchAll(/\b([A-Z0-9_]+_APP_ID)\s*[:=]\s*["']?(\d{2,10})["']?/g)) {
		if (isPreferredAppEnv(m[1])) pushUnique(preferred, m[2])
		else if (isFallbackAppEnv(m[1])) pushUnique(fallback, m[2])
	}
	for (const m of text.matchAll(/\b([A-Z0-9_]+_APP_ID)\s*=\s*"\$\{[^:]+:-(\d{2,10})\}"/g)) {
		if (isPreferredAppEnv(m[1])) pushUnique(preferred, m[2])
		else if (isFallbackAppEnv(m[1])) pushUnique(fallback, m[2])
	}
	for (const m of text.matchAll(/steam_appid\.txt["']?\s*<<.*?\n['"]?(\d{2,10})['"]?\s*\n/gs)) {
		pushUnique(preferred, m[1])
	}
	for (const m of text.matchAll(
		/printf\s+'%s\\n'\s+"(\d{2,10})"\s*>\s*"\$\{[^}]*\}\/steam_appid\.txt"/g,
	)) {
		pushUnique(preferred, m[1])
	}
	for (const m of text.matchAll(
		/printf\s+'%s\\n'\s+'(\d{2,10})'\s*>\s*"\$\{[^}]*\}\/steam_appid\.txt"/g,
	)) {
		pushUnique(preferred, m[1])
	}

	return { preferred, fallback }
}

/**
 * @param {string} slug
 * @param {{ id: string, compose: string }[]} catalog
 */
function discoverAppIds(slug, catalog) {
	/** @type {string[]} */
	const preferred = []
	/** @type {string[]} */
	const fallback = []
	const seenPref = new Set()
	const seenFall = new Set()

	for (const root of rootsForSlug(slug, catalog)) {
		for (const file of walkFiles(root)) {
			const text = readFileSync(file, 'utf8')
			const ids = extractAppIds(text)
			for (const id of ids.preferred) {
				if (seenPref.has(id)) continue
				seenPref.add(id)
				preferred.push(id)
			}
			for (const id of ids.fallback) {
				if (seenFall.has(id) || seenPref.has(id)) continue
				seenFall.add(id)
				fallback.push(id)
			}
		}
	}
	return { preferred, fallback }
}

/**
 * @param {string} url
 */
async function fetchBuffer(url) {
	const res = await fetch(url, {
		headers: { 'User-Agent': UA, Accept: '*/*' },
		redirect: 'follow',
	})
	if (!res.ok) return null
	const buf = Buffer.from(await res.arrayBuffer())
	if (buf.byteLength < 64) return null
	const type = (res.headers.get('content-type') || '').toLowerCase()
	return { buf, type, url }
}

/**
 * @param {string} appId
 */
async function fetchSteamAsset(appId) {
	for (const asset of STEAM_ASSETS) {
		const got = await fetchBuffer(`${STEAM_CDN}/${appId}/${asset}`)
		if (got) return { ...got, appId, source: `steam:${asset}` }
	}
	return null
}

/**
 * @param {string} title
 */
async function steamSearchExact(title) {
	const url = new URL('https://store.steampowered.com/api/storesearch/')
	url.searchParams.set('term', title)
	url.searchParams.set('l', 'english')
	url.searchParams.set('cc', 'US')
	const res = await fetch(url, { headers: { 'User-Agent': UA, Accept: 'application/json' } })
	if (!res.ok) return null
	/** @type {{ items?: { id: number, name: string }[] }} */
	const data = await res.json()
	const needle = title.trim().toLowerCase()
	const hit = (data.items || []).find((item) => item.name.trim().toLowerCase() === needle)
	return hit ? String(hit.id) : null
}

/**
 * @param {string} title
 */
async function wikipediaThumb(title) {
	const url = new URL(
		`https://en.wikipedia.org/api/rest_v1/page/summary/${encodeURIComponent(title)}`,
	)
	const res = await fetch(url, {
		headers: { 'User-Agent': UA, Accept: 'application/json' },
	})
	if (!res.ok) return null
	/** @type {{ thumbnail?: { source?: string }, originalimage?: { source?: string } }} */
	const data = await res.json()
	const src = data.originalimage?.source || data.thumbnail?.source
	if (!src) return null
	return fetchBuffer(src)
}

/**
 * @param {Buffer} buf
 * @param {string} type
 * @param {string} srcUrl
 */
function pickExt(buf, type, srcUrl) {
	if (type.includes('png') || srcUrl.endsWith('.png')) return 'png'
	if (type.includes('webp') || srcUrl.endsWith('.webp')) return 'webp'
	if (type.includes('gif') || srcUrl.endsWith('.gif')) return 'gif'
	if (type.includes('jpeg') || type.includes('jpg') || srcUrl.endsWith('.jpg')) return 'jpg'
	if (buf[0] === 0x89 && buf[1] === 0x50) return 'png'
	if (buf[0] === 0xff && buf[1] === 0xd8) return 'jpg'
	if (buf[0] === 0x52 && buf[1] === 0x49) return 'webp'
	return 'jpg'
}

/**
 * @returns {Promise<{ icons: Record<string, string>, report: { slug: string, status: string, detail: string }[] }>}
 */
export async function fetchGameIcons() {
	const catalog = catalogEntries()
	const repo = resolveRepo()
	mkdirSync(iconsDir, { recursive: true })
	mkdirSync(generatedDir, { recursive: true })

	const pages = readdirSync(serversDir)
		.filter((name) => name.endsWith('.md'))
		.map((name) => name.replace(/\.md$/, ''))
		.sort()

	/** @type {Record<string, string>} */
	const icons = {}
	/** @type {{ slug: string, status: string, detail: string }[]} */
	const report = []

	for (const slug of pages) {
		try {
			const mdPath = path.join(serversDir, `${slug}.md`)
			const { attrs } = parseFrontmatter(readFileSync(mdPath, 'utf8'))
			const title = attrs.title || slug
			/** @type {{ buf: Buffer, type: string, url: string, source?: string, appId?: string } | null} */
			let asset = null

			if (attrs.iconUrl) {
				const got = await fetchBuffer(attrs.iconUrl)
				if (got) asset = { ...got, source: 'frontmatter:iconUrl' }
			}

			/** @type {string[]} */
			const preferred = []
			/** @type {string[]} */
			const fallback = []
			if (attrs.steamAppId) preferred.push(attrs.steamAppId)
			const discovered = discoverAppIds(slug, catalog)
			for (const id of discovered.preferred) {
				if (!preferred.includes(id)) preferred.push(id)
			}
			for (const id of discovered.fallback) {
				if (!preferred.includes(id) && !fallback.includes(id)) fallback.push(id)
			}

			if (!asset) {
				for (const id of preferred) {
					const got = await fetchSteamAsset(id)
					if (got) {
						asset = got
						break
					}
				}
			}

			if (!asset) {
				const searchId = await steamSearchExact(title)
				if (searchId) {
					const got = await fetchSteamAsset(searchId)
					if (got) asset = got
				}
			}

			if (!asset) {
				for (const id of fallback) {
					const got = await fetchSteamAsset(id)
					if (got) {
						asset = got
						break
					}
				}
			}

			if (!asset) {
				const wikiTitle = WIKI_TITLE_ALIASES[slug] || title
				const got = await wikipediaThumb(wikiTitle)
				if (got) asset = { ...got, source: `wikipedia:${wikiTitle}` }
			}

			if (!asset && DIRECT_ICON_URLS[slug]) {
				const got = await fetchBuffer(DIRECT_ICON_URLS[slug])
				if (got) asset = { ...got, source: `direct:${slug}` }
			}

			const candidates = [...preferred, ...fallback]

			if (!asset) {
				report.push({
					slug,
					status: 'miss',
					detail: `candidates=${candidates.join(',') || '-'}`,
				})
				continue
			}

			const ext = pickExt(asset.buf, asset.type, asset.url)
			const fileName = `${slug}.${ext}`
			writeFileSync(path.join(iconsDir, fileName), asset.buf)
			icons[slug] = fileName
			report.push({
				slug,
				status: 'ok',
				detail: `${asset.source || asset.url}${asset.appId ? ` app=${asset.appId}` : ''}`,
			})
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error)
			report.push({ slug, status: 'miss', detail: `error: ${message}` })
		}
	}

	// Drop stale icons from previous builds.
	for (const name of readdirSync(iconsDir)) {
		const slug = name.replace(/\.[^.]+$/, '')
		if (!icons[slug]) rmSync(path.join(iconsDir, name), { force: true })
	}

	const body = `/** Generated by scripts/fetch-game-icons.mjs. Do not edit. */
export const gameIcons = ${JSON.stringify(icons, null, 2)}

/** Site base path used when the icons were fetched. */
export const gameIconsBase = ${JSON.stringify(repo.siteBase)}
`
	writeFileSync(path.join(generatedDir, 'game-icons.mjs'), body)
	return { icons, report }
}

const isMain =
	process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)

if (isMain) {
	const { icons, report } = await fetchGameIcons()
	const ok = report.filter((r) => r.status === 'ok').length
	const miss = report.filter((r) => r.status === 'miss')
	console.log(`game icons: ${ok}/${report.length} downloaded`)
	for (const row of report) {
		console.log(`  ${row.status === 'ok' ? 'ok' : '--'} ${row.slug}: ${row.detail}`)
	}
	if (miss.length) {
		console.warn(`game icons: ${miss.length} page(s) without an icon`)
	}
	if (Object.keys(icons).length === 0) {
		console.warn('game icons: none resolved (sidebar will omit icons)')
	}
}
