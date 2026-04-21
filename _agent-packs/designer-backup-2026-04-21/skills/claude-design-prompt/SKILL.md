---
name: claude-design-prompt
description: >
  Генерирует готовый промт для claude.ai/design на основе Brand Book клиента и типа дизайна.
  Результат — 2-3 абзаца текста, готовые к копированию. Запускается когда клиент выбрал
  Claude Design как стек для задачи. MANDATORY TRIGGERS: промт для Claude Design,
  промт для claude.ai/design, сделай картинку, обложка через Claude Design, визуал картинкой.
---

# Claude Design Prompt — промт для claude.ai/design

Твоя задача — превратить задачу клиента в мега-промт для claude.ai/design. 2-3 абзаца. Клиент копирует → вставляет → получает результат.

**Разведение с `creative-brief`:** этот скилл для **AI-генерации** (claude.ai/design). Если задача для **внешнего человека-дизайнера / фрилансера** — запускай `creative-brief`, там ТЗ формат. Не путай эти два скилла.

## Вход

- **Brand Book клиента** — `knowledge/brand/{project}/brand-book.md`. Если файла нет — **остановись** и запусти `brand-onboarding`.
- **Тип дизайна** — из `knowledge/design-catalog.md` (лендинг, обложка, карточка, one-pager, и т.д.)
- **Специфика запроса** — что именно делаем (обложка канала про AI / карточка с ценой / постер мероприятия)

## Шаги

### 1. Прочитай Brand Book

Вытащи оттуда:
- Палитра: все hex-коды
- Шрифты: точные названия
- Настроение: список прилагательных
- Запреты: что НЕ использовать

### 2. Определи формат

Из design-catalog.md — размер в пикселях и ratio. Если не из каталога — уточни у клиента.

### 3. Собери концепцию

3-5 строк у себя в голове (не вываливай клиенту если не просит):
- **Главный элемент** — что в центре кадра (один объект или сцена, не "всё и сразу")
- **Композиция** — минимализм / симметрия / диагональ / слои
- **Свет** — откуда идёт свет, какая атмосфера
- **Текстура** — гладкая / зернистая / бумажная / стеклянная
- **Настроение в одной фразе** — "тревожное утро после грозы"

### 4. Напиши промт

**ПЕРЕД структурой промта** — обязательно встрой в самое начало блок `DISTILLED_AESTHETICS_PROMPT` из `../../knowledge/design-stack-2026.md`. Это режет AI-слоп. Без него Claude Design даёт "средний результат по палате".

**Структура промта для claude.ai/design:**

```
[Абзац 1 — что за дизайн и формат]
Design a [тип дизайна] for [контекст]. Format: [размер] ([ratio]).

[Абзац 2 — концепция и визуальный стиль]
Composition: [главный элемент, как размещён]. Mood: [настроение — 3-5 слов].
Style: [минимализм / иллюстрация / фото / 3D / flat / textured].
Color palette: [hex1] (background), [hex2] (primary), [hex3] (accent), [hex4] (text).
Typography: [Название шрифта для заголовков], [Название шрифта для текста].

[Абзац 3 — запреты и финальные детали]
Avoid: [запреты из Brand Book]. No stock photos of people. No generic gradients.
[Дополнительные важные детали: "leave space at top for overlaid text later",
"centered composition with symmetrical negative space", и т.д.]
```

### 5. Объясни куда копировать

После промта — одно предложение для клиента:
> "Открой claude.ai/design → вставь → через 30 секунд будет картинка. Если не то — вернись, докрутим (например, скажешь 'сделай темнее' или 'замени акцент на охру')."

## Best practices промтинга Claude Design

**Что работает:**
- Конкретные hex-коды (не "dark blue", а "#0a1628")
- 1 главный элемент + 1 акцент — не "5 объектов вокруг"
- Указание композиции словами ("centered", "diagonal", "rule of thirds, subject in right third")
- Указание света ("soft morning light from left", "studio lighting, no shadows")
- Указание текстуры ("matte paper texture", "glossy ceramic", "rough cold stone")
- Имена шрифтов (Claude Design понимает Google Fonts — Inter, Unbounded, Geologica и т.д.)

**Что НЕ работает:**
- "Make it beautiful" — пусто
- "Modern and innovative" — AI-слоп
- Длинные перечисления без иерархии
- Противоречивые указания ("minimalist with lots of detail")
- Текст на самом визуале (Claude Design его часто искажает — лучше "leave space for text overlay", а текст накладывай отдельно)

## Пример

**Вход:** "Обложка Telegram-канала про мой курс по AI-офисам. Brand Book — палитра холодная, тёмно-синий фон #0a1628, акцент охра #e1a17a, шрифт Unbounded для заголовков."

**Выход:**

```
Design a Telegram channel cover image. Format: 1280x720 px (16:9).

Composition: single minimalist structure at the center — a stack of floating
translucent cards arranged in perspective, suggesting modularity and
architecture. Mood: focused, quiet, slightly mysterious — like an empty
control room before a mission. Style: photorealistic with soft matte
textures, shallow depth of field, cinematic. Color palette: #0a1628
(deep navy background, 80% of the image), #1a2040 (secondary depth
layers), #e1a17a (warm ochre — only on key highlights, max 10%),
#E8E8E8 (subtle text accent, very minimal). Typography: Unbounded Medium
for any on-image labels (if present).

Avoid: stock photos of people, generic blue tech gradients, neon glow,
futuristic holograms, Comic Sans or Helvetica. No text on the image itself
— leave the top-right corner empty for overlaid channel title.
Composition should be architectural, not decorative.
```

И ниже:
> "Открой claude.ai/design → вставь этот промт → через 30 секунд будет вариант. Если слишком тёмный — скажи 'lift shadows'. Если цветов мало — 'add a second ochre accent element'."

## Выход

1. **Промт** — 2-3 абзаца, готов к копированию, в блоке ```
2. **Инструкция куда копировать** — 1 предложение
3. **Подсказка для итераций** — 1-2 примера как поправить если не зайдёт

## Self-check перед отдачей

- [ ] Brand Book прочитан, hex-коды и шрифты взяты оттуда
- [ ] Формат указан в пикселях и ratio
- [ ] Композиция и главный элемент конкретны (не "красиво")
- [ ] **Блок `DISTILLED_AESTHETICS_PROMPT` из `../../knowledge/design-stack-2026.md` встроен в начало промта** — без него AI-слоп
- [ ] Запреты из Brand Book вставлены + минимум 3 конкретных запрета (не "avoid AI slop", а "no stock smiling people, no purple gradient, no Helvetica")
- [ ] Нет AI-слопа в промте (innovative, cutting-edge, synergy, revolutionary, transformative)
- [ ] Текст на визуале НЕ просится — только "leave space for text overlay"
