---
name: claude-design-prompt
description: >
  Генерирует премиум-промт для claude.ai/design по эталонной структуре (9 Aesthetic Families +
  DISTILLED_AESTHETICS_PROMPT + Design Tokens + BANNED). Основан на ресёрче Anthropic Cookbook
  и community best practices 2026. Даёт результат awwwards-уровня, не «средний AI-дизайн».
  MANDATORY TRIGGERS: промт для Claude Design, промт для claude.ai/design, сделай картинку,
  обложка через Claude Design, визуал картинкой, промт для слайд-дека.
---

# Claude Design Prompt — эталонная структура премиум-промта

**⚠️ ЭТО ОПЦИЯ, НЕ DEFAULT.** По умолчанию Дизайнер **сам делает** через claude.ai/design и отдаёт клиенту готовое. Этот скилл запускается только когда:
- клиент прямо попросил «дай промт, я сам вставлю»
- клиент хочет сделать шаг сам (часть обучения)
- нет Claude Pro у Дизайнера, промт нужен клиенту для самостоятельной работы

Если клиент просто просит «сделай обложку» — **не запускай этот скилл**, делай сам.

---

## Главный инсайт (из ресёрча Anthropic Cookbook + community)

**Без структуры Claude Design даёт один и тот же результат — кремовый фон, Fraunces, терракота.** Это фирменный стиль Anthropic, он включён по умолчанию. Единственный способ выйти из этого стиля — **жёсткая структура промта + явная Aesthetic Family + BANNED секция**.

**5 обязательных шагов:**
1. Настрой Design System ДО первого промта (URL сайта-референса → Claude Design скрапит за 15 мин)
2. Назови Aesthetic Family явно — одно из 9 с референсными брендами
3. Вставь `DISTILLED_AESTHETICS_PROMPT` из Anthropic Cookbook как preamble
4. Дай конкретные design tokens (hex, font name, spacing values)
5. Добавь BANNED с именованными anti-patterns

---

## 9 Aesthetic Families (выбери одну)

| Family | Референсы | Когда выбирать |
|--------|-----------|----------------|
| **Editorial Minimalism** | Linear, Stripe, Vercel | премиум-SaaS, тех-бренды, серьёзный B2B |
| **Terminal-Core** | Ollama, Warp | dev-tools, AI-продукты для инженеров |
| **Warm Editorial** | Claude, Notion, Substack | **ЭТО ДЕФОЛТ — ИЗБЕГАЙ БЕЗ ЦЕЛИ** (будет как у всех) |
| **Data-Dense Pro** | ClickHouse, PostHog, Linear | дашборды, аналитика, SaaS с плотными данными |
| **Cinematic Dark** | RunwayML, ElevenLabs | креативные тулы, премиум-entertainment |
| **Playful Color** | Figma, Duolingo | consumer apps, образование, coach-продукты |
| **Glass/Soft-Futurism** | Apple, Arc Browser | premium-consumer, lifestyle, hardware |
| **Neon Brutalist** | The Verge, PlayStation | media, gaming, edgy-бренды |
| **Cult/Indie** | A24, Letterboxd, Granola | нишевые creative-продукты, для «своих» |

**Важно:** Warm Editorial — дефолт Claude Design. Если не укажешь Family или укажешь эту — получишь кремово-охровый generic. Выбирай другую осознанно.

---

## Anti-slop preamble (вставляй ВСЕГДА первым блоком)

Это `DISTILLED_AESTHETICS_PROMPT` из Anthropic Cookbook — официальный код-блок, который снимает AI-слоп:

```
<frontend_aesthetics>
You tend to converge toward generic, "on distribution" outputs. In frontend design,
this creates what users call the "AI slop" aesthetic. Avoid this: make creative,
distinctive frontends that surprise and delight.

Typography: Avoid generic fonts like Arial and Inter; opt for distinctive choices.
Color & Theme: Dominant colors with sharp accents outperform timid palettes.
Motion: One well-orchestrated page load creates more delight than scattered micro-interactions.
Backgrounds: Create atmosphere and depth rather than defaulting to solid colors.

BANNED: Inter, Roboto, Arial — purple gradients on white — predictable layouts.
Think outside the box. It is critical.
</frontend_aesthetics>
```

Вставляй этот блок в **самое начало** любого промта.

---

## Структура эталонного промта (шаблон-план)

