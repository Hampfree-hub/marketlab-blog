// @ts-check

import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
	site: 'https://hampfree-hub.github.io',
	base: '/', // Для локальной разработки используем корень
	integrations: [mdx(), sitemap()],
});
