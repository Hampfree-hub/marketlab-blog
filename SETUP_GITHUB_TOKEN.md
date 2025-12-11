# 🔐 Настройка GitHub токена (безопасно)

## ⚠️ ВАЖНО: Токен уже создан!

**Токен:** `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`

**НЕ КОММИТИТЬ этот файл в репозиторий!** (уже в .gitignore)

---

## 🛡️ Безопасное хранение

### Вариант 1: Git Credential Manager (рекомендуется)

Git автоматически сохранит токен в Windows Credential Manager при первом использовании.

**Команда для настройки:**
```powershell
cd "D:\Projects\HampfreeBlog"
git remote set-url github https://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@github.com/Hampfree-hub/hampfree-blog.git
```

После первого push токен сохранится в Windows Credential Manager, и URL можно будет очистить от токена.

### Вариант 2: Переменные окружения (альтернатива)

Создать файл `.env.local` (уже в .gitignore):
```
GITHUB_TOKEN=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
```

Но для git это не сработает напрямую - нужен credential helper.

---

## ✅ Рекомендуемый способ

**Используйте Git Credential Manager:**

1. Настройте remote с токеном (один раз):
   ```powershell
   git remote set-url github https://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@github.com/Hampfree-hub/hampfree-blog.git
   ```

2. Сделайте первый push:
   ```powershell
   git push github feature/astro-setup
   ```

3. Git сохранит токен в Windows Credential Manager

4. После этого можно очистить URL от токена:
   ```powershell
   git remote set-url github https://github.com/Hampfree-hub/hampfree-blog.git
   ```

5. Токен будет использоваться автоматически из Credential Manager

---

## 🔒 Где хранится токен

**Windows Credential Manager:**
- Путь: `Control Panel → Credential Manager → Windows Credentials`
- Ищите: `git:https://github.com`
- Токен хранится зашифрованным

**Безопасность:**
- ✅ Зашифровано Windows
- ✅ Доступно только вашему пользователю
- ✅ Не видно в истории команд
- ✅ Не попадает в git config

---

## 🚨 Если токен скомпрометирован

1. Перейдите на https://github.com/settings/tokens
2. Найдите токен "Hampfree Blog - Local Development"
3. Нажмите "Revoke" (отозвать)
4. Создайте новый токен
5. Обновите в Credential Manager

---

**После настройки удалите этот файл или оставьте как напоминание (но НЕ коммитьте!)**

