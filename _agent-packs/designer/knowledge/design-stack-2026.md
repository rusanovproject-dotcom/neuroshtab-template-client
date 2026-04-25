---
title: "Design Stack Topology 2026 — для Designer-агента"
date: 2026-04-21
status: final
agent: intelligence
tags: [design, components, animation, branding, AI-tools, prompting, trends]
summary: "Полная карта инструментов, библиотек, паттернов и стеков для современного веб-дизайна 2026. Для Designer-агента в AI-офисе учеников: от компонентных библиотек до промт-паттернов и источников вдохновения."
sources:
  - https://ui.aceternity.com/guides/best-react-ui-components-2026
  - https://www.untitledui.com/blog/react-component-libraries
  - https://magicui.design/
  - https://reactbits.dev
  - https://21st.dev/home
  - https://line25.com/articles/web-design-trends-2026/
  - https://www.saasframe.io/blog/10-saas-landing-page-trends-for-2026-with-real-examples
  - https://muz.li/blog/vibe-design-in-2026-what-ai-generated-ui-means-for-your-work/
  - https://www.nxcode.io/resources/news/vibe-design-tools-compared-stitch-v0-lovable-2026
  - https://platform.claude.com/cookbook/coding-prompting-for-frontend-aesthetics
  - https://aiia.ro/blog/how-to-build-landing-page-claude-code/
  - https://blog.logrocket.com/best-react-animation-libraries/
  - https://www.rivemasterclass.com/blog/rive-vs-lottie
  - https://developer.chrome.com/blog/view-transitions-in-2025
  - https://www.relume.io/
  - https://www.framer.com/compare/framer-vs-webflow
  - https://www.awwwards.com/annual-awards-2025/
  - https://godly.website/
  - https://github.com/VoltAgent/awesome-design-md/blob/main/README.md
  - https://tympanus.net/codrops/
  - https://tremor.so/
  - https://www.metabrand.digital/learn/tech-website-design-best-examples
---

# Design Stack Topology 2026

> Рабочий справочник Designer-агента. Не теория — конкретные инструменты, когда что брать, примеры живых сайтов, готовые промты.

---

## 1. TL;DR — топ-5 стеков которые должен знать каждый Designer в 2026

| # | Стек | Для чего | Когда брать |
|---|------|----------|-------------|
| 1 | **shadcn/ui + Tailwind v4 + Motion** | SaaS дашборды, кастомные UI | Всегда как base layer |
| 2 | **Aceternity UI + Framer Motion / GSAP** | Landing pages с wow-эффектом | Когда нужны анимации из коробки |
| 3 | **Framer (no-code)** | Быстрый лендинг за 1 день | Старт без кода, пользовательские сайты |
| 4 | **React Three Fiber + GSAP ScrollTrigger** | Иммерсивные hero-секции, 3D storytelling | Awwwards-уровень |
| 5 | **Tremor + shadcn/ui** | Аналитика, данные, SaaS-дашборды | Где главное — данные, не визуал |

Ключевой принцип 2026: **Tailwind v4 как фундамент** (CSS-first, без конфига, 5x быстрее), shadcn/ui как скелет, анимационный слой сверху.

---

## 2. Компонентные библиотеки

### Сводная таблица

| Библиотека | GitHub Stars | Цена | Best For | Стек |
|------------|-------------|------|----------|------|
| shadcn/ui | 80k+ | Free | Кастомные design systems | Radix + Tailwind |
| Magic UI | 18k+ | Free (Pro $) | Анимированные лендинги | React + Tailwind + Motion |
| Aceternity UI | 25k+ | Free / $199 Pro | WOW-лендинги, hero-секции | Tailwind + Framer Motion |
| ReactBits | 8k+ | Free | Фоны, text-анимации, декор | React + CSS |
| Skiper UI | 3k+ | Free + Premium | Scroll-effects, micro-interactions | shadcn + Radix + Tailwind |
| 21st.dev | платформа | Free | Дискавери компонентов + AI | — |
| Tremor | 16k+ | Free | Дашборды, чарты | Tailwind |
| NextUI | 22k+ | Free | Визуально красивые апп | Tailwind Variants |
| Mantine | 30k+ | Free | Полный комплект + 100 хуков | CSS Modules |
| Radix UI | 16k+ | Free | Unstyled primitives | — |
| Untitled UI React | — | Free / $349+ | Максимальный выбор (5000+ компонентов) | Tailwind + React Aria |
| Tailwind Plus | — | $299+ | Профессиональные блоки | Tailwind |
| Base UI | — | Free | Unstyled, Radix-next | — |