```
[1. ANTI-SLOP PREAMBLE] — официальный фрагмент Anthropic (блок выше)

[2. AESTHETIC FAMILY + REFERENCES]
"Aesthetic: [Family name] — feel of [reference brand 1], [reference brand 2]"

[3. DESIGN TOKENS] — hex, font, radius, spacing
"Color tokens: bg #0A0A0A, surface #14141A, accent-primary #00F5D4, accent-hot #FF2E93, text-high #E8E8E8, text-muted #8A8A8A.
Typography: display Unbounded Black 120-180pt, body Söhne 24-32pt. Radius: 4px (sharp, brutalist). Spacing: 64px sections, 24px within."

[4. TYPOGRAPHY RULES] — weights, size hierarchy
"Headlines 180pt weight 900, subtitles 32pt weight 400 — weight gap 3x+ для контраста."

[5. COLOR & THEME] — доминирующий цвет + 1 острый акцент (правило Anthropic)
"Dominant: graphite #0A0A0A (70% of canvas). Accent: electric cyan #00F5D4 (6% max, only on focal point). No timid palettes — one bold color, one sharp accent."

[6. LAYOUT & COMPOSITION] — сетка, плотность, иерархия
"Asymmetric composition. Rule of thirds. Off-center focal. Massive negative space (60%+). No centered-everything."

[7. CONTENT SPEC] — что на каждом экране/слайде/элементе
Детально по каждому слайду или секции. Конкретно что где.

[8. MOTION] — анимации с таймингом
"Staggered text entry 60-80ms per letter. Page transition 400ms cubic-bezier(0.2, 0, 0, 1). Scroll-reveal on sections, 200ms delay."

[9. TWEAKS REQUEST] — какие слайдеры Claude Design должен подготовить
"Make these values tweakable: accent color, border-radius (0-20px), font weight (400-900)."

[10. BANNED] — именованные anti-patterns
"BANNED:
- Inter / Roboto / Space Grotesk / Arial / Helvetica as display fonts
- Purple gradients, blue tech holograms, glowing brains, circuit boards
- Stock photo people, smiling diverse teams
- Emoji in headlines
- 3-column feature grids with emoji icons
- Centered-everything layouts
- 'Innovative / cutting-edge / seamless / revolutionary' wording
- Pastel corporate palettes
- Container soup (nested divs without purpose)
- Blinking status dots"

[11. FORMAT & EXPORT]
"Export: high-res PDF + PPTX + standalone HTML. Aspect ratio 16:9. Breakpoints: desktop 1920px, tablet 768px, mobile 375px."
```

---

## Вход (что ты подтягиваешь перед написанием)

- **Brand Book клиента** — `knowledge/brand/{project}/brand-book.md`. Если файла нет — **остановись** и запусти `brand-onboarding`.
- **Тип дизайна** — из `knowledge/design-catalog.md`
- **Aesthetic Family** — определи сам из контекста клиента или спроси
- **Специфика запроса** — что именно делаем

---

## Шаги написания промта

### 1. Прочитай Brand Book
Вытащи: hex-коды, точные названия шрифтов, настроение, запреты, do/don't.

### 2. Определи Aesthetic Family
Из таблицы 9 штук. Учти нишу клиента:
- Онлайн-курс / эксперт → **Editorial Minimalism** или **Cult/Indie**
- AI-продукт → **Terminal-Core** или **Cinematic Dark**
- Consumer-app → **Playful Color** или **Glass/Soft-Futurism**
- B2B SaaS → **Editorial Minimalism** или **Data-Dense Pro**

**НЕ Warm Editorial**, если клиент специально не хочет «как у Claude/Notion».

### 3. Определи режим Claude Design
- **Prototype** (UI/UX, артефакты) — 2 подрежима: Wireframe (экономит токены) → High-fidelity
- **Slide deck** (HTML-презентации) — 1-indexed слайды ("01 Title"), speaker notes через JSON script
- **From Template** (лендинги, one-pager, инфографика)

### 4. Собери design tokens
- Palette: 4–6 hex из Brand Book + правило «dominant + 1 sharp accent»
- Typography: display font + body font + weights (с разрывом 3x+)
- Spacing: 8px grid (8/16/24/32/48/64/96/128)
- Radius: 0px (brutalist) / 4px (sharp) / 8px (friendly) / 16px+ (playful)

### 5. Напиши промт по 11-секционной структуре
Каждая секция обязательна, кроме Tweaks (если не нужны слайдеры).

