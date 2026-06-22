---
title: "Дизайн-библиотеки (MCP-серверы) — твой опциональный арсенал"
updated: 2026-05-13
owner: Designer
---

# Дизайн-библиотеки (MCP-серверы)

## Что это

Опциональный слой инструментов. Если у пользователя подключены MCP-серверы — у тебя есть прямой доступ к каталогам 400+ готовых React-компонентов (анимированные кнопки, hero-фоны, карточки, отзывы, навигация). Не надо писать руками то, что уже сделано.

**Как узнать что подключено:** в первом контакте с пользователем посмотри, есть ли у тебя в инструментах `mcp__magic-ui__*`, `mcp__reactbits__*`, `mcp__aceternity-ui__*`, `mcp__21st-magic__*`. Если их нет — предложи подключить (см. секцию «Если MCP не подключены»).

## Правило приоритета (когда MCP подключены)

**MCP First.** Перед написанием руками — сначала ищи готовое в библиотеках в этом порядке:

```
Magic UI → ReactBits → Aceternity UI → 21st.dev Magic → пиши сам
```

Magic UI — самый большой каталог стандартных секций. ReactBits — сильные WebGL-фоны. Aceternity — premium-эффекты. 21st Magic — генерация по описанию когда ничего из каталогов не подошло.

---

## 1. Magic UI (`mcp__magic-ui__*`)

**Что:** 150+ анимированных компонентов для лендингов. Первый выбор для стандартных секций.

**Ключевые компоненты:**

| Компонент | Когда использовать |
|-----------|-------------------|
| `marquee` | Лого-карусель клиентов, бесконечный скролл |
| `bento-grid` | Раскладка фич (стандарт SaaS лендингов) |
| `animated-beam` | Визуализация связей, интеграций, потоков |
| `blur-fade` | Мягкое появление текста и блоков |
| `border-beam` | Подсветка границ карточек (premium feel) |
| `animated-grid-pattern` | Фон hero-секции |
| `shimmer-button` | CTA-кнопка с shimmer-эффектом |
| `animated-testimonials` | Отзывы с анимацией |
| `dock` | macOS-стиль dock для навигации |
| `number-ticker` | Анимация цифр (статистика, метрики) |
| `word-rotate` / `typing-animation` | Динамический текст в заголовках |
| `globe` | 3D глобус (для «глобальный охват») |
| `particles` | Фон с частицами |
| `ripple` | Ripple-эффект на кнопках и карточках |
| `meteors` | Декоративный эффект для hero |
| `magic-card` | Карточка с gradient border, следующим за мышью |
| `spotlight` | Spotlight-эффект на наведение |

**Как искать:**
```
mcp__magic-ui__searchRegistryItems({ query: "marquee" })
```

**Как получить код:**
```
mcp__magic-ui__getRegistryItem({ name: "marquee" })
```

**Как ставить локально (если работаешь в Next.js проекте):**
```bash
npx shadcn@latest add "https://magicui.design/r/marquee"
```

---

## 2. ReactBits (`mcp__reactbits__*`)

**Что:** 135+ компонентов. Сила — WebGL-фоны.

**Фоновые эффекты (главное за чем сюда идёшь):**

| Background | Эффект | Когда |
|-----------|--------|-------|
| `Threads` | Анимированные нити | Hero на тёмном фоне |
| `Waves` | Волнообразный WebGL | Секция о продукте |
| `Noise` | Зернистость | Premium feel |
| `Aurora` | Северное сияние | Светлый ледяной стиль |
| `Squares` | Геометрическая сетка | Техничный раздел |
| `Lightning` | Молнии | Энергичная секция |
| `Particles` | Частицы | Фоновое оформление |
| `Ribbons` | Ленты | Декоративный фон |

**Другие сильные компоненты:**
- `BlobCursor` — кастомный курсор-блоб
- `SplashCursor` — splash при клике
- `SplitText` — посимвольная анимация текста
- `TextPressure` — давление на текст при наведении
- `PixelTransition` — переход между изображениями

**Как искать:**
```
mcp__reactbits__search_components({ query: "background" })
```

---

## 3. Aceternity UI (`mcp__aceternity-ui__*`)

**Что:** 200+ premium-компонентов. 3D, параллакс, свечения, spotlight.

**Топ-компоненты:**