### Детальные карточки топ-10

---

#### shadcn/ui
**Что:** Copy-paste компоненты на Radix UI + Tailwind. Ты копируешь код в свой проект — нет зависимости от пакета.
**Сильные стороны:** Полный контроль над кодом, идеально кастомизируется, CLI-установка покомпонентно. De facto стандарт 2026 для новых SaaS.
**Когда брать:** Любой серьёзный проект как базовый слой. Все остальные библиотеки строятся поверх него.
**Живые примеры:** Vercel v0-генерация по умолчанию, Linear-клоны, большинство YC-стартапов.
**URL:** https://ui.shadcn.com

---

#### Magic UI
**Что:** 150+ бесплатных анимированных компонентов + эффектов. Позиционируется как "идеальный компаньон для shadcn/ui".
**Сильные стороны:** Готовые orbit-анимации, shimmer-эффекты, border-beam, text-reveal, animated-list — всё что выглядит "дорого" но делается в 2 строки.
**Когда брать:** Marketing sites, landing pages стартапов. YC-funded продукты часто используют именно Magic UI для hero-секций.
**Живые примеры:** Множество Y Combinator стартапов 2024–2025.
**URL:** https://magicui.design — основной бесплатно; Magic UI Pro ($) — 50+ готовых секций.

---

#### Aceternity UI
**Что:** 330+ компонентов с акцентом на Framer Motion + Tailwind. Сильный фокус на "modern and futuristic aesthetic".
**Сильные стороны:** Лучший выбор для landing pages с wow-эффектом из коробки: Spotlight cards, 3D card-hover, background-beams, infinite moving cards, text-generate-effect.
**Когда брать:** Когда пользователь хочет "как у крутого стартапа". SaaS, AI-продукты, креативные агентства.
**Особенность:** Premium ($199) даёт шаблоны целых страниц — не компоненты, а полные секции.
**URL:** https://ui.aceternity.com

---

#### ReactBits
**Что:** 110+ анимированных компонентов в 4 категориях: text animations, backgrounds, transitions, UI-декор.
**Сильные стороны:** Лучшие animated backgrounds (Ballpit, Pixel-Trail, Aurora, Silk) и text-эффекты (Blurry Text, Wave Text, Shiny Text). Всё бесплатно, open source.
**Когда брать:** Когда нужен уникальный фоновый эффект или hero с живым текстом. Хорошо сочетается с shadcn/ui.
**URL:** https://reactbits.dev

---

#### Skiper UI
**Что:** 70+ компонентов поверх shadcn/ui, фокус на scroll-effects и micro-interactions.
**Сильные стороны:** Smooth scroll reveals, interactive cards, современные micro-interactions. Работает естественно с Tailwind + Radix-паттернами.
**Когда брать:** Next.js проекты где нужна плавность взаимодействий без написания анимаций с нуля.
**URL:** https://21st.dev/skiper-ui

---

#### 21st.dev
**Что:** Платформа-реестр компонентов + AI agent registry. Место где можно найти компоненты от ReactBits, Skiper UI и других за один визит.
**Сильные стороны:** "Vibe-crafting tool" — browse → copy → build. Есть Claude-совместимые конфиги агентов. Хорошо для дискавери.
**Когда брать:** Когда ищешь конкретный компонент или нужно быстро собрать что-то из готового.
**URL:** https://21st.dev

---

#### Tremor
**Что:** Tailwind-компоненты специально для дашбордов и data visualization: charts, KPI cards, tables, metrics.
**Сильные стороны:** Узкая специализация = отличное качество в своей нише. Любой chart выглядит чисто и профессионально сразу без стилизации. 2026 = go-to для engineering-команд с data-heavy UI.
**Когда брать:** SaaS дашборды, аналитика, admin panels, любой UI где главное — данные.
**Ограничение:** Узкий set компонентов, плохо подходит для marketing-сайтов.
**URL:** https://tremor.so