### 6. BANNED — минимум 6 конкретных запретов
Обязательно включи:
- Inter / Roboto / Space Grotesk / Arial as display (slop-триггеры!)
- Purple gradient на белом
- Stock people
- Emoji в headlines
- Centered-everything
- "Innovative / cutting-edge" wording

Плюс специфичные для ниши клиента из Brand Book.

### 7. Объясни куда копировать

> «Открой claude.ai/design → выбери режим [Prototype / Slide deck / From Template] → вставь промт → подожди 30-60 секунд. Не зашло — крути Tweaks (ползунки справа) или скажи в чате 'сделай ярче / другой акцент'. Через Comment ('кликнул на элемент, написал правку') правки точные, не через общий чат.»

---

## Технические фишки Claude Design (используй в промте явно)

### Tweaks
Заказывай ползунки в промте: *«Make tweakable: accent color (hex), border-radius (0-20px), font size (14-20px), stagger duration (40-120ms)»*. Ползунки **не потребляют токены** — live-редактирование без регенерации.

### Design System
Если у клиента есть сайт — укажи в промте: *«Design System: match styling of https://example.com (colors, typography, spacing)»*. Claude скрапит за 15 мин при настройке DS.

### Comment vs Chat
В промте можно написать: *«Elements that will likely need inline editing (labels, CTAs, prices) — make them individually selectable for Comment mode»*. Comment точнее чем правки через общий чат.

### Экспорт
Всегда указывай в секции FORMAT: PDF + PPTX + HTML. Без этого выдаст только preview.

---

## BANNED шрифты (slop-триггеры — никогда как display)

Из community-анализа 2026 — эти шрифты дают мгновенный «средний AI-результат»:
- Inter
- Roboto
- Open Sans
- Lato
- Arial / Helvetica
- Space Grotesk (перегружен по всем AI-генерациям)

**Вместо них используй distinctive:** Unbounded, Fraunces, Cabinet Grotesk, IBM Plex, Satoshi, JetBrains Mono, PP Neue Machina, Geologica, Söhne, Instrument Serif.

---

## 5 готовых эталонных промтов (копируй-используй)

### A. Premium Pitch Deck (Data-Dense Pro)

```
<frontend_aesthetics>[официальный блок выше]</frontend_aesthetics>

Create a 10-slide Slide Deck in Data-Dense Pro aesthetic — feel of PostHog, ClickHouse, Linear.

Design tokens:
- Background: deep graphite #0A0A0A
- Surface: #14141A (subtle depth)
- Accent primary: electric lime #D4FF00 (one bold accent, max 8% of canvas)
- Accent danger: #FF3B47 (only for negative metrics)
- Text high: #E8E8E8
- Text muted: #7A7A82
- Font display: IBM Plex Sans, weights 700–900, 120pt
- Font body: IBM Plex Mono, weight 400, 24pt
- Spacing: 64px, 8px grid
- Radius: 4px (sharp)

Composition: asymmetric, off-center focal, rule of thirds. Heavy negative space (60%+ per slide). Data visualisations are first-class citizens — not decorative.

[Per-slide content: …]

Motion: staggered text 60-80ms, slide transitions 400ms cubic-bezier(0.2, 0, 0, 1).

Make tweakable: accent color, stagger duration.

BANNED: Inter, Roboto, Space Grotesk as display. Purple gradients. Stock people. Centered everything. 3-column feature grids with emoji. "Innovative/cutting-edge" wording. Blinking status dots. Container soup.

Export: PDF + PPTX + HTML. 16:9.
```

### B. Awwwards-уровня лендинг (Editorial Minimalism)

```
<frontend_aesthetics>[официальный блок]</frontend_aesthetics>

Create a landing page in Editorial Minimalism aesthetic — feel of Linear, Stripe, Vercel.

Design tokens:
- Background: warm off-white #FAFAF7
- Surface: #F0EFE8 (paper layer)
- Ink: #0D0D0A (deep black, not pure)
- Accent: forest emerald #1B5E3F (one bold accent, max 6%)
- Font display: Fraunces, weights 300-700, sizes 96-180pt
- Font body: Cabinet Grotesk, weights 400-600, 20-24pt
- Spacing: 96px sections, 12-column grid
- Radius: 0px (editorial, not rounded)

Composition: editorial layout, print-first feel. Massive type hierarchy (h1 180pt / h2 64pt / body 20pt — weight and size gap 3x+). Scroll-as-story. Heavy top-hero with slow reveal.

[Section content: …]

Motion: scroll-driven opacity reveals, text entrance 80ms stagger per word. Subtle parallax on images (translate 0.3x scroll speed).

Design System: match typographic rhythm of https://linear.app.

BANNED: Inter, Space Grotesk, Roboto. Centered hero with gradient. 3-column benefits grid. Stock photos. Emoji icons. "Cutting-edge" copy.

Export: standalone HTML + Figma export.
```

