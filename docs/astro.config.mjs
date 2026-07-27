// @ts-check
import { defineConfig } from 'astro/config'
import starlight from '@astrojs/starlight'
import { remarkRepoTokens, resolveRepo } from './src/lib/repo.mjs'

const repo = resolveRepo()
const tokens = {
	'{{IMAGE_PREFIX}}': repo.imagePrefix,
	'{{GITHUB_URL}}': repo.githubUrl,
	'{{DOCS_URL}}': repo.docsUrl,
	'{{REPO}}': repo.repo,
	'{{IMAGE_OWNER}}': repo.imageOwner,
}

// https://astro.build/config
export default defineConfig({
	site: repo.siteUrl,
	base: repo.siteBase,
	markdown: {
		remarkPlugins: [remarkRepoTokens(tokens)],
	},
	integrations: [
		starlight({
			title: 'Dockerized Game Servers',
			description:
				'Dockerized dedicated game servers with small images and compose files.',
			pagefind: false,
			lastUpdated: true,
			editLink: {
				baseUrl: `${repo.githubUrl}/edit/master/docs/`,
			},
			customCss: ['./src/styles/theme.css', './src/styles/no-js.css'],
			components: {
				ThemeProvider: './src/components/ThemeProvider.astro',
				ThemeSelect: './src/components/Empty.astro',
				TableOfContents: './src/components/TableOfContents.astro',
				MobileTableOfContents: './src/components/MobileTableOfContents.astro',
				Search: './src/components/Search.astro',
				Head: './src/components/Head.astro',
				Header: './src/components/Header.astro',
				Sidebar: './src/components/Sidebar.astro',
				PageTitle: './src/components/PageTitle.astro',
				Footer: './src/components/Footer.astro',
				Hero: './src/components/Hero.astro',
			},
			social: [
				{
					icon: 'github',
					label: 'GitHub',
					href: repo.githubUrl,
				},
			],
			sidebar: [
				{
					label: 'Start',
					items: [
						{ label: 'Overview', slug: '' },
						{ label: 'Quick start', slug: 'guides/quick-start' },
						{ label: 'Ops', slug: 'guides/ops' },
					],
				},
				{
					label: 'Servers',
					items: [{ autogenerate: { directory: 'servers' } }],
				},
				{
					label: 'Reference',
					items: [{ autogenerate: { directory: 'reference' } }],
				},
			],
		}),
	],
})
