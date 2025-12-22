# 🗺️ РЕКОМЕНДАЦИИ: Реализация интерактивной карты

**Дата:** 21.12.2025  
**Вопрос:** Как рисовать карту? Отказались от SVG-иконок, делаем всё на HTML. Будет ли удобно?

---

## 💡 КЛЮЧЕВОЕ РАЗЛИЧИЕ

**SVG-иконки ≠ SVG-карта**

Это **две разные вещи**:

1. **SVG-иконки** (от которых вы отказались):
   - Отдельные файлы `.svg` для каждой иконки
   - Используются как `<img src="icon.svg">` или `<Icon name="icon" />`
   - Вы отказались от этого подхода → используете inline SVG или эмодзи

2. **SVG-карта** (для интерактивной карты):
   - Это не иконка, а **структурная карта** (как чертёж)
   - Используется как один большой элемент с множеством фигур внутри
   - Можно делать inline SVG (прямо в HTML, не отдельный файл)
   - Это **совместимо** с вашим подходом "всё на HTML"

---

## ✅ МОЯ РЕКОМЕНДАЦИЯ: HTML/CSS Grid + Карточки

**Почему это лучше для вашего проекта:**

1. ✅ **Соответствует вашему подходу** — всё на HTML/CSS, без внешних файлов
2. ✅ **Проще реализовать** — обычные `<div>` с CSS Grid
3. ✅ **Легче поддерживать** — можно менять через CSS переменные
4. ✅ **Быстрее загружается** — нет сложного SVG-парсинга
5. ✅ **Лучше для адаптивности** — CSS Grid легко адаптируется под мобильные

---

## 🎨 КОНЦЕПЦИЯ: HTML/CSS Grid Карта

### Структура:

```html
<div class="lab-map-container">
  <!-- Заголовок карты -->
  <h2 class="lab-map-title">HAMPFREE MARKET LAB - FLOOR MAP</h2>
  
  <!-- Сетка карты -->
  <div class="lab-map-grid">
    
    <!-- ЦЕНТРАЛЬНЫЙ УЗЕЛ (открыт) -->
    <a href="/sectors/core" class="sector sector-core sector--open">
      <div class="sector-header">
        <span class="sector-icon">✓</span>
        <h3 class="sector-title">ЦЕНТРАЛЬНЫЙ УЗЕЛ</h3>
      </div>
      <p class="sector-character">Emily</p>
      <p class="sector-description">Главная</p>
      <div class="sector-status-indicator sector-status--open"></div>
    </a>
    
    <!-- СЕКТОР БЕЗОПАСНОСТИ (активен) -->
    <a href="/sectors/security" class="sector sector-security sector--active">
      <div class="sector-header">
        <span class="sector-icon">🔒</span>
        <h3 class="sector-title">СЕКТОР БЕЗОПАСНОСТИ</h3>
      </div>
      <p class="sector-character">Kai</p>
      <p class="sector-description">Риск-менеджмент</p>
      <div class="sector-status-indicator sector-status--active pulse"></div>
    </a>
    
    <!-- АРХИВ (закрыт) -->
    <div class="sector sector-vault sector--locked" title="Sector locked. Unlocks after LAB REPORT #20">
      <div class="sector-header">
        <span class="sector-icon">⚠</span>
        <h3 class="sector-title">АРХИВ ДАННЫХ</h3>
      </div>
      <p class="sector-character">Alex</p>
      <p class="sector-description">Данные</p>
      <div class="sector-status-indicator sector-status--locked"></div>
      <span class="sector-lock-label">LOCKED</span>
    </div>
    
    <!-- ... остальные сектора ... -->
    
  </div>
  
  <!-- Легенда -->
  <div class="lab-map-legend">
    <span class="legend-item">✓ = Открыто</span>
    <span class="legend-item">🔒 = Активно</span>
    <span class="legend-item">⚠ = Спит</span>
    <span class="legend-item">? = TBA</span>
  </div>
</div>
```

### CSS (в стиле проекта):

