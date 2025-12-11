# 🔄 Обновление GitHub токена

## Новый токен создан!

**Токен:** `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`

**Scopes:** `repo` + `workflow` ✅

---

## Команды для выполнения

Выполните в PowerShell:

```powershell
cd "D:\Projects\HampfreeBlog"

# Обновить remote с новым токеном
git remote set-url github https://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@github.com/Hampfree-hub/hampfree-blog.git

# Проверить
git remote -v

# Запушить код
git push github feature/astro-setup
```

---

## После успешного push

Токен сохранится в Windows Credential Manager, и можно будет очистить URL:

```powershell
# Очистить URL от токена (токен уже в Credential Manager)
git remote set-url github https://github.com/Hampfree-hub/hampfree-blog.git
```

---

**ВАЖНО:** Этот файл НЕ коммитить! (уже в .gitignore)

