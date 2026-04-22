# Credits & Attribution — Designer pack

Designer-агент использует материалы 5 внешних проектов. Все — MIT License, совместимы с этим проектом. Ниже — что взято, откуда, как адаптировано.

---

## 1. garrytan/gstack → skills/design-critique/

**Источник:** [github.com/garrytan/gstack](https://github.com/garrytan/gstack) (MIT License)

**Что взято:** логика аудита дизайна из папки `design-review/` — фазы 1-6 оригинального 11-фазного алгоритма, dual scoring (Design Score A-F + AI Slop Score A-F), blacklist из 11 AI-slop паттернов, hard rules доступности (16px body, 4.5:1 contrast, 44px touch targets).

**Как адаптировано:**
- Сокращено с 11 до 6 фаз — убраны фазы 7-11 (fix loop, автокоммиты, Playwright-зависимости)
- Работает без браузера и кода — анализирует описание артефакта или HTML-сниппет
- Не трогает файлы клиента — возвращает список правок приоритизированный High/Medium/Polish
- Dual scoring сохранён дословно

**Куда положено:** `skills/design-critique/SKILL.md`

---

## 2. LottieFiles/motion-design-skill → knowledge/motion-principles.md

**Источник:** [github.com/LottieFiles/motion-design-skill](https://github.com/LottieFiles/motion-design-skill) (MIT License)

**Что взято:**
- `reference/timing-easing-tables.md` — duration-диапазоны (80-120ms tooltip, 400-600ms page transition), cubic-bezier значения (MD3 Standard, Emphasized, Accelerate), stagger-таблицы
- `director/disney-principles.md` — 12 принципов Disney с параметрами (squash scale [1.2, 0.8], exaggeration 0% для premium до 25% для playful)
- `director/choreography.md` — правило 1/3, stagger-техники (sequential/center-out/random/wave/reverse), three-phase formula
- `SKILL.md` — 8-шаговый чеклист и 4 Motion Personality archetypes (Playful, Premium, Corporate, Energetic)

**Как адаптировано:**
- Собрано в один knowledge-файл для Designer-агента (не отдельный skill — это данные для промтов)
- Убран код (Framer Motion / GSAP рецепты — это для Developer, не Designer)
- Добавлен anti-patterns блок и пример «как использовать в промте» с до/после
- Сохранены все числовые параметры дословно

**Куда положено:** `knowledge/motion-principles.md`

---

## 3. dembrandt/dembrandt → skills/site-extract/

**Источник:** [github.com/dembrandt/dembrandt](https://github.com/dembrandt/dembrandt) (MIT License)

**Что взято:** сам пакет **не копируется** — вызывается через `npx dembrandt` при исполнении skill. Пакет извлекает дизайн-токены (цвета, шрифты, spacing, border-radius) с любого публичного сайта и сохраняет в `output/{domain}/DESIGN.md`.

**Как адаптировано:**
- Создан skill-wrapper который инструктирует Designer когда и как вызвать `npx dembrandt`
- Добавлен fallback: если Node.js недоступен → предлагается использовать brand-reference (если сайт в каталоге) или описать визуал словами
- Guardrails: Brand Book клиента приоритетнее извлечённых токенов

**Attribution:** не требуется (пакет вызывается через npx, не копируется в репо), но упомянуто здесь для полноты картины.

**Куда положено:** `skills/site-extract/SKILL.md`

---

## 4. nextlevelbuilder/ui-ux-pro-max-skill → knowledge/brand-palette-guide.md

**Источник:** [github.com/nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) (MIT License)

**Что взято:** данные из `src/ui-ux-pro-max/data/colors.csv` (161 продуктовая категория → палитры) и `typography.csv` (73 пары шрифтов).

**Как адаптировано:**
- Выбрано **40 ниш** наиболее релевантных для русскоязычной аудитории (эксперты, коучи, курсы, B2B-услуги, SaaS, e-commerce, wellness, fintech)
- Для каждой ниши — Primary / Secondary / Accent / Background (hex) + Heading + Body font (Google Fonts) + Mood + Rationale
- Добавлена секция «как выбирать если ниша на стыке»
- CLI `uipro-cli` **не устанавливается** — берём только данные

**Куда положено:** `knowledge/brand-palette-guide.md`

---

## 5. VoltAgent/awesome-design-md → skills/brand-reference/ + knowledge/brand-references-catalog.md

**Источник:** [github.com/VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) (MIT License). Файлы доступны через [getdesign.md](https://getdesign.md) — сервис VoltAgent.

**Что взято:**
- Концепция каталога DESIGN.md-файлов (69 эталонных брендов)
- Механика вызова `npx getdesign@latest add {brand-slug}`
- Стандарт 9 секций (Visual Theme, Color Palette, Typography Rules, Component Stylings, Layout Principles, Depth & Elevation, Do's and Don'ts, Responsive Behavior, Agent Prompt Guide)

**Как адаптировано:**
- Из 69 брендов выбраны **30** наиболее релевантных для русскоязычной аудитории (AI/Dev tools, SaaS, Design tools, Fintech, Premium consumer, Auto)
- Для каждого бренда — slug, стиль в 1-2 строках, рекомендуемая ниша использования
- Создан отдельный skill `brand-reference` который автоматизирует вызов getdesign CLI
- DESIGN.md файлы сами **не копируются в репо** — загружаются on-demand при запросе клиента

**Attribution:** файлы getdesign.md содержат публично видимые CSS-значения с публичных сайтов брендов, MIT-лицензия awesome-design-md покрывает их использование.

**Куда положено:** `skills/brand-reference/SKILL.md` + `knowledge/brand-references-catalog.md`

---

## MIT License — сводка по всем источникам

Все 5 проектов выпущены под MIT. Это означает:

- **Разрешено:** копировать, адаптировать, встраивать в коммерческие продукты
- **Требуется:** сохранить указание авторства (этот файл)
- **НЕ требуется:** получать разрешение правообладателей

Оригинальные лицензии — в репозиториях источников.

---

## Changelog

**2026-04-21** — Designer v2 integration: создан файл, добавлены 5 attributions

---

*Этот файл — часть пака Designer и устанавливается вместе с агентом в `office/agents/designer/knowledge/credits.md` (копия для клиента).*