---

#### Mantine
**Что:** 120+ компонентов + 100 хуков, CSS Modules (без Emotion начиная с v7).
**Сильные стороны:** Лучший developer experience среди всех библиотек. Огромный набор: date pickers, rich text editor, все что нужно для сложного SaaS. 30k+ GitHub stars.
**Когда брать:** Сложные продуктовые UI: форм-heavy, много состояний, нужна глубокая кастомизация темы.
**URL:** https://mantine.dev

---

#### NextUI (теперь HeroUI)
**Что:** Компоненты с современным визуальным качеством, smooth анимации out of the box. Построен на Tailwind Variants.
**Сильные стороны:** Компоненты выглядят хорошо без кастомизации — отличный default. Хорош для быстрых MVP где нет дизайнера.
**Ограничение:** Theming поверхностный — сложно сделать "своим".
**URL:** https://nextui.org (редиректит на heroui.com)

---

#### Radix UI / Base UI
**Что:** Unstyled primitives с отличной accessibility. Base UI — следующее поколение от создателей Radix.
**Сильные стороны:** Лучшая accessibility на рынке, полная свобода стилизации, идеально для кастомных design systems.
**Когда брать:** Команда строит собственную design system с нуля и знает что делает.
**URL:** https://radix-ui.com | https://base-ui.com

---

## 3. Анимационные паттерны

### Выбор инструмента

| Инструмент | Вес | Когда использовать | Уровень |
|-----------|-----|-------------------|---------|
| **CSS Scroll-Driven Animations** | 0KB | Простые scroll-reveals, parallax. Chrome 115+, Safari 26+. | Beginner |
| **View Transitions API** | 0KB | Page transitions, morphing элементов между страницами. Baseline Oct 2025. | Intermediate |
| **Tailwind CSS Motion** | 5KB | Простые UI-анимации, чисто CSS. | Beginner |
| **Motion (ex-Framer Motion)** | 85KB | Сложные scroll-анимации в React, layout transitions, exit animations. v12: hardware-accelerated scroll. | Intermediate |
| **GSAP + ScrollTrigger** | 78KB | Профессиональные timeline-анимации, SVG morphs, точный scrubbing. | Advanced |
| **Lottie** | — | Дизайнерские анимации (icons, illustrations). С state machines (2025) — базовая интерактивность. | Beginner |
| **Rive** | 10–15x меньше Lottie | Интерактивные анимации со state machine, data binding, scripting. | Advanced |
| **React Three Fiber / Three.js** | Heavy | 3D иммерсивные сцены, WebGL hero. | Expert |

### Ключевые паттерны 2026

**Scroll-triggered reveals** — самый применяемый паттерн. Элементы появляются при скролле с staggered задержкой.
```
GSAP + ScrollTrigger: pixel-perfect контроль scrubbing
Motion: лучший DX в React, достаточно для большинства
CSS scroll-driven: нативно, без JS, если не нужен старый Safari
```

**Hero animations с staggered reveal** — загрузка страницы с оркестрованным появлением элементов (заголовок → подзаголовок → CTA → изображение) с animation-delay.

**Page transitions (View Transitions API)** — плавные морфинг-переходы между страницами. `document.startViewTransition()`. Baseline в октябре 2025. React 19 добавил `<ViewTransition>` компонент.

**Parallax scrolling** — GSAP ScrollTrigger даёт точный контроль. Motion + useScroll — проще в React.

**3D scroll storytelling** — React Three Fiber + GSAP: камера движется по сцене при скролле. Самый сложный, но эффект — Awwwards-уровень.

**Micro-interactions** — hover-states, focus-states, loading states. Motion AnimatePresence для exit-анимаций. Rive для кастомных интерактивных элементов.

### Живые примеры (эталоны)

