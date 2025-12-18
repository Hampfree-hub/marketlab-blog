# 🎨 HTML-баннеры для статей: Исследование и возможности

## 📋 ТЕКУЩАЯ СИТУАЦИЯ

**Проблема:**
- Баннеры создаются в Figma → экспорт в PNG
- Cursor не заточен под визуальное оформление
- Нужны альтернативные решения

**Вопрос:** Можно ли создавать красивые баннеры через HTML/CSS вместо PNG?

---

## ✅ ВОЗМОЖНОСТИ HTML-БАННЕРОВ

### Преимущества:

1. **Код вместо дизайна**
   - Создаётся через HTML/CSS/JS
   - Легко версионировать в Git
   - Легко изменять через код

2. **Адаптивность**
   - Автоматически адаптируется под разные размеры
   - Responsive дизайн из коробки

3. **Динамичность**
   - Можно менять цвета, шрифты через CSS-переменные
   - Легко создавать варианты

4. **Производительность**
   - Меньше размер файлов (HTML vs PNG)
   - Можно кэшировать стили

5. **Доступность**
   - Легко добавить alt-текст
   - Семантический HTML

---

## 🎯 ВАРИАНТЫ РЕАЛИЗАЦИИ

### Вариант 1: Astro компонент для баннеров

**Структура:**
```astro
---
// src/components/ArticleBanner.astro
const { title, subtitle, category, gradient } = Astro.props;
---

<div class="article-banner">
  <div class="banner-content">
    <span class="category">{category}</span>
    <h1 class="title">{title}</h1>
    {subtitle && <p class="subtitle">{subtitle}</p>}
  </div>
</div>

<style>
  .article-banner {
    width: 100%;
    height: 400px;
    background: linear-gradient(135deg, var(--gradient-start), var(--gradient-end));
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 2rem;
    border-radius: 12px;
  }
  
  .banner-content {
    text-align: center;
    color: white;
  }
  
  .category {
    display: inline-block;
    padding: 0.5rem 1rem;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 20px;
    font-size: 0.875rem;
    text-transform: uppercase;
    letter-spacing: 1px;
  }
  
  .title {
    font-size: 3rem;
    font-weight: 700;
    margin: 1rem 0;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
  }
  
  .subtitle {
    font-size: 1.25rem;
    opacity: 0.9;
  }
</style>
```

**Использование:**
```astro
---
import ArticleBanner from '../../components/ArticleBanner.astro';
---

<ArticleBanner 
  title="Название статьи"
  subtitle="Подзаголовок"
  category="Трейдинг"
  gradient="135deg, #667eea 0%, #764ba2 100%"
/>
```

---

### Вариант 2: Генерация статических изображений

**Идея:** Использовать библиотеку для генерации изображений из HTML

**Библиотеки:**
- `puppeteer` + `html-to-image`
- `playwright` + скриншот
- `node-html-to-image`

**Пример:**
```javascript
// scripts/generate-banner.js
import { nodeHtmlToImage } from 'node-html-to-image';

const html = `
  <div style="width: 1200px; height: 630px; background: linear-gradient(135deg, #667eea, #764ba2); display: flex; align-items: center; justify-content: center; color: white; font-family: system-ui;">
    <h1 style="font-size: 48px; text-align: center;">Название статьи</h1>
  </div>
`;

await nodeHtmlToImage({
  output: './public/banners/article-1.png',
  html: html,
  type: 'png',
  quality: 100,
});
```

**Плюсы:**
- HTML-код для создания
- На выходе — PNG (как сейчас)
- Можно автоматизировать

**Минусы:**
- Нужна дополнительная зависимость
- Генерация при сборке

---

### Вариант 3: SVG-баннеры

**Идея:** Использовать SVG вместо PNG

**Преимущества:**
- Векторная графика (масштабируется)
- Можно редактировать как код
- Меньше размер файла
- Можно стилизовать через CSS

**Пример:**
```svg
<svg width="1200" height="630" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="1200" height="630" fill="url(#grad)"/>
  <text x="600" y="315" font-family="system-ui" font-size="48" fill="white" text-anchor="middle">Название статьи</text>
</svg>
```

---

## 🎨 ДИЗАЙН-СИСТЕМА ДЛЯ БАННЕРОВ

### Цветовые схемы (CSS-переменные):

```css
:root {
  --banner-gradient-trading: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --banner-gradient-crypto: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  --banner-gradient-automation: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  --banner-gradient-strategies: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}
```

### Типографика:

```css
.banner-title {
  font-family: 'Lato', system-ui, sans-serif;
  font-weight: 700;
  font-size: clamp(2rem, 5vw, 3.5rem);
  line-height: 1.2;
}

.banner-subtitle {
  font-family: 'Lato', system-ui, sans-serif;
  font-weight: 400;
  font-size: clamp(1rem, 2vw, 1.5rem);
  opacity: 0.9;
}
```

