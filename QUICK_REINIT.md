# ⚡ Быстрая переинициализация Astro

## 🚀 Команды для выполнения (по порядку)

### Шаг 1: Переинициализировать Astro

```powershell
cd "D:\Projects\HampfreeBlog"

# Инициализировать Astro в текущей директории
npm create astro@latest . -- --template blog --install --yes --typescript strict --no-git
```

**Важно:** Используем `--no-git` потому что git уже инициализирован!

**После выполнения:**
- Astro создаст структуру проекта
- Установит зависимости
- Создаст `package.json`, `src/`, `public/` и т.д.

---

### Шаг 2: Обновить astro.config.mjs

После инициализации Astro создаст свой `astro.config.mjs`. 

**Откройте файл `astro.config.mjs` и замените на:**

```javascript
// @ts-check

import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';
import { defineConfig } from 'astro/config';

export default defineConfig({
	site: 'https://hampfree-hub.github.io',
	base: '/marketlab-blog', // Имя репозитория на GitHub
	integrations: [mdx(), sitemap()],
});
```

---

### Шаг 3: Проверить сборку

```powershell
npm run build
```

Должно собраться без ошибок (может быть предупреждение про sitemap - это нормально).

---

### Шаг 4: Закоммитить и запушить

```powershell
git add .
git commit -m "feat: reinitialize Astro blog project"
git push origin main
git push github main
```

---

## ✅ После пуша

1. Проверьте Actions: https://github.com/Hampfree-hub/marketlab-blog/actions
2. Должен запуститься workflow "Deploy to GitHub Pages"
3. Через 1-2 минуты блог будет доступен: https://hampfree-hub.github.io/marketlab-blog

---

**Начните с Шага 1!** 🚀