- **Messenger.com** — Awwwards Site of the Year 2025. WebGL планета, 3D анимации, scroll-storytelling.
- **linear.app** — эталон micro-interactions: анимации показывают скорость продукта, не декорируют.
- **stripe.com** — анимированные gradient + subtle scroll-reveals, product-first hero.
- **vercel.com** — animated build log как hero, scroll-driven демонстрация скорости.
- **Bruno Simon portfolio** (brunosimon.io) — 3D-мир управляемый мышкой, R3F.
- **Codrops Creative Hub** (tympanus.net/codrops) — 1000+ демо, ежемесячные туториалы по GSAP, WebGL, R3F.

---

## 4. Brand Identity Pipeline — как собирать быстро

### Порядок действий (от идеи до готового брендбука за 1 день)

**Шаг 1: Ситемапинг и структура (Relume, 20 мин)**
Relume.io — описываешь проект в 2-3 предложениях → AI генерирует полный sitemap → автоматически конвертирует в wireframes → экспорт в Figma или Webflow.
Оценка 7.4/10. Стоит $38/мес (Freelancer). Сокращает ранние стадии с дней до 20 минут.

**Шаг 2: Цветовая палитра**

| Инструмент | Что делает | Цена |
|-----------|-----------|------|
| **Khroma** (khroma.co) | AI-нейросеть обучается на твоих предпочтениях, генерирует палитры в контексте (типографика, UI, градиенты). Показывает как цвет выглядит applied. | Бесплатно |
| **Coolors** (coolors.co) | Быстрый генератор, lock ключевых цветов пока варьируешь остальные. Simulator для color blindness, contrast checker. | Free / $4 мес |
| **Realtime Colors** (realtimecolors.com) | Тестируешь палитру на живом UI прямо в браузере. Лучший для быстрого preview. | Бесплатно |

**Шаг 3: Типографика**

| Инструмент | Что |
|-----------|-----|
| **Fontpair.co** | 1000+ кураторских Google Fonts пар. Preview с твоим текстом. |
| **Fontjoy.com** | AI-генератор пар одним кликом. |
| **Fontaine** (fontain.app) | AI паринг с context-aware подбором. |
| **Typ.io** | Реальные примеры парингов с живых сайтов. |

**Топ-пары 2026:**
- Display + Monospace: Clash Display + JetBrains Mono (tech/startup)
- Editorial: Playfair Display + Source Sans 3 (premium/editorial)
- Geometric: Cabinet Grotesk + Inter (clean SaaS)
- Bold современный: Satoshi + Satoshi (единая гарнитура, разные веса)

**Шаг 4: Style guide**
Relume Style Guide Builder или DESIGN.md подход (ниже).

### DESIGN.md паттерн (новый стандарт 2026)
GitHub-репозиторий VoltAgent/awesome-design-md собрал 69+ готовых DESIGN.md файлов от топовых компаний (Claude, Vercel, Stripe, Linear, Figma, Apple, Nike...).
Каждый файл = полная design system в markdown: цвета, типографика, спейсинг, компоненты, atmosphere.
Паттерн использования: кладёшь DESIGN.md в корень проекта → AI-агент читает его → генерирует UI в стиле нужного бренда.
**URL:** https://github.com/VoltAgent/awesome-design-md

---

## 5. Промт-паттерны для AI-дизайна

### Почему AI генерирует "слоп"

По умолчанию Claude / v0 / Lovable тяготеют к:
- Inter, Arial, системные шрифты
- Фиолетовые градиенты на белом
- Стандартный hero: заголовок слева, кнопка, картинка справа
- Нет характера, нет настроения

Решение: явно задавать эстетические ограничения.

### DISTILLED_AESTHETICS_PROMPT

Вставляй этот блок целиком в НАЧАЛО любого промта к AI-генерации (Claude Design, Claude Code, v0, Lovable). Он режет AI-слоп — дистиллированный промт из Anthropic Cookbook.

### Базовый промт-антислоп (для Claude / Claude Design)

