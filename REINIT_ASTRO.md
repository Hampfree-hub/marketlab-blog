# 🔄 Переинициализация Astro проекта

## 📋 План действий

### Шаг 1: Сохранить важные файлы

**Файлы которые нужно сохранить:**
- `astro.config.mjs` (уже настроен для marketlab-blog)
- `.github/workflows/deploy.yml` (GitHub Actions)
- `.gitignore` (если есть)
- `.cursorrules-blog` (правила для AI)

### Шаг 2: Удалить старые файлы

```powershell
cd "D:\Projects\HampfreeBlog"

# Удалить node_modules и dist (можно пересоздать)
Remove-Item -Recurse -Force node_modules, dist -ErrorAction SilentlyContinue

# Удалить package.json и package-lock.json (создадим заново)
Remove-Item package.json, package-lock.json -ErrorAction SilentlyContinue
```

### Шаг 3: Переинициализировать Astro

```powershell
# Инициализировать Astro в текущей директории
npm create astro@latest . -- --template blog --install --yes --typescript strict --no-git
```

**Важно:** Используем `--no-git` потому что git уже инициализирован!

### Шаг 4: Восстановить конфигурацию

После инициализации:
1. Обновить `astro.config.mjs` с правильным `base: '/marketlab-blog'`
2. Проверить что `.github/workflows/deploy.yml` на месте

### Шаг 5: Закоммитить и запушить

```powershell
git add .
git commit -m "feat: reinitialize Astro blog project"
git push origin main
git push github main
```

---

## ✅ Ожидаемый результат

После переинициализации:
- ✅ Полная структура Astro проекта
- ✅ Все файлы в git
- ✅ Правильная конфигурация для GitHub Pages
- ✅ Автодеплой работает

---

**Готовы начать?** 🚀