```css
.lab-map-container {
  background: var(--nes-bg-card, #1a2a1a); /* Тёмный фон */
  border: var(--nes-border-width, 2px) solid rgba(0, 255, 65, 0.3);
  border-radius: 4px;
  padding: var(--nes-spacing-lg, 24px);
  margin: var(--nes-spacing-lg, 24px) 0;
}

.lab-map-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--nes-spacing-md, 16px);
  margin: var(--nes-spacing-md, 16px) 0;
}

/* Сектор (карточка) */
.sector {
  background: var(--nes-bg-card, #1a2a1a);
  border: var(--nes-border-width, 2px) solid rgba(0, 255, 65, 0.3);
  border-radius: 4px;
  padding: var(--nes-spacing-md, 16px);
  position: relative;
  cursor: pointer;
  transition: all 0.15s ease;
  text-decoration: none;
  color: inherit;
  
  /* Beveling */
  border-top: var(--nes-border-width, 2px) solid var(--nes-bevel-light, #FFFFFF);
  border-left: var(--nes-border-width, 2px) solid var(--nes-bevel-light, #FFFFFF);
  border-bottom: var(--nes-border-width, 2px) solid var(--nes-bevel-dark, #000000);
  border-right: var(--nes-border-width, 2px) solid var(--nes-bevel-dark, #000000);
}

/* Открытый сектор */
.sector--open {
  border-color: var(--nes-neon-green, #00ff41);
}

.sector--open:hover {
  background: rgba(0, 255, 65, 0.1);
  transform: translateY(-1px);
}

/* Активный сектор (Kai) */
.sector--active {
  border-color: var(--nes-neon-cyan, #00ffff);
  animation: pulse-glow 2s ease-in-out infinite;
}

/* Закрытый сектор */
.sector--locked {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
  border-color: rgba(255, 255, 255, 0.1);
}

/* Индикатор статуса (пульсирующая точка) */
.sector-status-indicator {
  position: absolute;
  top: var(--nes-spacing-xs, 4px);
  right: var(--nes-spacing-xs, 4px);
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--nes-neon-green, #00ff41);
}

.sector-status--active {
  background: var(--nes-neon-cyan, #00ffff);
  animation: pulse 2s ease-in-out infinite;
}

.sector-status--locked {
  background: #ff4444;
}

/* Анимация пульсации */
@keyframes pulse {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.5;
    transform: scale(1.2);
  }
}

/* Тёмная тема */
html.dark-theme .sector {
  background: var(--nes-bg-card, #1a2a1a);
  border-color: rgba(0, 255, 65, 0.3);
  color: var(--nes-text-light, #e5e5e5);
}

html.dark-theme .sector--open {
  border-color: var(--nes-neon-green, #00ff41);
}

html.dark-theme .sector-title {
  color: var(--nes-neon-green, #00ff41);
}
```

---

## 🎯 АЛЬТЕРНАТИВА: Inline SVG (если всё-таки хотите SVG)

**Если вам всё-таки нужен более точный контроль (точные координаты, сложные формы), можно использовать inline SVG:**

```html
<!-- Это НЕ отдельный файл, это inline SVG прямо в HTML -->
<svg class="lab-map" width="800" height="600">
  <!-- Фон -->
  <rect width="800" height="600" fill="#0a0e27"/>
  
  <!-- ЦЕНТРАЛЬНЫЙ УЗЕЛ -->
  <g class="sector sector-core sector--open" data-sector="core">
    <rect x="100" y="100" width="200" height="150" fill="#1a3a52"/>
    <text x="200" y="160" class="sector-label">ЦЕНТРАЛЬНЫЙ УЗЕЛ</text>
  </g>
</svg>
```

**Плюсы inline SVG:**
- ✅ Нет отдельного файла (всё в HTML)
- ✅ Можно стилизовать через CSS
- ✅ Можно анимировать
- ✅ Точный контроль координат

**Минусы:**
- ❌ Сложнее поддерживать (много кода в HTML)
- ❌ Труднее адаптировать под мобильные

---

## 📊 СРАВНЕНИЕ ПОДХОДОВ

| Критерий | HTML/CSS Grid | Inline SVG |
|----------|---------------|------------|
| Соответствие подходу проекта | ✅ 100% | ⚠️ 80% (SVG в HTML, но не CSS) |
| Простота реализации | ✅ Проще | ⚠️ Сложнее |
| Поддержка | ✅ Легко | ⚠️ Труднее |
| Адаптивность | ✅ Отлично | ❌ Труднее |
| Точность координат | ⚠️ Ограничена | ✅ Полная |
| Размер кода | ✅ Компактнее | ❌ Больше |

---

## ✅ МОЯ ФИНАЛЬНАЯ РЕКОМЕНДАЦИЯ

**Используйте HTML/CSS Grid + Карточки**

**Почему:**
1. ✅ Соответствует вашему подходу "всё на HTML/CSS"
2. ✅ Проще реализовать и поддерживать
3. ✅ Легче адаптировать под мобильные
4. ✅ Можно использовать те же стили, что и для карточек статей
5. ✅ Легко менять через CSS переменные

**Это будет выглядеть как карта, но реализована через знакомые вам паттерны (карточки + Grid).**

---

## 🚀 СЛЕДУЮЩИЕ ШАГИ

1. **Создать компонент `LabMap.astro`**
   - HTML-структура с CSS Grid
   - Карточки секторов
   - Состояния (открыто/закрыто/активно)

2. **Добавить интерактивность (JavaScript)**
   - Клики по открытым секторам
   - Tooltips для закрытых секторов
   - Анимация пульсации для активных

3. **Интегрировать с навигацией**
   - Связь секторов с реальными страницами
   - Обновление карты с каждым новым LAB REPORT

4. **Адаптировать под тёмную тему**
   - Использовать неоновые цвета
   - Добавить свечение для активных секторов

---

**HTML/CSS Grid подход идеально подходит для вашего проекта!** 🎯