```
<frontend_aesthetics>
Избегай типичных AI-выходов ("AI slop"):

Типография:
- НЕ: Inter, Arial, Roboto, Open Sans
- ДА: Clash Display, Satoshi, Cabinet Grotesk (startup); Playfair Display, Crimson Pro (editorial); JetBrains Mono, Fira Code (tech)
- Используй экстремальные контрасты веса: 100 vs 900, размеры 3x+

Цвет:
- НЕ: фиолетовые градиенты, голубой на белом
- ДА: связная эстетика через CSS-переменные. Один доминирующий цвет, один контрастный акцент.
- Вдохновение: IDE-темы, культурные эстетики (японский минимализм, brutalist print)

Анимация:
- Оркестрированная загрузка: staggered reveals с animation-delay
- Фокус на высокоударные моменты (hero, переходы между секциями)
- Не анимируй всё — анимируй то что несёт смысл

Фон:
- Атмосфера вместо solid colors: CSS gradients, геометрические паттерны, шум/текстура
- Depth через слои, не плоскость

Откажись от: cookie-cutter layouts, stock imagery, generic CTA buttons
</frontend_aesthetics>
```

### 7 готовых промт-шаблонов

---

**ШАБЛОН 1: Лендинг SaaS-продукта**
```
Ты — дизайн-инженер с aesthetic Stripe + Linear.

Создай landing page для [ПРОДУКТ] ([1 предложение о продукте]).
ЦА: [кто это, их боль].

Эстетика:
- Тёмная тема, почти чёрный фон (#0A0A0A), белый текст
- Акцент: [ЦВЕТ] (один, не три)
- Типографика: Satoshi (заголовки, 700–900) + Inter (текст, 400)
- Hero: продукт UI screenshot сразу виден, не абстрактная иллюстрация

Обязательно:
- Staggered reveal при загрузке (hero → subtitle → CTA с задержкой)
- Bento-grid для фич секции
- Одна CTA кнопка, не три
- Social proof: логотипы пользователей, не текстовые отзывы

Не использовать: gradient hero, stock photos, пять разных синих кнопок
```

---

**ШАБЛОН 2: Лендинг локального бизнеса (кофейня, студия, ресторан)**
```
Создай landing page для [БИЗНЕС] в стиле [РЕФЕРЕНС: Kinfolk magazine / японский минимализм / French editorial].

Атмосфера: [тёплая + уютная / холодная + профессиональная / дерзкая + яркая]
Цветовая палитра: earth tones / monochrome + акцент / ...

Типографика: editorial serif (Playfair Display или Cormorant) для заголовков, sans-serif (Satoshi) для текста.
Изображения: большие, дышащие, много whitespace.
Анимация: subtle scroll-fade, без aggressive motion.

Структура: Hero (атмосфера) → О нас (история) → Продукт/Меню → Где найти → Контакты
Мобайл first.
```

---

**ШАБЛОН 3: Дашборд / SaaS UI**
```
Ты строишь UI для [ПРОДУКТ]. Данные: [что отображается].

Стек: shadcn/ui + Tremor для charts + Tailwind v4.
Тема: тёмная или светлая (выбери одну, не обе).

Layout:
- Sidebar nav (фиксированная) + main content area
- KPI cards вверху (Tremor AreaChart или BarChart)
- Таблица данных с sorting и filtering внизу

Принципы:
- Данные на первом плане, chrome минимален
- Цветовая кодировка метрик: зелёный = рост, красный = падение
- Пустые состояния продуманы (empty state с CTA)

Не добавлять: украшения ради украшений, анимации везде, gradient backgrounds
```

---

**ШАБЛОН 4: Питч-дек / презентация**
```
Создай [N]-слайдовую презентацию для [ТЕМА/ПРОДУКТ].

Инструмент: [Gamma / Beautiful.ai / Tome / Claude Design + export]
Аудитория: [инвесторы / пользователи / команда]

Визуальный язык:
- Минималистичный, данные говорят сами
- Одна идея на слайд — не пять
- Full-bleed imagery где нужна эмоция
- Конкретные цифры крупно, не buried в тексте

Структура питч-дека (стандарт):
1. Проблема (эмоциональный hook)
2. Решение (40 слов максимум)
3. Размер рынка (TAM/SAM/SOM)
4. Продукт (скриншоты, не описания)
5. Traction (метрики, не слова)
6. Бизнес-модель
7. Команда
8. Что просим / на что

Tone: уверенный, без buzzwords, факты + нарратив
```

