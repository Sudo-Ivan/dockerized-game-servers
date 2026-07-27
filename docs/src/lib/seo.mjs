/**
 * Reusable SEO helpers for docs pages.
 * @param {Record<string, unknown>} data
 * @param {string} type
 */
export function buildJsonLd(type, data) {
	return JSON.stringify({
		'@context': 'https://schema.org',
		'@type': type,
		...data,
	})
}

/**
 * Escape JSON for safe embedding in a script tag.
 * @param {string} json
 */
export function escapeJsonForScript(json) {
	return json.replace(/</g, '\\u003c').replace(/>/g, '\\u003e').replace(/&/g, '\\u0026')
}

/**
 * @param {string} json
 */
export function jsonLdScript(json) {
	return `<script type="application/ld+json">${escapeJsonForScript(json)}</script>`
}

/**
 * @param {{
 *   name: string
 *   description: string
 *   url: string
 *   docsUrl: string
 *   githubUrl: string
 *   logoUrl: string
 *   authorName?: string
 * }} opts
 */
export function getWebSiteJsonLd(opts) {
	return buildJsonLd('WebSite', {
		name: opts.name,
		description: opts.description,
		url: opts.docsUrl,
		publisher: {
			'@type': 'Person',
			name: opts.authorName || 'Sudo-Ivan',
			url: opts.githubUrl.replace(/\/[^/]+$/, '') || opts.githubUrl,
		},
		inLanguage: 'en',
		license: 'https://opensource.org/licenses/0BSD',
		potentialAction: {
			'@type': 'SearchAction',
			target: {
				'@type': 'EntryPoint',
				urlTemplate: `${opts.docsUrl}?q={search_term_string}`,
			},
			'query-input': 'required name=search_term_string',
		},
	})
}

/**
 * @param {{
 *   name: string
 *   description: string
 *   docsUrl: string
 *   githubUrl: string
 *   logoUrl: string
 *   downloadUrl: string
 *   authorName?: string
 * }} opts
 */
export function getSoftwareApplicationJsonLd(opts) {
	return buildJsonLd('SoftwareApplication', {
		name: opts.name,
		description: opts.description,
		url: opts.docsUrl,
		image: opts.logoUrl,
		applicationCategory: 'DeveloperApplication',
		operatingSystem: 'Linux, Docker',
		license: 'https://opensource.org/licenses/0BSD',
		codeRepository: opts.githubUrl,
		downloadUrl: opts.downloadUrl,
		author: {
			'@type': 'Person',
			name: opts.authorName || 'Sudo-Ivan',
		},
		offers: {
			'@type': 'Offer',
			price: '0',
			priceCurrency: 'USD',
		},
	})
}

/**
 * @param {{
 *   title: string
 *   description: string
 *   url: string
 *   docsUrl: string
 *   authorName?: string
 *   dateModified?: string
 * }} opts
 */
export function getWebPageJsonLd(opts) {
	const page = {
		name: opts.title,
		description: opts.description,
		url: opts.url,
		isPartOf: {
			'@type': 'WebSite',
			name: 'Dockerized Game Servers',
			url: opts.docsUrl,
		},
		author: {
			'@type': 'Person',
			name: opts.authorName || 'Sudo-Ivan',
		},
		license: 'https://opensource.org/licenses/0BSD',
		inLanguage: 'en',
	}
	if (opts.dateModified) page.dateModified = opts.dateModified
	return buildJsonLd('WebPage', page)
}

/**
 * @param {{ name: string, url: string }[]} items
 */
export function getBreadcrumbJsonLd(items) {
	return buildJsonLd('BreadcrumbList', {
		itemListElement: items.map((item, i) => ({
			'@type': 'ListItem',
			position: i + 1,
			name: item.name,
			item: item.url,
		})),
	})
}

/**
 * Shared page meta used by Head.
 * @param {{
 *   title: string
 *   description: string
 *   canonicalUrl: string
 *   author: string
 *   siteName?: string
 *   imageUrl?: string
 *   dateModified?: string | null
 *   themeColor?: string
 * }} opts
 */
export function buildPageMeta(opts) {
	return {
		title: opts.title,
		description: opts.description,
		canonicalUrl: opts.canonicalUrl,
		author: opts.author,
		siteName: opts.siteName || 'Dockerized Game Servers',
		imageUrl: opts.imageUrl || '',
		dateModified: opts.dateModified || null,
		themeColor: opts.themeColor || '#0a0a0a',
		license: '0BSD',
		robots: 'index,follow',
	}
}