---

## 📊 СРАВНЕНИЕ ПОДХОДОВ

| Критерий | PNG (Figma) | HTML-компонент | SVG | Генерация из HTML |
|----------|------------|----------------|-----|-------------------|
| **Создание** | Figma (визуально) | Код (HTML/CSS) | Код (SVG) | Код (HTML) → PNG |
| **Размер файла** | Большой (200-500 KB) | Минимальный | Маленький (5-20 KB) | Большой (200-500 KB) |
| **Адаптивность** | Нет | Да | Да | Нет |
| **Редактирование** | Figma | Код | Код | Код |
| **Производительность** | Медленнее | Быстрее | Быстрее | Медленнее |
| **SEO** | Alt-текст | Семантика | Alt-текст | Alt-текст |
| **Версионирование** | Бинарный файл | Текстовый | Текстовый | Бинарный |

---

## 🎯 РЕКОМЕНДАЦИИ

### Для статей блога:

**Вариант A: HTML-компонент (рекомендуется)**
- ✅ Создаётся через код
- ✅ Адаптивный
- ✅ Легко изменять
- ✅ Быстрая загрузка

**Вариант B: SVG-баннеры**
- ✅ Векторная графика
- ✅ Маленький размер
- ✅ Редактируется как код
- ⚠️ Ограничения по сложности дизайна

**Вариант C: Генерация из HTML**
- ✅ HTML-код для создания
- ✅ На выходе PNG (как сейчас)
- ⚠️ Нужна дополнительная зависимость

---

## 🚀 ПЛАН ВНЕДРЕНИЯ

### Этап 1: Создать базовый компонент

```astro
// src/components/ArticleBanner.astro
---
interface Props {
  title: string;
  subtitle?: string;
  category: string;
  gradient?: string;
}

const { title, subtitle, category, gradient = '135deg, #667eea 0%, #764ba2 100%' } = Astro.props;
---

<div class="article-banner" style={`background: linear-gradient(${gradient});`}>
  <div class="banner-content">
    <span class="category">{category}</span>
    <h1 class="title">{title}</h1>
    {subtitle && <p class="subtitle">{subtitle}</p>}
  </div>
</div>

<style>
  .article-banner {
    width: 100%;
    height: 400px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 2rem;
    border-radius: 12px;
    margin-bottom: 2rem;
  }
  
  .banner-content {
    text-align: center;
    color: white;
    max-width: 800px;
  }
  
  .category {
    display: inline-block;
    padding: 0.5rem 1rem;
    background: rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    font-size: 0.875rem;
    text-transform: uppercase;
    letter-spacing: 1px;
    font-weight: 600;
  }
  
  .title {
    font-family: 'Lato', system-ui, sans-serif;
    font-size: clamp(2rem, 5vw, 3.5rem);
    font-weight: 700;
    margin: 1.5rem 0;
    text-shadow: 0 2px 20px rgba(0, 0, 0, 0.3);
    line-height: 1.2;
  }
  
  .subtitle {
    font-family: 'Lato', system-ui, sans-serif;
    font-size: clamp(1rem, 2vw, 1.5rem);
    opacity: 0.9;
    font-weight: 400;
  }
  
  @media (max-width: 768px) {
    .article-banner {
      height: 300px;
      padding: 1.5rem;
    }
  }
</style>
```

### Этап 2: Интегрировать в статьи

```markdown
---
title: "Название статьи"
pubDate: 2025-12-18
---

import ArticleBanner from '../../components/ArticleBanner.astro';

<ArticleBanner 
  title="Название статьи"
  subtitle="Подзаголовок статьи"
  category="Трейдинг"
  gradient="135deg, #667eea 0%, #764ba2 100%"
/>

Содержание статьи...
```

### Этап 3: Создать библиотеку градиентов

```typescript
// src/consts/banner-gradients.ts
export const BANNER_GRADIENTS = {
  trading: '135deg, #667eea 0%, #764ba2 100%',
  crypto: '135deg, #f093fb 0%, #f5576c 100%',
  automation: '135deg, #4facfe 0%, #00f2fe 100%',
  strategies: '135deg, #43e97b 0%, #38f9d7 100%',
} as const;
```

---

## ✅ ВЫВОД

**HTML-баннеры — это ВОЗМОЖНО и ПРАКТИЧНО!**

**Преимущества:**
- ✅ Создаётся через код (не нужен Figma)
- ✅ Адаптивный дизайн
- ✅ Легко изменять и версионировать
- ✅ Быстрая загрузка

**Рекомендация:** Начать с HTML-компонента `ArticleBanner.astro` и постепенно заменить PNG-баннеры.

---

**Статус:** Исследование завершено  
**Дата:** 18.12.2025  
**Следующий шаг:** Создать Issue в GitHub для внедрения HTML-баннеров
