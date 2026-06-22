---
title: "Матрица решений: что использовать для какой задачи"
updated: 2026-05-13
owner: Designer
---

# Матрица решений

Быстрый справочник. Читай сверху вниз — найди задачу, бери решение.

**Условие:** все решения с пометкой `MCP` — работают только если у тебя подключены MCP-серверы (Magic UI / ReactBits / Aceternity / 21st.dev Magic). Если не подключены — используй колонку «Fallback» (нативный Tailwind / shadcn / Motion).

---

## Hero-секции

| Тип hero | Решение (MCP) | Fallback (без MCP) |
|----------|---------------|--------------------|
| Spotlight за мышью | `spotlight` + `background-beams` (Aceternity) | Motion + CSS radial-gradient на mousemove |
| Сетка на фоне | `animated-grid-pattern` (Magic UI) | CSS `background-image` с SVG-сеткой |
| WebGL фон | `Aurora` / `Threads` / `Waves` (ReactBits) | CSS-градиент + Motion `animate` |
| Параллакс с продуктами | `hero-parallax` (Aceternity) | GSAP ScrollTrigger вручную |
| Частицы | `particles` (Magic UI) | tsParticles npm |
| Видео-фон | `<video>` + gradient overlay | то же |
| Свечение сверху | `lamp` (Aceternity) | CSS radial-gradient + blur |
| Генеративный фон | Claude Design → картинка | то же |

## Текст и заголовки

| Эффект | Решение (MCP) | Fallback |
|--------|---------------|----------|
| Gradient text | `bg-gradient-to-r bg-clip-text text-transparent` | то же (нативный Tailwind) |
| Печатающий текст | `typewriter-effect` (Aceternity) | Motion + useEffect setInterval |
| Ротация слов | `word-rotate` (Magic UI) | Motion `AnimatePresence` + setInterval |
| Посимвольное появление | `SplitText` (ReactBits) | Motion `stagger` по буквам вручную |
| Генеративное появление | `text-generate-effect` (Aceternity) | Motion `whileInView` + blur |
| Blur-появление | `blur-fade` (Magic UI) | Motion `initial: filter blur(8px)` |
| Счётчик цифр | `number-ticker` (Magic UI) | Motion `useMotionValue` + spring |

## Карточки и сетки

| Тип | Решение (MCP) | Fallback |
|-----|---------------|----------|
| Bento grid (фичи) | `bento-grid` (Magic UI) | CSS Grid `grid-cols-3` + `col-span` |
| 3D-карточка с наклоном | `3d-card-effect` (Aceternity) | Motion `useTransform` + perspective |
| Карточка с gradient border | `magic-card` (Magic UI) | CSS gradient border + conic-gradient |
| Карточка с hover glow | `hover-border-gradient` (Aceternity) | Tailwind `hover:shadow-[color]` |
| Карточка с border beam | `border-beam` (Magic UI) | Motion + animated CSS border |
| Простая карточка | shadcn `Card` + glass | то же |

## Кнопки и CTA

| Эффект | Решение (MCP) | Fallback |
|--------|---------------|----------|
| Shimmer/блеск | `shimmer-button` (Magic UI) | Tailwind `animate-shimmer` + gradient |
| Moving border | `moving-border` (Aceternity) | CSS conic-gradient + animation |
| Magnetic (тянется к курсору) | custom + Motion `useSpring` | то же |
| Pulse glow | `animate-pulse` + `shadow-[color]` | то же (нативный Tailwind) |
| Стандартный pill | shadcn `Button` + `rounded-full` | то же |

## Прокрутка и скролл

| Эффект | Решение | npm |
|--------|---------|-----|
| Smooth scroll | Lenis | `lenis` |
| Scroll-triggered анимация | GSAP ScrollTrigger | `gsap` |
| Pin секция при скролле | GSAP ScrollTrigger `pin: true` | `gsap` |
| Parallax при скролле | GSAP ScrollTrigger + `y` transform | `gsap` |
| Scrub анимация (привязка к скроллу) | GSAP `scrub: true` | `gsap` |
| Progress bar скролла | `tracing-beam` (Aceternity) или Motion `useScroll` | mcp / motion |
| Появление при скролле | Motion `whileInView` | `motion` |

## Логотипы и социальное

