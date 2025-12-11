# 🚀 Настройка GitHub Pages для Hampfree Blog

## 📋 Пошаговая инструкция

### Шаг 1: Создать репозиторий на GitHub

1. Откройте https://github.com (через VPN, если нужно)
2. Нажмите **"New repository"** (зелёная кнопка)
3. Заполните форму:
   - **Repository name:** `hampfree-blog` (или любое другое имя)
   - **Description:** "Personal blog powered by Astro"
   - **Visibility:** `Public` (для бесплатного GitHub Pages)
   - **НЕ создавайте** README, .gitignore, license (у нас уже есть)
4. Нажмите **"Create repository"**

### Шаг 2: Добавить GitHub remote

После создания репозитория GitHub покажет инструкции. Выполните:

```powershell
cd "D:\Projects\HampfreeBlog"

# Добавить GitHub как второй remote (назовём его 'github')
git remote add github https://github.com/YOUR_USERNAME/hampfree-blog.git

# Проверить remotes
git remote -v
```

**Должно быть:**
```
origin   https://gitlab.com/hampfree-team-group/hampfree-blog.git (fetch)
origin   https://gitlab.com/hampfree-team-group/hampfree-blog.git (push)
github   https://github.com/YOUR_USERNAME/hampfree-blog.git (fetch)
github   https://github.com/YOUR_USERNAME/hampfree-blog.git (push)
```

### Шаг 3: Обновить astro.config.mjs

Откройте `astro.config.mjs` и замените:

```javascript
site: 'https://YOUR_USERNAME.github.io',
base: '/hampfree-blog', // Если репозиторий называется hampfree-blog
```

**На:**
```javascript
site: 'https://YOUR_USERNAME.github.io',
base: '/hampfree-blog', // Имя вашего репозитория на GitHub
```

**Важно:**
- Если репозиторий называется `YOUR_USERNAME.github.io`, то `base` не нужен (удалите строку)
- Если репозиторий называется `hampfree-blog`, то `base: '/hampfree-blog'` обязателен

### Шаг 4: Запушить код в GitHub

```powershell
# Убедитесь что вы на правильной ветке
git checkout feature/astro-setup

# Запушить в GitHub
git push github feature/astro-setup

# Создать main ветку на GitHub (если её нет)
git checkout -b main
git push github main
```

### Шаг 5: Включить GitHub Pages

1. Откройте репозиторий на GitHub
2. Перейдите в **Settings** → **Pages**
3. В разделе **"Source"** выберите:
   - **Source:** `GitHub Actions`
4. Сохраните

### Шаг 6: Проверить деплой

1. Откройте вкладку **Actions** в репозитории
2. Должен запуститься workflow **"Deploy to GitHub Pages"**
3. Через 1-2 минуты блог будет доступен по адресу:
   - `https://YOUR_USERNAME.github.io/hampfree-blog`

---

## 🔄 Синхронизация GitLab → GitHub

### Вариант A: Ручная синхронизация (простой)

После каждого коммита в GitLab:

```powershell
cd "D:\Projects\HampfreeBlog"

# Подтянуть изменения из GitLab
git pull origin feature/astro-setup

# Запушить в GitHub
git push github feature/astro-setup
```

### Вариант B: Автоматическая синхронизация (GitLab CI)

Создайте файл `.gitlab-ci.yml`:

```yaml
stages:
  - sync

sync-to-github:
  stage: sync
  image: alpine/git
  script:
    - git remote add github https://github.com/YOUR_USERNAME/hampfree-blog.git || true
    - git push github $CI_COMMIT_REF_NAME
  only:
    - main
    - feature/astro-setup
```

**Важно:** Нужно настроить GitHub Personal Access Token в GitLab CI/CD Variables.

---

## 📝 Структура remotes

```
GitLab (origin)     ← Основная разработка
     ↓
GitHub (github)     ← Зеркало для Pages
     ↓
GitHub Pages        ← Автодеплой блога
```

---

## ✅ Чек-лист

- [ ] Создан репозиторий на GitHub
- [ ] Добавлен remote `github`
- [ ] Обновлён `astro.config.mjs` с правильным `site` и `base`
- [ ] Код запушен в GitHub
- [ ] Включён GitHub Pages (Source: GitHub Actions)
- [ ] Workflow прошёл успешно
- [ ] Блог доступен по URL

---

## 🆘 Проблемы и решения

### Проблема: "Workflow не запускается"

**Решение:** Проверьте что:
- Файл `.github/workflows/deploy.yml` существует
- Код запушен в ветку `main` или `feature/astro-setup`
- GitHub Pages включён (Settings → Pages → Source: GitHub Actions)

### Проблема: "404 Not Found"

**Решение:** Проверьте `base` в `astro.config.mjs`:
- Если репозиторий `hampfree-blog` → `base: '/hampfree-blog'`
- Если репозиторий `username.github.io` → удалите `base`

### Проблема: "Authentication failed" при push

**Решение:** Используйте Personal Access Token:
```powershell
git remote set-url github https://YOUR_TOKEN@github.com/YOUR_USERNAME/hampfree-blog.git
```

---

**Готово!** 🎉

