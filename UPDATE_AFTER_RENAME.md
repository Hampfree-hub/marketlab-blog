# 🔄 Обновление после переименования репозитория

## ✅ Что нужно обновить

Репозиторий переименован в `marketlab-blog`. Нужно обновить:

---

## 📝 Шаг 1: Обновить remote URL

Выполните в терминале:

```powershell
cd "D:\Projects\HampfreeBlog"
git remote set-url github https://github.com/Hampfree-hub/marketlab-blog.git
git remote -v  # Проверить
```

---

## 📝 Шаг 2: Обновить astro.config.mjs

Найти файл `astro.config.mjs` и обновить:

**Было:**
```javascript
base: '/hampfree-blog',
```

**Должно быть:**
```javascript
base: '/marketlab-blog',
```

**Полный файл должен быть:**
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

## 📝 Шаг 3: Пересобрать и запушить

```powershell
# Пересобрать проект
npm run build

# Закоммитить изменения
git add astro.config.mjs
git commit -m "fix: update base path to marketlab-blog"
git push origin main
git push github main
```

---

## 🌐 Новый URL блога

После обновления блог будет доступен по адресу:

**https://hampfree-hub.github.io/marketlab-blog**

---

## ✅ Проверка

1. Откройте Actions: https://github.com/Hampfree-hub/marketlab-blog/actions
2. Должен запуститься workflow
3. Через 1-2 минуты проверить сайт

---

**Выполните команды выше!** 🚀

