---
name: claude-code-artifact
description: >
  Генерирует промт под HTML/React артефакт в Claude Code — лендинги, дашборды, презентации,
  интерактивные прототипы. Использует Brand Book клиента + стек shadcn/ui + Magic UI + Motion.
  Запускается когда клиент выбрал интерактив как формат. MANDATORY TRIGGERS: промт для артефакта,
  сделай лендинг, дашборд, интерактивная презентация, HTML артефакт, React артефакт,
  промт для Claude Code.
---

# Claude Code Artifact — промт под интерактивный артефакт

Твоя задача — написать структурированный промт под HTML/React артефакт в Claude Code. Это для продвинутых задач: лендинги, дашборды, презентации, прототипы. Результат — готовый к копированию промт, который клиент пришлёт отдельным сообщением в Claude Code.

**Разведение с `creative-brief`:** этот скилл для **AI-генерации** (Claude Code artifact). Если задача для **внешнего человека-разработчика / фрилансера** — запускай `creative-brief`, там ТЗ-формат. Не путай эти два скилла.

## Вход

- **Brand Book клиента** — `knowledge/brand/{project}/brand-book.md`. Если нет — **остановись**, запусти `brand-onboarding`.
- **Тип артефакта** — из `knowledge/design-catalog.md` (лендинг / дашборд / презентация / one-pager / КП / email)
- **Специфика запроса** — что за артефакт, какие секции, какой функционал
- **Для лендингов / продающих страниц ОБЯЗАТЕЛЬНО:** `../../knowledge/landing-frameworks.md` секция 4 (Schwartz Awareness Levels) + раздел 5 (нишевые скелеты). Порядок:
  1. Определи уровень осознанности аудитории (Unaware / Problem / Solution / Product / Most Aware) — спроси клиента одной фразой если не знаешь.
  2. Выбери фреймворк структуры (StoryBrand / PAS / Hormozi / PASTOR) под уровень осознанности.
  3. Возьми нишевый скелет из раздела 5 (SaaS / курс / услуга / B2B / event / ecom).
  4. Вставь структуру секций в промт — она заменяет generic «Hero + Features + CTA».
- **Перед написанием промта** — `../../knowledge/design-stack-2026.md` секция `DISTILLED_AESTHETICS_PROMPT`. Блок встраивается в самое начало промта.

## Стек (всегда использовать)

- **HTML + React** — основа артефакта
- **Tailwind CSS** — стилизация
- **shadcn/ui** — базовые компоненты (Button, Card, Dialog, Tabs, Badge, Input, Progress, Avatar, и т.д.)
- **Magic UI** — premium-компоненты для WOW-эффекта (Marquee, Bento Grid, Animated Beam, Number Ticker, Border Beam, Shimmer Button)
- **Motion** (ex Framer Motion) — анимации входа, скролла, ховера

**Правило:** shadcn = структура. Magic UI = акценты на 1-2 места. Motion = плавность. Не перебирай — 1 Magic UI компонент на экран + 2-3 Motion анимации достаточно.

## Шаги

### 1. Прочитай Brand Book

Палитра, шрифты, настроение, запреты. Шрифты подключаем через Google Fonts в `<head>`.

### 2. Определи структуру артефакта

Из design-catalog.md возьми ориентир. Если лендинг — 5-7 секций. Если дашборд — 3-4 блока на экране. Если презентация — N слайдов.

Проговори секции у себя в голове: hero / problem / solution / features / pricing / testimonials / final CTA — или что уместно типу.

### 3. Напиши промт

**ПЕРЕД структурой промта** — обязательно встрой в самое начало блок `DISTILLED_AESTHETICS_PROMPT` из `../../knowledge/design-stack-2026.md`. Это режет AI-слоп. Без него Claude Code даёт "средний результат по палате".

**Если артефакт — лендинг:** используй Schwartz-уровень + выбранный фреймворк (PAS / Hormozi / PASTOR / StoryBrand) + нишевый скелет из `landing-frameworks.md` раздел 5. Структура секций берётся оттуда, НЕ generic "Hero + Features + CTA".

**Структура промта для Claude Code artifact:**

```
# [Название артефакта] — [краткое описание]

Создай интерактивный артефакт: [тип]. Используй React + Tailwind + shadcn/ui
+ Magic UI + Motion.

## Структура
[Список секций с коротким описанием каждой]
1. Hero: [заголовок, подзаголовок, CTA, визуал]
2. [секция]: [что внутри]
...

## Визуал (Brand Book)
- Палитра: background #XXX, primary #XXX, accent #XXX, text #XXX
- Шрифты: [Заголовки] (Google Fonts), [Текст] (Google Fonts)
- Настроение: [прилагательные]
- Запреты: [из Brand Book]

## Компоненты
- shadcn: Button (primary CTA), Card (для features), Badge (для меток), [что ещё]
- Magic UI: [Marquee / Bento Grid / Border Beam / Shimmer Button] — на [где именно]
- Motion: [fade-in staggered на скролл / hover-lift на карточках / smooth scroll]

## Функционал
- [Что должно быть интерактивным: кнопки ведут куда / модалка открывается / формы]
- Mobile-responsive (обязательно)
- Dark mode: [да / нет / авто]

## Контент
[Если клиент дал текст — вставь сюда. Если нет — напиши:
"placeholder-текст в стиле Brand Book, короткие формулировки,
без AI-слопа"]

## Финальные требования
- Единый артефакт (один HTML файл через React component)
- Производительность: без лишних анимаций, smooth 60fps
- Accessibility: корректные заголовки, alt-тексты, focus states
```

