// @ts-check

import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
	// Настройка для GitHub Pages
	// Репозиторий: hampfree-blog
	// URL блога: https://hampfree-hub.github.io/hampfree-blog
	site: 'https://hampfree-hub.github.io',
	base: '/hampfree-blog', // Имя репозитория на GitHub
	integrations: [mdx(), sitemap()],
});
