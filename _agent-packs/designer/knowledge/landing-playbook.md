---
title: "Playbook: создание лендинга от 0 до готового"
updated: 2026-05-13
owner: Designer
---

# Playbook лендинга

Пошаговый гайд исполнения. Дополняет `landing-frameworks.md` — он про **смысл** структуры (Schwartz, awareness, фреймворки), этот — про **техническую сборку**.

**Условие:** рекомендации с пометкой `MCP` работают только если у пользователя подключены MCP-серверы. Если не подключены — смотри fallback-колонку в `component-decision-matrix.md`.

---

## Шаг 0. Подготовка

### 0.1 Brand Book
```
1. Прочитай ../../knowledge/brand/{project}/brand-book.md
2. Если файла нет → запусти скилл brand-onboarding (10 минут диалога)
3. Извлеки: палитру (hex-коды), шрифты, радиусы, настроение, запреты
```

### 0.2 Фреймворк структуры
```
1. Прочитай knowledge/landing-frameworks.md
2. Определи Schwartz-уровень аудитории (1-5)
3. Выбери фреймворк структуры (PAS / AIDA / 4P / Hormozi 5-step / Storybrand)
4. Только потом — техническая сборка ниже
```

### 0.3 Стек (если делаешь Next.js проект)
```bash
# Новый проект:
npx create-next-app@latest --typescript --tailwind --app --src-dir
npm install motion gsap lenis lucide-react
npx shadcn@latest init
```

Если делаешь Claude Code артефакт в чате — стек встроен, ничего не ставишь.

### 0.4 Tailwind конфиг
- Прописать CSS-переменные из Brand Book в `globals.css`.
- Подключить шрифты из Brand Book через `next/font/google` (если работаешь в Next).
- В артефакте — через `<link>` в head.

---

## Шаг 1. Структура секций

Стандартная структура SaaS / коучинг / курс лендинга:

```
1. Navbar        — лого + навигация + CTA
2. Hero          — главный оффер, CTA, визуал
3. Social Proof  — логотипы клиентов / «как видели в»
4. Problem       — боль аудитории
5. Solution      — как продукт решает
6. Features      — 3–6 ключевых фич (bento grid)
7. How it works  — 3 шага
8. Testimonials  — отзывы
9. Pricing       — тарифы
10. FAQ          — вопросы-ответы
11. CTA          — финальный призыв
12. Footer       — ссылки, контакты, соцсети
```

**Адаптируй под фреймворк.** Если Hormozi 5-step — нужны блоки Dream Outcome + Likelihood + Time Delay + Effort & Sacrifice + Risk Reversal. Если Storybrand — нужен Hero (пользователь как герой) + Guide (продукт как проводник) + Plan + Success + Failure.

---

## Шаг 2. Секция за секцией

### 2.1 Navbar
**Компоненты:** shadcn `NavigationMenu` или Aceternity `floating-navbar` `MCP`
**Правила:**
- Лого слева (шрифт из Brand Book)
- 3–5 ссылок по центру
- CTA-кнопка справа (pill, shimmer если MCP)
- Sticky: `sticky top-0 z-50 backdrop-blur-md bg-white/80`
- Mobile: hamburger menu

### 2.2 Hero
**Компоненты:** Aceternity `spotlight` или Magic UI `animated-grid-pattern` + `shimmer-button` `MCP` / fallback CSS
**Структура:**
```
[Фон: WebGL / spotlight / grid / градиент]
  [Container max-w-5xl mx-auto text-center]
    [Badge: «Новое» или категория]
    [H1: gradient text, font из Brand Book, text-5xl md:text-7xl]
    [P: text цвет из Brand Book, max-w-[640px] mx-auto]
    [Buttons: primary + ghost]
    [Social proof mini: аватары + «500+ клиентов»]
```
**Анимация:** fade-up на каждом элементе, stagger 0.1s (см. `animation-patterns.md`).

### 2.3 Social Proof (логотипы)
**Компоненты:** Magic UI `marquee` `MCP` / fallback CSS keyframes
**Правила:**
- Логотипы серые (grayscale, opacity-50, hover:opacity-100)
- Бесконечный скролл в 2 ряда (reverse на втором)
- Текст сверху: «Нам доверяют 500+ компаний»

### 2.4 Problem
**Компоненты:** простой текст + иконки (Lucide React)
**Структура:**
```
[Container]
  [H2: «Знакомо?»]
  [Grid 2 cols: проблемы с иконками ❌]
```
**Анимация:** fade-up, stagger

### 2.5 Solution
**Компоненты:** Aceternity `lamp` `MCP` или split layout (текст + визуал)
**Структура:**
```
[Container]
  [Grid 2 cols]
    [Текст: H2 + описание + bullet points ✓]
    [Визуал: скриншот / Claude Design картинка / 3D-mockup]
```

### 2.6 Features (bento grid)
**Компоненты:** Magic UI `bento-grid` `MCP` / fallback CSS Grid
**Правила:**
- 3–6 фич максимум
- Каждая: иконка + заголовок + описание
- Размеры ячеек: 1 большая (span-2) + остальные стандарт
- Hover: translateY(-4px) + shadow
- Featured карточка: `border-beam` (если MCP) или CSS gradient border