---

**ШАБЛОН 5: Мобильный UI (iOS/Android-style)**
```
Создай мобильный UI для [ПРИЛОЖЕНИЕ]. Screen: [конкретный экран].

Стандарты: следуй Human Interface Guidelines (iOS) / Material You (Android).
Вибрация: [нативная / кастомная бренд-личность]

Safe areas: учти notch, bottom bar.
Touch targets: минимум 44×44pt.
Типографика: SF Pro (iOS) / Roboto Flex (Android) или кастомный если бренд диктует.

Ключевые элементы экрана: [список]
Основное действие: одна primary CTA (FAB или нативная кнопка).

Состояния: loading / empty / error — все три должны быть.
```

---

**ШАБЛОН 6: One-pager / инфографика**
```
Создай one-pager для [ТЕМА].
Формат: A4 / web (1440px) / story format.

Контент: [что должно быть на странице]

Визуальная иерархия:
- 3 уровня заголовков: H1 (большой, bold), H2 (средний), body
- Iconography: Lucide или custom SVG, не emoji
- Data visualization: простые чарты или icon-stats вместо сложных графиков

Whitespace: много. Дышащий макет важнее плотного.
Цвет: один акцентный, монохром остальное.

Экспорт: HTML/CSS (for web) или Figma-ready описание
```

---

**ШАБЛОН 7: Скриншот → редизайн (итеративный паттерн)**
```
[Прикрепи скриншот текущего дизайна]

Это текущий дизайн [ПРОДУКТ]. Он выглядит дешево/устаревше/скучно потому что:
- [перечисли что плохо]

Переделай, сохранив:
- Структуру и контент
- Брендовые цвета [если нужно сохранить]

Улучши:
- Типографическую иерархию (больше контраст размеров)
- Spacing (больше whitespace)
- Визуальный rhythm (consistent grid)
- Первый impression за 3 секунды

Референс-эстетика: [linear.app / stripe.com / vercel.com / название конкретного сайта]
```

### Анти-паттерны (от чего всё одинаковое)

1. **Без референсов** — "сделай красиво" → Claude даёт среднее. "Сделай как vercel.com" → конкретный результат.
2. **Все шрифты Inter** — нет характера. Задавай шрифт явно или используй промт-антислоп.
3. **"Добавь анимации"** → Claude добавит везде. Лучше: "staggered reveal при загрузке hero-секции, 0.1s задержка между элементами".
4. **Не говоришь что НЕ делать** — список запретов так же важен как список желаний.
5. **Один большой промт без итераций** — лучше: base layout → review screenshot → улучши типографику → улучши анимации.

---

## 6. Тренды 2026

### Что сейчас в моде

**Bento Grid Layouts (HIGH)**
Модульные сетки в стиле японского ланч-бокса. В 2026 эволюция: active bento — при hover тайл расширяется, проигрывает видео или раскрывает вторичный слой данных.
Примеры: Apple product pages, Linear marketing site.

**Scroll-Driven Typography (HIGH)**
Гигантский текст как главный визуальный элемент. Заголовок занимает весь viewport. Буквы анимируются при скролле.
Техника: GSAP SplitText + ScrollTrigger или Motion `useScroll`.

**Glassmorphism 2.0 (MEDIUM)**
Blur-эффект как информационная архитектура, не просто украшение. Чёткие значения blur-radius и opacity создают иерархию foreground/background. Контролируемый, не хаотичный.

**Neo-Brutalism / Soft Brutalism (MEDIUM)**
Raw layouts, bold borders, высококонтрастные цвета — но с friendly fonts и whitespace. Сигнализирует аутентичность в море отполированных SaaS-сайтов.
Кто использует: творческие агентства, независимые продукты.

**3D Immersive (Awwwards-tier)**
WebGL-сцены интегрированы в scroll storytelling. Больше не "один 3D объект посередине страницы" — это scroll-driven narratives где камера движется по 3D миру.
Инструменты: React Three Fiber + Drei + GSAP ScrollTrigger.
Пример: Messenger.com (Awwwards SOTY 2025), Bruno Simon portfolio.

