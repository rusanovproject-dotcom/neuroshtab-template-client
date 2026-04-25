# Каталог типов дизайнов

> Выбор типа — первый шаг любой задачи на дизайн. Запрос пользователя → нахожу ближайший тип → определяю стек → пишу промт.

**Легенда стека:**
- **CD** — Claude Design (claude.ai/design). Быстрый визуал-картинка.
- **CC** — Claude Code artifact (HTML/React в Claude Code). Интерактив.

---

## 1. Личный дашборд недели / трекер целей

**Когда:** пользователь хочет видеть свои цели, метрики, задачи недели одной страницей. Визуальная мотивация + функциональный контроль.

**Стек:** CC (интерактив — важно кликать по целям, отмечать прогресс).

**Промт-стаб:**
> Single-page dashboard artifact. Clean grid layout with 3 sections: goals for the week (top), daily tasks with checkboxes (middle), progress chart (bottom). Use [палитра из Brand Book]. Typography: [шрифты]. Components: shadcn Card, Progress, Checkbox. Motion: subtle fade-in on load. Mobile-responsive.

---

## 2. Лендинг продукта / услуги

**Когда:** одностраничный сайт с оффером, УТП, блоками "для кого / что внутри / цена / отзывы / CTA". Для запуска продукта, продажи консультации, лид-магнита.

**Стек:** CC (лендинг = интерактив — плавающий header, скролл-анимации, клики по CTA).

**Промт-стаб:**
> Landing page artifact. Sections: hero with headline + CTA, problem/solution, 3-column features, pricing card, testimonials, final CTA. Use [палитра из Brand Book]. Typography: [шрифты]. Components: shadcn Button, Card, Badge. Magic UI: Marquee for logos, Bento grid for features. Motion: staggered fade-in on scroll. Mobile-first.

---

## 3. Питч-дек / презентация

**Когда:** 8-15 слайдов для выступления, продажи, инвесторов, команды. Есть структура, нужна визуальная упаковка.

**Стек:** CC (интерактивная презентация — свайпы, анимации между слайдами). Для отдельных слайдов-героев можно CD.

**Промт-стаб:**
> Presentation artifact with N slides. Navigation: arrow keys + swipe. Structure: cover → problem → solution → market → product → traction → team → ask. Use [палитра]. Typography: [шрифты]. Each slide: big title, 1-2 key visuals, minimal text. Motion: slide transitions with Motion library. Dark mode.

---

## 4. One-pager / оффер

**Когда:** один лист с сутью предложения. Не сайт — статичный документ (часто экспортируется в PDF). КП, tear-sheet, summary.

**Стек:** CD (визуал-картинка для PDF) или CC (если нужна интерактивная версия).

**Промт-стаб (CD):**
> Single-page offer document. Layout: header with logo, headline, 3 key points in cards, price block, CTA line, footer. Palette: [Brand Book]. Typography: [шрифты]. Mood: [настроение]. Composition: symmetric, generous whitespace. No stock photos.

---

## 5. Инфографика для соцсетей

**Когда:** карточка для Telegram / Instagram / VK с данными, статистикой, шагами процесса.

**Стек:** CD (чистый визуал, экспорт в png).

**Промт-стаб:**
> Instagram carousel card, 1080x1080. Visualize [что]: [данные]. Layout: [bar chart / step-by-step / comparison]. Palette: [Brand Book]. Typography: [шрифты]. Style: [настроение]. Max 7 words of text. No people, no stock imagery.

---

## 6. Мокап мобильного приложения

**Когда:** демо экрана app-а для презентации, лендинга, портфолио.

**Стек:** CC (интерактивный прототип в iPhone frame).

**Промт-стаб:**
> Mobile app mockup artifact. iPhone frame with screen inside. Show [feature]: [3-4 UI screens stacked]. Palette: [Brand Book]. Typography: [шрифты]. Components: shadcn primitives sized for mobile. Motion: slide between screens. Clean iOS aesthetic.

---

## 7. Визуализация целей / роадмап

**Когда:** таймлайн на квартал / год, roadmap проекта, визуальный план.

**Стек:** CC (интерактивный таймлайн с hover-стейтами) или CD (статичная визуализация).

**Промт-стаб (CC):**
> Roadmap artifact. Horizontal timeline with N milestones. Each milestone: date, title, 1-line description. Palette: [Brand Book]. Typography: [шрифты]. Components: shadcn HoverCard for details. Motion: milestones animate in on scroll. Clean, strategic feel.

---

## 8. Пользовательское КП (коммерческое предложение)

**Когда:** документ для пользователя B2B — структурированное предложение с ценой.

**Стек:** CC (интерактивный документ с оглавлением) или CD (PDF-ready визуал).

**Промт-стаб (CC):**
> Proposal document artifact. Multi-section with sticky nav: cover, context, solution, scope, timeline, investment, next steps. Palette: [Brand Book]. Typography: [шрифты]. Print-friendly. Components: shadcn Tabs for sections, Table for pricing.

---

## 9. Social media assets (Telegram banner / IG cover)

**Когда:** обложка канала, шапка профиля, баннер для поста, welcome-картинка.

**Стек:** CD.

**Промт-стаб:**
> Social banner [размер]. Composition: [1 главный элемент + акцент]. Palette: [Brand Book]. Typography: [шрифты]. Mood: [настроение]. No stock smiling people. No generic gradients. Allow space for overlaid text later.

**Размеры для быстрой справки:**
- Telegram канал обложка: 1280×720 (16:9)
- Telegram сторис: 1080×1920 (9:16)
- Instagram post: 1080×1080 (1:1)
- Instagram story: 1080×1920 (9:16)
- YouTube превью: 1280×720 (16:9)
- VK обложка: 1590×400
- LinkedIn баннер: 1584×396

---

## 10. Email / welcome letter

**Когда:** первое письмо после покупки, welcome-цепочка, шаблон newsletter.

**Стек:** CC (HTML-email artifact, который можно скопировать в ESP).

**Промт-стаб:**
> Email HTML template artifact. Max 600px wide. Structure: logo, headline, 2-3 content blocks, CTA button, footer. Palette: [Brand Book]. Typography: [шрифты — fallback web-safe if needed]. Inline CSS only (email-compatible). Test in dark/light mode.

---

## Что делать если запрос не из каталога

1. Уточни у пользователя формат: "Это статичная картинка или интерактив? Куда пойдёт — в PDF, на сайт, в соцсети, в презентацию?"
2. Подбери ближайший тип из каталога как ориентир
3. Если совсем не ложится — обсуди отдельно, **не насилуй промт** в неподходящий шаблон

## Общее правило выбора стека

| Признак в запросе | Стек |
|-------------------|------|
| "картинка", "постер", "визуал", "иллюстрация", "обложка", "карточка" | CD |
| "сайт", "лендинг", "дашборд", "интерактив", "презентация", "форма", "калькулятор" | CC |
| "КП", "one-pager", "документ" | CC предпочтительнее (гибкость), CD если строго под PDF |
| "email", "письмо" | CC (HTML artifact) |