| Тип | Решение (MCP) | Fallback |
|-----|---------------|----------|
| Бегущая строка логотипов | `marquee` (Magic UI) | CSS `@keyframes` + `transform: translateX` |
| Карусель отзывов | `animated-testimonials` (Magic UI) | shadcn `Carousel` (Embla) |
| Бесконечная карусель карточек | `infinite-moving-cards` (Aceternity) | CSS infinite scroll |
| Аватары стопкой | `avatar-circles` (Magic UI) | Flex с `-ml-2` overlap |

## Навигация

| Тип | Решение (MCP) | Fallback |
|-----|---------------|----------|
| Floating navbar | `floating-navbar` (Aceternity) | Motion + scrollY listener |
| Dock (macOS) | `dock` (Magic UI) | Motion + useTransform на mouseX |
| Animated tabs | `tabs` (Aceternity) | shadcn `Tabs` + Motion `layoutId` |
| Стандартный navbar | shadcn `NavigationMenu` | то же |

## Фоны и декор

| Эффект | Решение (MCP) | Fallback |
|--------|---------------|----------|
| WebGL потоки | `Threads` (ReactBits) | CSS-only пыль/градиент |
| Волны | `Waves` (ReactBits) | SVG `<path>` + Motion |
| Северное сияние | `Aurora` (ReactBits) | CSS-конические градиенты + blur |
| Сетка точек | `dot-pattern` (Magic UI) | CSS `radial-gradient` repeated |
| Сетка линий | `animated-grid-pattern` (Magic UI) | SVG `<pattern>` |
| Метеоры | `meteors` (Magic UI) | Motion + случайные линии |
| Лучи | `background-beams` (Aceternity) | SVG `<line>` + Motion |
| Градиент анимированный | `background-gradient` (Aceternity) | CSS `@keyframes` на `background-position` |
| Noise/зернистость | CSS `background-image: url(noise.svg)` | то же |
| Частицы | `particles` (Magic UI) | tsParticles |
| Ripple | `ripple` (Magic UI) | Motion + клик-trigger |

## Иконки

| Тип | Решение | npm |
|-----|---------|-----|
| Стандартные иконки | Lucide React (дефолт shadcn) | `lucide-react` |
| Анимированные иконки | lucide-animated | `lucide-animated` |
| Большой набор стилей | Phosphor Icons (6 стилей) | `@phosphor-icons/react` |
| Микро-интеракции | React UseAnimations (Lottie) | `react-useanimations` |

## Изображения

| Задача | Решение |
|--------|---------|
| Hero-фон | Claude Design → экспорт PNG/WebP |
| Product shot | Claude Design (mockup стиль) |
| Иллюстрация | Claude Design (flat vector style) |
| Объект без фона | Claude Design + указание «transparent background» |
| Стилизация фото | Claude Design img2img с референсом |

---

## Быстрые рецепты (copy-paste решения)

**Условие:** рецепты ниже предполагают подключённые MCP. Без MCP — берёшь логику структуры, исполняешь через Fallback-колонку выше.

### «Сделай лендинг за 2 часа»
1. Hero: Aceternity `spotlight` + Magic UI `shimmer-button`
2. Логотипы: Magic UI `marquee`
3. Фичи: Magic UI `bento-grid`
4. Отзывы: Magic UI `animated-testimonials`
5. CTA: Aceternity `lamp` + `shimmer-button`
6. Footer: 21st.dev Magic генерация

### «Сделай wow-hero»
- Aceternity `spotlight` + `background-beams`
- Motion `fade-up` на заголовке
- Magic UI `word-rotate` в подзаголовке
- ReactBits `Aurora` на фоне (если светлый ледяной стиль) или `Threads` (тёмный)

### «Карточки фич с анимацией»
- Magic UI `bento-grid` (layout)
- Motion `staggerChildren` (появление)
- Hover: `translateY(-4px)` + `shadow` increase
- Border: `border-beam` на featured карточке

### «Секция с цифрами»
- Magic UI `number-ticker` для каждой цифры
- Motion `whileInView` для триггера
- Grid: `grid-cols-2 md:grid-cols-4`
- Glass карточки с иконками (стиль — из Brand Book)

### «Страница с длинным скроллом»
- Lenis smooth scroll (глобально)
- GSAP ScrollTrigger на каждой секции
- Motion `whileInView` для мелких элементов
- Aceternity `tracing-beam` для progress