### 2.7 How it works
**Компоненты:** Aceternity `tracing-beam` `MCP` или numbered steps
**Структура:**
```
[Container]
  [H2: «Как это работает»]
  [3 шага: число + заголовок + описание + визуал]
```
**Анимация:** GSAP scrub или Motion stagger.

### 2.8 Testimonials
**Компоненты:** Magic UI `animated-testimonials` `MCP` или Aceternity `infinite-moving-cards` `MCP` / fallback shadcn Carousel
**Правила:**
- Аватар + имя + роль + цитата
- 3–6 отзывов
- Автопрокрутка или карусель

### 2.9 Pricing
**Компоненты:** 21st.dev Magic генерация `MCP` + кастомизация / fallback ручная сборка
**Структура:**
```
[Container]
  [Toggle: месяц / год]
  [Grid 3 cols]
    [Тариф 1: базовый]
    [Тариф 2: рекомендуемый — выделен border + badge]
    [Тариф 3: премиум]
```
**Правила:**
- Рекомендуемый = визуально выделен (border, badge «Популярный»)
- CTA на каждом тарифе
- Фичи с галочками

### 2.10 FAQ
**Компоненты:** shadcn `Accordion`
**Правила:**
- 5–8 вопросов
- Открывается один за раз
- Plus / minus иконка

### 2.11 CTA (финальный)
**Компоненты:** Aceternity `lamp` `MCP` + Magic UI `shimmer-button` `MCP` / fallback CSS gradient
**Структура:**
```
[Фон: gradient или lamp-эффект]
  [H2: «Готов начать?»]
  [P: одна строка]
  [CTA button: большая, shimmer]
```

### 2.12 Footer
**Компоненты:** 21st.dev Magic генерация `MCP` или HyperUI / fallback ручная разметка
**Структура:**
```
[Container]
  [Grid 4 cols]
    [Лого + описание + соцсети]
    [Продукт: ссылки]
    [Компания: ссылки]
    [Контакты: email, телефон]
  [Divider]
  [Copyright]
```

---

## Шаг 3. Responsive

### Breakpoints

| Viewport | Tailwind | Что проверять |
|----------|---------|---------------|
| 375px | default (mobile) | Всё в 1 колонку, текст читаемый |
| 768px | `md:` | 2 колонки где нужно, navbar |
| 1024px | `lg:` | 3 колонки, полная навигация |
| 1280px | `xl:` | Max-width контейнера |

### Правила responsive
- Mobile-first: пиши для mobile, добавляй `md:` и `lg:`
- Grid: `grid-cols-1 md:grid-cols-2 lg:grid-cols-3`
- Текст: `text-3xl md:text-5xl lg:text-7xl`
- Padding: `px-4 md:px-8 lg:px-12`
- Hero image: `hidden md:block` или stack на mobile
- Hamburger: `md:hidden` для mobile menu

---

## Шаг 4. Performance checklist

### Перед отдачей
- [ ] Images: Next.js `<Image>` с `width` / `height` или `fill`, format webp
- [ ] Fonts: `next/font` (не Google Fonts CDN — медленнее)
- [ ] «use client» только где нужно (анимации, interactivity)
- [ ] Lazy load: секции ниже fold — `whileInView` вместо `animate`
- [ ] Bundle: проверь что не тянешь всю библиотеку (tree-shaking)
- [ ] GSAP: `ScrollTrigger.kill()` в cleanup useEffect
- [ ] Lenis: `lenis.destroy()` в cleanup
- [ ] Нет CLS (Cumulative Layout Shift): заданы размеры для картинок
- [ ] Нет unused imports
- [ ] Lighthouse: aim for 90+ Performance

### Оптимизация картинок
```tsx
// ПРАВИЛЬНО:
import Image from "next/image";
<Image src="/images/hero.webp" alt="Hero" width={1920} height={1080} priority />

// Для фона:
<Image src="/images/bg.webp" alt="" fill className="object-cover" priority={false} />
```

---

## Шаг 5. Screenshot Loop

После каждой секции:
1. Запусти dev-сервер (`npm run dev`) если работаешь в проекте, или просто посмотри артефакт справа.
2. Сделай скриншот / посмотри визуально.
3. Сравни с референсом (если есть).
4. Исправь spacing, цвета, пропорции.
5. Финальный скриншот → продолжай.

---

## Чек-лист готовности

- [ ] Все секции на месте
- [ ] Brand Book токены используются (не хардкод цветов и шрифтов)
- [ ] Если MCP подключены — компоненты из библиотек подменены под Brand Book
- [ ] Responsive: 375px, 768px, 1280px проверены
- [ ] Анимации: entrance + hover + scroll (см. `animation-patterns.md`)
- [ ] Accessibility: alt, contrast, focus
- [ ] Performance: images optimized, no CLS
- [ ] Код: clean, components split, no inline styles
- [ ] `design-critique` прогнан — Design Score ≥ B, AI Slop Score ≥ B

---

## Связка с другими файлами

| Когда читать | Файл |
|--------------|------|
| Перед выбором структуры | `landing-frameworks.md` (смысловая логика) |
| Перед выбором компонента | `component-decision-matrix.md` |
| Перед написанием анимации | `animation-patterns.md` + `motion-principles.md` |
| Перед выбором палитры если нет Brand Book | `brand-palette-guide.md` |
| Перед отдачей | запусти скилл `design-critique` |