**Claymorphism (MEDIUM)**
Inflated 3D shapes с soft shadows и мягкими краями. CSS-only для простых вариантов. Популярно в мобильном дизайне.

**Dark Mode как фундамент (HIGH)**
Не "опция тёмной темы" — а дизайн изначально для тёмной, светлая как альтернатива. Linear, Vercel, Raycast — все начинают с тёмной.

**Variable Fonts + Fluid Typography (HIGH)**
CSS `clamp()` + variable fonts = типографика адаптируется к viewport плавно без breakpoints.
```css
font-size: clamp(1rem, 2.5vw, 2rem);
```

**Product UI в hero-секции (HIGH)**
Real interface screenshots вместо абстрактных иллюстраций. Figma, Miro, Linear, Calendly — все ставят реальный продукт сразу.

### Что уходит

- Generic serif fonts без характера
- Тяжёлые декоративные эффекты везде
- Abstract tech illustrations (circuit boards, floating orbs)
- Пять разных CTA кнопок на странице
- Full-screen pop-ups сразу при загрузке
- "Фиолетовый градиент на белом" как дефолт AI-дизайна

---

## 7. Источники вдохновения — куда ходить каждую неделю

### Галереи сайтов

| Ресурс | Фокус | Частота визита |
|--------|-------|----------------|
| **Godly.website** | Топ AI, Web3, portfolio сайты. Динамические превью. + Jobs board, Framer/Figma templates. | Еженедельно |
| **Awwwards.com** | Лучшие сайты в мире, Site of the Day/Month/Year. Annual Awards 2025 уже доступны. | Еженедельно |
| **Screenlane** | UX/UI screenshots от лучших SaaS-продуктов. Для mobile patterns. | Еженедельно |
| **saaslandingpage.com** | Только SaaS лендинги. 10 inspiration-сайтов в одном месте. | По запросу |
| **saasframe.io** | SaaS patterns + trends-анализ. | По запросу |
| **landingfolio.com** | 341+ SaaS landing pages, фильтры по стилю. | По запросу |
| **saaspo.com** | Дизайн-инспирация SaaS сайтов. | По запросу |
| **Codrops** (tympanus.net/codrops) | Туториалы + 1000+ демо по GSAP, WebGL, R3F, scroll. Обновляется еженедельно. | Еженедельно |

### Дизайн-системы эталонов (изучить как референсы)

| Компания | Что изучать | URL |
|----------|------------|-----|
| **Linear** | Pixel-perfect precision, fast animations, темная тема | linear.app |
| **Stripe** | Product-first hero, calm confidence, документация как бренд | stripe.com |
| **Vercel** | Dual-audience design (dev + exec), animated deployment hero | vercel.com |
| **Anthropic** | Restraint как дизайн-решение, без AI-хайпа визуально | anthropic.com |

### DESIGN.md файлы (готовые design systems для AI-агентов)
**VoltAgent/awesome-design-md** — 69+ DESIGN.md файлов от топовых компаний.
Положи в корень проекта → скажи агенту "следуй DESIGN.md" → получи стиль нужного бренда.
**URL:** https://github.com/VoltAgent/awesome-design-md

### Кого смотреть (Twitter/X)

| Аккаунт | Специализация |
|---------|--------------|
| @kloss_xyz | AI + UI prompts, дизайн-агенты |
| @reallynattu | Claude Code + UI animations, практические демо |
| @dann | Dann Petty, 164K фолловеров, Design Director |
| @Smashing | Smashing Magazine, тренды UX/UI |
| @awwwards | Официальный аккаунт, ежедневные лучшие сайты |

---

## 8. Recommended Stack по типу задачи

### A) Слайды / Питч-деки

**Быстро + без кода:**
- **Gamma** ($10–20/мес) — промт → готовая презентация за 2 минуты. Лучший для нетехнических.
- **Beautiful.ai** — Smart Slides с встроенными design rules. Нельзя сделать некрасиво. Лучший для команд.
- **Tome** — storytelling-формат, cinematic layouts. Лучший для creative pitches и brand narratives.