### C. Editorial инфографика (Warm Editorial — осознанно)

```
<frontend_aesthetics>[блок]</frontend_aesthetics>

Create an editorial infographic in Warm Editorial aesthetic — NYT/New Yorker feel, printed warmth.

Design tokens:
- Background: aged paper #F4EFE2 (with subtle noise texture)
- Ink: #1C1812
- Accent warm: terracotta #C66B3C
- Accent cool: petrol #2B4A55
- Font display: Fraunces Italic, 72-120pt
- Font body: Instrument Serif, 18pt

Composition: magazine-style, multi-column, clear reading flow. Subhead "decks" under headlines.

[Content spec: …]

BANNED: sans-serif display. Neon colors. Modern flat icons — use editorial illustration style instead. Stock infographic clipart.

Export: PDF at 300dpi, 16:9 and vertical 9:16 versions.
```

### D. SaaS Dashboard (Data-Dense Pro)

```
<frontend_aesthetics>[блок]</frontend_aesthetics>

Create a SaaS dashboard in Data-Dense Pro aesthetic — feel of PostHog, ClickHouse.

Design tokens: [токены]

Layout: 12-column grid. Left sidebar 240px (collapsible to 64px). Main canvas with 24px gutters. Density: show 3x more data per viewport than "friendly" dashboards — this is pro.

[Content per screen: Overview, Users, Revenue, Alerts]

Motion: zero micro-animations on data (jumpy feels broken). Only hover-states and page transitions.

Make tweakable: density (compact/cozy/comfy), accent color.

BANNED: big centered "Welcome back" modules. Cards with 80% whitespace. Emoji in metric names. Stock avatars in testimonials (no testimonials on dashboards at all).

Export: HTML + Figma.
```

### E. Mobile UI Prototype (Glass/Soft-Futurism)

```
<frontend_aesthetics>[блок]</frontend_aesthetics>

Create a mobile UI prototype in Glass/Soft-Futurism aesthetic — feel of Apple, Arc Browser.

Design tokens:
- Background: gradient from #0B1426 to #1B2A4E
- Glass layer: rgba(255,255,255,0.08) with backdrop-blur 24px
- Accent: iridescent teal #7FDBFF
- Text: #F2F4F8, muted #8993A8
- Font: Satoshi, weights 300-700
- Spacing: 16pt grid (iOS-style)
- Radius: 28px (soft)

Composition: single focal element per screen. Use depth through layering (3-4 z-layers visible).

[Screen specs: Home, Detail, Settings, Empty state]

Motion: spring physics, iOS-like. Page transitions 350ms with ease-out. Staggered list entry 50ms.

Make tweakable: blur intensity, accent hue.

BANNED: Material Design cards. Android back-button layouts. Neon without blur. Skeuomorphic shadows.

Export: iPhone 15 Pro frame, PDF + Figma.
```

---

## Self-check перед отдачей промта

- [ ] `DISTILLED_AESTHETICS_PROMPT` блок стоит **первым**
- [ ] Aesthetic Family названа явно (одна из 9) + 2+ reference brands
- [ ] Design tokens конкретны: hex, font name, font weights, spacing, radius
- [ ] Typography с разрывом 3x+ между display и body
- [ ] Color — «доминирующий + один острый акцент», не «5 равных цветов»
- [ ] Composition: не «centered everything», есть асимметрия / heavy negative space
- [ ] Если есть анимации — конкретные ms + cubic-bezier (не «smooth»)
- [ ] Tweaks заказаны (3-5 ползунков)
- [ ] BANNED: минимум 6 именованных паттернов, включая Inter/Roboto/Space Grotesk
- [ ] Export: PDF + PPTX + HTML указаны
- [ ] Режим (Prototype / Slide deck / From Template) объявлен явно
- [ ] Нет в промте AI-слопа (innovative, cutting-edge, synergy, revolutionary)
- [ ] Длина 300-800 строк — промты короче 200 строк дают средний результат

## Выход

1. **Промт** в блоке кода (готов к копированию)
2. **Инструкция:** куда копировать + какой режим выбрать + куда нажимать (Tweaks / Comment)
3. **2-3 подсказки для итераций:** примеры фраз на случай если не зашло