| Компонент | Когда |
|-----------|-------|
| `spotlight` | Hero с spotlight, следящим за мышью |
| `3d-card-effect` | Карточки с 3D-наклоном |
| `background-beams` | Лучи на фоне hero |
| `background-gradient` | Анимированный градиент |
| `hero-parallax` | Параллакс-hero с продуктами |
| `infinite-moving-cards` | Карусель отзывов и логотипов |
| `lamp` | «Лампа» — свечение сверху |
| `text-generate-effect` | Генеративное появление текста |
| `typewriter-effect` | Печатающий текст |
| `wavy-background` | Волнистый анимированный фон |
| `moving-border` | Движущаяся граница на кнопке |
| `tracing-beam` | Линия, следующая за скроллом |
| `hover-border-gradient` | Градиент при наведении |
| `floating-navbar` | Парящая навигация при скролле |
| `tabs` | Анимированные табы |

**Лучшие связки:**
- `spotlight` + `background-beams` = wow-hero
- `3d-card-effect` + `hover-border-gradient` = premium-карточки
- `hero-parallax` + `tracing-beam` = storytelling-лендинг

**Как искать:**
```
mcp__aceternity-ui__search_components({ query: "spotlight" })
```

---

## 4. 21st.dev Magic (`mcp__21st-magic__*`)

**Что:** «v0 в твоём IDE» — генерация UI-компонентов из текстового описания.

**Когда использовать:**
- Быстрый прототип секции по описанию словами
- Нестандартный компонент, которого нет в библиотеках
- Нужен каркас — допилишь руками под Brand Book

**Как вызывать:**
```
mcp__21st-magic__21st_magic_component_builder({
  prompt: "A hero section with gradient background, large heading, subtext, and two CTA buttons"
})
```

**Хорошие промты:**
```
"A pricing section with 3 tiers, popular badge on middle card, toggle for monthly/yearly"
"A testimonial carousel with avatar, quote, name, role, and company logo"
"A feature grid 2x3 with icons, titles, descriptions, hover effect"
"A footer with 4 columns: logo+description, Product links, Company links, Social icons"
"A navbar with logo left, 4 links center, CTA button right, mobile hamburger"
```

**Ограничения:**
- Генерирует JSX + Tailwind — нужно адаптировать под стек проекта
- Не знает про Brand Book — обязательно переставь цвета и шрифты после генерации
- Результат = стартовая точка, не финал

---

## Матрица: какой MCP для чего

| Задача | Первый выбор | Второй выбор |
|--------|-------------|--------------|
| Hero-секция | Aceternity (`spotlight`, `beams`) | Magic UI (`grid-pattern`) |
| Фоновый эффект | ReactBits (WebGL backgrounds) | Aceternity (`wavy-background`) |
| Бегущая строка | Magic UI (`marquee`) | — |
| Карточки фич | Magic UI (`bento-grid`) | Aceternity (`3d-card`) |
| Отзывы | Magic UI (`animated-testimonials`) | Aceternity (`infinite-moving-cards`) |
| CTA-кнопка | Magic UI (`shimmer-button`) | Aceternity (`moving-border`) |
| Анимация текста | ReactBits (`SplitText`) | Aceternity (`text-generate-effect`) |
| Статистика/цифры | Magic UI (`number-ticker`) | — |
| Навигация | Magic UI (`dock`) | Aceternity (`floating-navbar`) |
| Нестандартное | 21st.dev Magic (генерация) | Пиши сам |

---

## Адаптация компонента под Brand Book

**После того как взял готовый компонент:**

1. Прочитай `knowledge/brand/{project}/brand-book.md` пользователя.
2. Замени все hex-коды на палитру Brand Book.
3. Замени шрифты на те что в Brand Book.
4. Радиусы скругления — из Brand Book (если там pill — все кнопки `rounded-full`; если 8px — `rounded-lg`).
5. Тени — из Brand Book (если glass — `bg-white/45 backdrop-blur-[32px]`).

**Никогда не отдавай компонент с дефолтной палитрой библиотеки.** Brand Book — закон, MCP — кирпичи.

---

## Если MCP не подключены

При первом контакте с пользователем — проверь свои доступные инструменты. Если `mcp__magic-ui__*` и других нет:

**Скажи живым языком, одной фразой:**
> «Кстати — у меня есть 4 опциональные библиотеки на 400+ готовых компонентов: Magic UI, ReactBits, Aceternity, 21st.dev Magic. С ними лендинги получаются жирнее и быстрее. Сейчас они не подключены. Если хочешь — дам инструкцию как подключить за 5 минут. Без них тоже работаю, но дизайн будет проще.»

Если пользователь сказал «давай подключим» — дай ему инструкцию из `knowledge/mcp-setup.md` (если есть) или сошлись на `.mcp.json.example` в корне офиса.

**Если пользователь отказался** — работаешь без MCP, через Claude Code артефакт + чистый Tailwind/shadcn. Brand Book + насмотренность + ручная работа. Это тоже хороший путь, просто медленнее.