**С контролем дизайна:**
- **Claude Design** (launched Apr 17, 2026) — Opus 4.7, промт → питч-дек + экспорт. Прямой handoff в Claude Code.
- **Canva Pro** — максимальный выбор템 template + AI-генерация. Для нетехнических + маркетинг.

**Рекомендация по ситуации:**
- Стартап → инвесторы ($500K+): Beautiful.ai или Tome
- Внутренняя презентация: Gamma
- Пользовательский питч-дек с AI: Claude Design
- Учебный модуль / инфографика: Canva Pro

---

### B) Лендинги

**No-code (дизайнер без кода):**
- **Framer** ($15/мес) — Figma-like canvas, AI-генерация, лучшие анимации из no-code tools. Выбор для дизайнеров. Идеален для landing pages и портфолио.
- **Webflow** — мощнее для content-heavy сайтов, сложный CMS, лучший SEO. Выбор для агентств и долгосрочных сайтов.

**Vibe-coded (AI + код):**
- **v0.dev** — Vercel: React + Tailwind + shadcn из промта. Производственный качество компонентов.
- **Lovable** — full-stack из промта. Для MVP с backend.
- **Google Stitch** — бесплатно, 350 генераций/мес, лучший для дизайн-экспорта в Figma.

**Coded (дизайнер + разработчик):**
```
shadcn/ui (base) 
+ Magic UI или Aceternity UI (wow-эффекты)
+ Motion или GSAP (анимации)
+ Tailwind v4 (стили)
+ Next.js (фреймворк)
```

**Пример по типу пользователя:**

| Пользователь | Stack | Почему |
|--------|-------|--------|
| Кофейня | Framer + Fontpair + Coolors | За 1 день, красиво, пользователь сам обновляет CMS |
| AI-стартап (MVP) | Lovable или v0 + Magic UI | Быстро, с бекендом, shadcn-качество |
| SaaS ($) | Next.js + shadcn + Aceternity + GSAP | Полный контроль, production-grade |
| Фотограф/портфолио | Framer | Анимации, визуальный импакт |
| Локальный ресторан | Framer + Unsplash + Khroma | 1 день, приятно, mobile-first |

---

### C) Дашборды и SaaS UI

**Stack по умолчанию:**
```
shadcn/ui (компоненты)
+ Tremor (charts и data visualization)  
+ Tailwind v4 (стили)
+ TanStack Table (таблицы)
+ Recharts или Nivo (сложные графики)
```

**Варианты по масштабу:**

| Уровень | Стек | Когда |
|---------|------|-------|
| MVP дашборд | shadcn/ui + Tremor + Next.js | Быстро, выглядит профессионально |
| Средний SaaS | shadcn + Tremor + Mantine (для хуков и форм) | Нужно много форм + данных |
| Enterprise | Ant Design или MUI + кастомная система | Большая команда, строгий бренд |
| Data-heavy | Tremor + Observable Plot или D3 | Кастомные визуализации данных |

**Принципы хорошего dashboard-дизайна 2026:**
1. Data сначала, chrome минимален — каждый пиксель объясняется данными
2. Dark mode как основа — тёмный фон снижает eye strain при долгой работе
3. Progressive disclosure — не показывай всё сразу, drill-down паттерн
4. Пустые состояния продуманы — empty state с CTA это UX, не afterthought
5. Real-time feedback — skeleton loaders, optimistic updates

---

## Чеклист Design-агента перед выдачей результата

- [ ] Указан конкретный стек (не "используй компоненты")
- [ ] Есть ссылка на живой пример / эталонный сайт
- [ ] Промт содержит анти-паттерны (что НЕ делать)
- [ ] Типографика задана явно (не "красивые шрифты")
- [ ] Анимации объяснены через функцию, не "добавь анимации"
- [ ] Указан инструмент с обоснованием (Framer vs Next.js и почему)

---

*Источники верифицированы по 3+ независимым URL. Данные на 2026-04-21.*
*Обновить: при появлении мажорных релизов shadcn v2, Motion v13, Tailwind v5.*
