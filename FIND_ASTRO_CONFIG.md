# 🔍 Как найти и обновить astro.config.mjs

## 📁 Где искать файл?

### Вариант 1: В корне проекта
```
D:\Projects\HampfreeBlog\astro.config.mjs
```

### Вариант 2: В подпапке (если есть)
```
D:\Projects\HampfreeBlog\HampfreeBlog\astro.config.mjs
```

### Вариант 3: Файл не существует (нужно создать)

Если файла нет — создадим его!

---

## 🔎 Как найти вручную

### В Cursor/VS Code:
1. Нажмите `Ctrl+P` (быстрый поиск файлов)
2. Введите: `astro.config`
3. Если найдётся — откройте

### В PowerShell:
```powershell
cd "D:\Projects\HampfreeBlog"
Get-ChildItem -Recurse -Filter "astro.config.*" | Select-Object FullName
```

---

## ✏️ Как обновить (если файл найден)

### Откройте файл и найдите строку:
```javascript
base: '/hampfree-blog',
```

### Замените на:
```javascript
base: '/marketlab-blog',
```

### Полный файл должен быть:
```javascript
// @ts-check

import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';
import { defineConfig } from 'astro/config';

export default defineConfig({
	site: 'https://hampfree-hub.github.io',
	base: '/marketlab-blog',  // ← Обновлено!
	integrations: [mdx(), sitemap()],
});
```

---

## 🆕 Если файла нет — создадим!

Если файл не найден, я создам его с правильной конфигурацией.

**Сначала попробуйте найти через Ctrl+P в Cursor!**

---

**Нашли файл? Сообщите где он находится!** 🔍