### 4. Объясни куда вставлять

После промта:
> "Открой новый чат в Claude Code → вставь промт → Claude сгенерит артефакт, ты его сразу увидишь в окне справа. Если не нравится — допиши в том же чате ('сделай плотнее', 'поменяй CTA на X'). Итерации работают хорошо."

## Best practices для артефактов

**Что работает:**
- Чёткая структура секций (Claude Code любит нумерованные списки)
- Конкретные компоненты с названиями библиотек ("shadcn Button", "Magic UI Marquee")
- Указание motion-паттернов: "fade-in on scroll with 100ms stagger between children"
- Mobile-first: "320px → 768px → 1024px breakpoints"
- Примеры текста из Brand Book

**Что НЕ работает:**
- "Сделай крутой лендинг" без структуры
- Упоминание библиотек которых нет в Claude Code (например, не проси Three.js для 3D — лучше уточни у клиента или используй CSS 3D)
- Слишком много Magic UI — скатится в hype-carnival
- Требование бэкенд-интеграций — артефакты фронтовые

## Пример

**Вход:** "Лендинг моего курса по AI-офисам. Brand Book: тёмно-синий фон, охра акцент, Unbounded заголовки, Geologica текст."

**Выход:**

```
# Лендинг курса «AI-офис за 6 недель»

Создай интерактивный лендинг-артефакт. Стек: React + Tailwind + shadcn/ui + Magic UI + Motion.

## Структура
1. Hero: заголовок "AI-офис за 6 недель", подзаголовок о сути, CTA "Записаться" (Shimmer Button), фоновая анимация (Animated Beam)
2. Problem/Solution: 2-колоночный блок — "без AI-офиса" vs "с AI-офисом", иконки из lucide-react
3. Features (Bento Grid): 4 карточки — что внутри программы (cтратегия / команда агентов / knowledge / деплой)
4. How it works: 6 шагов-таймлайн (по неделям программы), Motion staggered animation на скролл
5. Pricing: 1 карточка с ценой, Border Beam по периметру, CTA
6. FAQ: shadcn Accordion, 5-7 вопросов
7. Final CTA: фуллскрин блок, большой заголовок, Shimmer Button

## Визуал (Brand Book)
- Палитра: background #0a1628, primary #1a2040, accent #e1a17a (охра), text #E8E8E8
- Шрифты: Unbounded (Medium/Bold) для заголовков, Geologica (Regular/Light) для текста. Подключи через Google Fonts.
- Настроение: сфокусированный, архитектурный, уверенный, немного мистический
- Запреты: стоковые люди, яркие голубые градиенты, неон, Helvetica

## Компоненты
- shadcn: Button, Card, Badge, Accordion, Separator
- Magic UI: Animated Beam (hero фон), Bento Grid (features), Shimmer Button (CTA), Border Beam (pricing карточка), Marquee (логотипы довольных клиентов если есть)
- Motion: staggered fade-in + slide-up на скролл для секций (stagger 80ms), hover-lift на карточках, smooth scroll между секциями

## Функционал
- Все CTA ведут на #pricing (якорь-скролл)
- Mobile-first, breakpoints 320/768/1024
- Dark mode постоянный (у нас по умолчанию тёмная тема)

## Контент
Placeholder-текст в сдержанном уверенном тоне. Максимум 7 слов на заголовках. Никакого "инновационного" и "революционного". Короткие конкретные формулировки.

## Финальные требования
- Один React component в артефакте
- Smooth 60fps, не перегружай Motion анимациями
- Focus states на всех интерактивных элементах, alt-тексты
```

И ниже:
> "Создай новый чат в Claude Code → вставь этот промт → артефакт появится справа. Если что-то не то — допиши в том же чате фидбек. Хорошо итерируется."

## Выход

1. **Промт** — структурированный, готов к копированию, в блоке ```
2. **Инструкция куда вставить** — 1 предложение про Claude Code
3. **Подсказка для итераций** — 1-2 примера фидбеков

## Self-check перед отдачей

- [ ] Brand Book прочитан, палитра/шрифты взяты оттуда
- [ ] Структура секций конкретна (не "всякие секции")
- [ ] **Блок `DISTILLED_AESTHETICS_PROMPT` из `../../knowledge/design-stack-2026.md` встроен в начало промта** — без него AI-слоп
- [ ] **Если лендинг:** Schwartz-уровень определён, фреймворк выбран, нишевый скелет из `landing-frameworks.md` применён (не generic Hero+Features+CTA)
- [ ] Указаны конкретные компоненты (shadcn + Magic UI названиями)
- [ ] Motion-паттерны описаны
- [ ] Mobile-responsive требование есть
- [ ] Запреты из Brand Book вставлены + минимум 3 конкретных запрета (не "avoid AI slop", а "no stock diverse team, no purple gradient hero, no Helvetica")
- [ ] Нет AI-слопа в контенте (innovative, revolutionary, synergy, transformative, paradigm)
- [ ] Не просим бэкенд-интеграции (артефакт фронтовый)
