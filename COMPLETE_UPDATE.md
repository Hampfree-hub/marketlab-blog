# ✅ Полная инструкция по обновлению после переименования

## 🎯 Что нужно сделать

Репозиторий переименован в `marketlab-blog`. Выполните команды по порядку:

---

## 📝 Шаг 1: Обновить remote URL

```powershell
cd "D:\Projects\HampfreeBlog"
git remote set-url github https://github.com/Hampfree-hub/marketlab-blog.git
git remote -v  # Проверить что обновилось
```

**Ожидаемый результат:**
```
github  https://github.com/Hampfree-hub/marketlab-blog.git (fetch)
github  https://github.com/Hampfree-hub/marketlab-blog.git (push)
```

---

## 📝 Шаг 2: Файл astro.config.mjs

**Я уже создал файл `astro.config.mjs` с правильной конфигурацией!**

Проверьте что файл содержит:
```javascript
base: '/marketlab-blog',
```

---

## 📝 Шаг 3: Пересобрать и запушить

```powershell
# Пересобрать проект
npm run build

# Закоммитить изменения
git add astro.config.mjs
git commit -m "fix: update base path to marketlab-blog"
git push origin main  # GitLab
git push github main  # GitHub → автодеплой!
```

---

## 🌐 Новый URL блога

После деплоя блог будет доступен по адресу:

**https://hampfree-hub.github.io/marketlab-blog**

---

## ✅ Проверка

1. Откройте Actions: https://github.com/Hampfree-hub/marketlab-blog/actions
2. Должен запуститься workflow "Deploy to GitHub Pages"
3. Через 1-2 минуты проверить сайт

---

**Выполните команды по порядку!** 🚀

