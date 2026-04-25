# Knowledge Index — Дизайнер

| Файл | Что внутри |
|------|------------|
| `design-catalog.md` | Каталог из ~10 типов дизайнов — когда что делать, какой стек, промт-стаб |
| `design-stack-2026.md` | **Топовые стеки 2026** — 13 компонентных библиотек (shadcn, Magic UI, Aceternity, ReactBits, Skiper, Tremor...), 6 анимационных стеков (Motion, GSAP, Lottie, Rive, R3F), DISTILLED_AESTHETICS_PROMPT из Anthropic Cookbook, 7 готовых промтов, паттерн DESIGN.md, рекомендованные стеки под 3 контекста (слайды/лендинги/дашборды) |
| `landing-frameworks.md` | **Смысловая структура лендингов** — 22 фреймворка конверсии (StoryBrand, PAS, Hormozi, PASTOR, AIDA, BAB...), 5 уровней осознанности по Schwartz, 10 нишевых скелетов (SaaS, курс, услуга, B2B...), 7 мастер-промтов, 20 живых референсов, anti-patterns с цифрами |
| `how-to-design.md` | Короткий гайд для пользователя: как работать с Дизайнером, с чего начинать |
| `edge-cases.md` | **Справочник пограничных сценариев** — нет Claude Pro, результат не зашёл, тип не из каталога, пользователь работает в другом AI, Claude обрезал лендинг, хочу как у чужого сайта, и др. Читать когда ситуация нестандартная. |
| `motion-principles.md` | **Библия анимаций** — таблицы тайминга (80-120ms, 400-600ms), Material 3 easing-кривые, Disney-принципы для UI, stagger-паттерны, шаблон "было/стало" в промтах. Читать ПЕРЕД любым упоминанием анимации. |
| `brand-palette-guide.md` | **40 готовых стартовых палитр по нишам** (онлайн-курсы, коучинг, SaaS, e-commerce, AI-платформа, wellness, legal, fintech и др.) — для каждой: Primary/Secondary/Accent/Background в hex, пара Google Fonts, mood в 3-5 словах, rationale. Используется в brand-onboarding как "Вариант №1 Industry Standard". |
| `brand-references-catalog.md` | **30 эталонных брендов** (Apple, Stripe, Linear, Notion, Vercel, Framer, Claude и др.) со slug'ами для `npx getdesign add {slug}`. Используется когда пользователь говорит "хочу как [бренд]" — загружаем их DESIGN.md через skill `brand-reference`. |

---

## Внешние зависимости

| Где лежит | Что | Когда читать |
|-----------|-----|--------------|
| `../../../knowledge/brand/{project}/brand-book.md` | Brand Book конкретного проекта пользователя | ПЕРЕД любым промтом — оттуда берётся палитра, шрифты, настроение |

---

## Ключевые выводы

- **Brand Book — не украшение, а конституция.** Без него дизайны разваливаются в зоопарк. Первое действие с новым пользователем — собрать Brand Book через скилл `brand-onboarding`.
- **Стек определяется задачей, не модой.** Картинка → Claude Design. Интерактив → Claude Code артефакт.
- **Каталог — не догма.** Если запрос не ложится ни в один тип — обсуди с пользователем формат отдельно.
- **Против AI-слопа — `DISTILLED_AESTHETICS_PROMPT`** (из `design-stack-2026.md`). Встраивать в любой AI-промт, чтобы результат не был "очередной градиент-голограмма".
- **Структура лендинга — от осознанности аудитории.** `landing-frameworks.md` → секция Schwartz. Unaware начинается с проблемы, Most Aware — с оффера. Не смешивать.
- **Палитра — из ниши пользователя первой опцией.** `brand-palette-guide.md` даёт "Industry Standard" для 40 ниш — используй в Brand Book онбординге как Вариант №1.
- **Анимации — в цифрах, не "плавно".** `motion-principles.md` всегда открыт при упоминании движения. Не "smooth animations", а "180ms cubic-bezier(0.4,0,0.2,1)".
- **Эталонные бренды грузятся командой.** Пользователь говорит "как Apple" → skill `brand-reference` → `npx getdesign add apple`. Каталог 30 брендов в `brand-references-catalog.md`.
