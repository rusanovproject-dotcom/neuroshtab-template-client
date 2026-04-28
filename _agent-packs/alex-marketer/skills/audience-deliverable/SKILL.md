---
name: audience-deliverable
description: |
  Phase E пайплайна Stage 1 — собирает интерактивный HTML-артефакт `audience-report.html`
  из закрытой распаковки ЦА для отправки ментору / партнёру / инвестору. Hero + стратегия +
  карточки сегментов с табами (Боли/Желания/Страхи/Возражения/Критерии/Lingvo/VoC) +
  карусель цитат + Next Steps. Опциональная фаза — запускается после `/accept` Stage 1.

  ПРИНЦИП: артефакт «жирный» — 30-50 цитат болей дословно с источниками + лингво × 5
  категорий + цветовая схема сегментов 4 цвета + Hero-формула. Если Brand Book проекта
  есть в `knowledge/brand/<project>/brand-book.md` — палитра и шрифты берутся оттуда.

  КОГДА:
  - Stage 1 закрыта на `/accept` NORTH-STAR + N × `segment-portrait.md` + `voice-of-customer.md` ≥ 5 цитат
  - Клиент явно просит: «соберём отчёт ментору» / «нужен HTML для презентации» / «упакуй ЦА визуально»
  - Авто-вызов в конце `/audience-stage` после Phase D, перед /accept Stage 1

  НЕ ИСПОЛЬЗОВАТЬ:
  - Stage 1 ещё не закрыта — Pre-flight БЛОКИРУЕТ, маршрут на `/audience-status`
  - Клиенту нужен текстовый сегмент-портрет, не HTML — это уже есть в `segment-portrait.md`
  - Пересборка после изменений — Алекс делает diff в `hypotheses.md`, после `/accept` повторно прогоняешь Phase E

triggers:
  - audience deliverable
  - собери отчёт по ЦА
  - HTML по ЦА
  - артефакт ментору
  - упакуй ЦА в HTML
  - отчёт по сегментам
  - визуализируй ЦА
  - phase e
---

# `/audience-deliverable` — Phase E пайплайна Stage 1

📍 **Где это в системе:**
- **Уровень:** Phase E из 4+1 пайплайна Stage 1 (Quick Capture → Internet Research → Validation → Awareness-lite → **Deliverable**)
- **Запускается из:** триггеров клиента после закрытия Stage 1, авто-вызова из `/audience-stage` после Phase D
- **Pre-flight БЛОКИРУЕТ если:** Stage 1 не закрыта (`/accept` на NORTH-STAR не выставлен), нет `voice-of-customer.md` ≥ 5 цитат, нет `segment-portrait.md` для ТОП-сегментов
- **Передаёт в:** `/unpack-product` (Stage 2) — после показа артефакта клиенту и его согласия двигаться дальше

> **Цель:** за 5-10 минут собрать интерактивный HTML-артефакт уровня «отчёт ментору / партнёру / инвестору». Без ручной правки — данные берутся из закрытых артефактов Stage 1, шаблон фиксированный, brand-палитра адаптируется под проект.

> **Маркетинговая логика:** клиенту нужен **визуальный** результат после 2-3 часов в чате — иначе ощущение «много говорили, ничего не сделали». HTML с цифрами, цитатами и карточками сегментов — материализованное доказательство что Stage 1 закрыта и можно идти дальше.

---

## 1. Pre-flight checks (БЛОКИРУЮЩИЕ)

```bash
PROJECT_ROOT="projects/<main>-audience"

# 1. /accept на NORTH-STAR
grep -i "/accept\|accepted: true" "$PROJECT_ROOT/audience/segments/NORTH-STAR.md" || {
  echo "❌ STOP: NORTH-STAR.md не закрыт на /accept. Запусти /audience-status — проверим что осталось."
  exit 1
}

# 2. Минимум 1 segment-portrait.md
N_PORTRAITS=$(ls "$PROJECT_ROOT/audience/segments"/*/segment-portrait.md 2>/dev/null | wc -l)
[ "$N_PORTRAITS" -lt 1 ] && {
  echo "❌ STOP: нет ни одного segment-portrait.md. Phase C (validation) ещё не пройден."
  exit 1
}

# 3. voice-of-customer.md с ≥5 цитатами
N_QUOTES=$(grep -c "^> " "$PROJECT_ROOT/audience/voice-of-customer.md" 2>/dev/null || echo 0)
[ "$N_QUOTES" -lt 5 ] && {
  echo "❌ STOP: voice-of-customer.md содержит $N_QUOTES цитат (нужно ≥5). Запусти /audience-stage Phase B для добивки."
  exit 1
}

# 4. Memory pre-flight (см. core.md)
grep -i "deliverable\|html" "$AGENT_HOME/failures.md" | tail -5
cat "$AGENT_HOME/memory.md" | grep -A3 "Active Projects"
```

**Если хоть один Pre-flight провалился** — STOP, вернуть клиенту понятным языком:

> *«Чтобы собрать отчёт, нужно сначала закрыть Stage 1: [что не хватает по конкретике]. Запускаю `/audience-status` чтобы посмотреть что есть.»*

---

## 2. Шаг 1 — Сборка JSON-данных из артефактов

Алекс открывает артефакты и собирает структуру для HTML:

```python
# Псевдокод — реальная сборка через Read + парсинг секций

deliverable_data = {
    "project": {
        "name": "<основной проект>",  # из projects/<main>/CLAUDE.md или client-profile.md
        "client": "<имя клиента>",
        "date": "<сегодня>",
    },
    "hero": {
        "n_segments": N,                    # количество сегментов в NORTH-STAR
        "n_pains": <count>,                 # суммарно по всем segment-portrait.md секция БПСВ
        "n_quotes": <count>,                # из voice-of-customer.md
        "n_competitors": <count>,           # из intel/competitors-*/INDEX.md
    },
    "strategy": {
        "why_these_segments": "...",        # из NORTH-STAR.md секция «Обоснование выбора»
        "rejected": [...],                  # из segments-map.md секция «Отвергнутые гипотезы»
        "backlog": [...],                   # из segments-map.md секция «Backlog»
    },
    "segments": [
        {
            "slug": "h-stuck-doer",
            "name": "Эксперт в потолке",
            "color": "🟢",                  # из segment-portrait.md цветовой схемы
            "awareness": "Solution-Aware",
            "main_pain_quote": "«дословная цитата»",
            "n_pains": 8,
            "n_desires": 5,
            "n_fears": 4,
            "n_objections": 6,
            "criteria": [...],
            "lingvo_categories": [
                {"name": "Якорь", "examples": ["...", "..."]},
                {"name": "Триггер", "examples": ["...", "..."]},
                # 5 категорий
            ],
            "voc_quotes": [
                {"text": "...", "source": "vc.ru", "tags": ["#pain"]},
                # топ-5 цитат с тегами
            ],
            "hero_formula": "...",          # из segment-core.md (только для hot)
            "dream_outcome": "...",         # из segment-core.md (только для hot)
            "anti_avatar": [...],           # 5 типов (только для hot)
        },
        # 1-3 сегмента
    ],
    "next_steps": {
        "stage_2_product": "Сборка Grand Slam Offer через 6 диалоговых протоколов Хормози",
        "first_test": "...",                # из NORTH-STAR.md «Тестовая гипотеза следующего шага»
        "risks": [...],                     # из NORTH-STAR.md секция «Risk Map»
    },
}
```

**Wayfinding для клиента:** *«Собираю данные из артефактов — секунду.»*

---

## 3. Шаг 2 — Чтение Brand Book (если есть)

```bash
BRAND_BOOK="knowledge/brand/<project>/brand-book.md"
if [ -f "$BRAND_BOOK" ]; then
  # Извлечь палитру (hex), шрифты (Google Fonts URLs), настроение
  PRIMARY=$(grep -i "primary\|основной" "$BRAND_BOOK" | grep -oE "#[0-9a-fA-F]{6}" | head -1)
  ACCENT=$(grep -i "accent\|акцент" "$BRAND_BOOK" | grep -oE "#[0-9a-fA-F]{6}" | head -1)
  BG=$(grep -i "background\|фон" "$BRAND_BOOK" | grep -oE "#[0-9a-fA-F]{6}" | head -1)
  FONT_HEAD=$(grep -i "Heading\|заголовк" "$BRAND_BOOK" | grep -oE "fonts.googleapis.com[^ )]*" | head -1)
  FONT_BODY=$(grep -i "Body\|текст" "$BRAND_BOOK" | grep -oE "fonts.googleapis.com[^ )]*" | head -1)
fi

# Fallback (если Brand Book нет): нейтральная Arctic Cold Light палитра
PRIMARY=${PRIMARY:-"#0B1220"}    # глубокий синий
ACCENT=${ACCENT:-"#22D3EE"}      # бирюза
BG=${BG:-"#F8FAFC"}              # почти белый
FONT_HEAD=${FONT_HEAD:-"https://fonts.googleapis.com/css2?family=Unbounded:wght@600;700"}
FONT_BODY=${FONT_BODY:-"https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600"}
```

**Wayfinding для клиента:** если Brand Book найден — *«Беру палитру и шрифты из твоего стиля»*; если нет — *«Brand Book не нашёл, использую нейтральную тёмную палитру. Если хочешь свою — скажи Дизайнеру собрать Brand Book, потом перезапустим эту фазу.»*

---

## 4. Шаг 3 — Сборка Claude Code артефакта

Скилл создаёт HTML-артефакт прямо в чате (Claude Code артефакт), пользователь видит результат справа в окне. Стек: **HTML + React + Tailwind + shadcn/ui** (без motion-эффектов чтобы артефакт открывался офлайн быстро).

### Структура HTML

```
1. Hero (выше fold)
   - Заголовок проекта + дата
   - 4 цифры в карточках: {N} сегментов | {M} болей | {K} цитат | {L} конкурентов
   - Sub-заголовок: «Stage 1 закрыта — фундамент для оффера и воронки»

2. Стратегия (1 экран)
   - Текст «почему эти сегменты» (из NORTH-STAR)
   - Список отвергнутых гипотез (краткое + 1 строка причина)
   - Backlog (если есть): 3-5 карточек

3. Карточки сегментов (1 экран на сегмент, 1-3 карточки)
   - Цветной заголовок (🟢/🟡/🟠/🔴) + название + awareness
   - Главная цитата боли (большим шрифтом, с источником)
   - Табы (shadcn Tabs):
     - Боли (список с тегами)
     - Желания
     - Страхи
     - Возражения
     - Критерии выбора
     - Lingvo (5 категорий: Якорь / Триггер / Метафора / Слово-Запрет / Слово-Включатель)
     - VoC (топ-5 цитат с источниками)
   - Для hot-сегмента: блок Hero-формулы + Dream Outcome + Anti-avatar (5 типов)

4. Voice of Customer карусель
   - Все цитаты в горизонтальном скролле
   - Каждая цитата = карточка с тегом + источником
   - Фильтр по тегам (#pain / #desire / #objection / #trigger)

5. Next Steps + Risk Map (низ)
   - Что дальше: Stage 2 Product (6 протоколов Хормози)
   - Первая тестовая гипотеза с оценкой confidence
   - Risk Map: 3-5 рисков + митигация
   - CTA-кнопка: «Согласовать Stage 1 закрытой → /accept»
```

### Технические требования к артефакту

- **One-page**, не SPA — открывается из файла без сервера
- **Tailwind CDN** + shadcn/ui компоненты (Tabs, Card, Badge, Carousel)
- **Inline JSON** — все данные внутри `<script id="data" type="application/json">…</script>`, чтобы файл был самодостаточный
- **Brand-палитра** через CSS variables `:root { --primary, --accent, --bg }`
- **Адаптивность** — mobile (1 col) / desktop (3 col для сегментов)
- **Без анимаций кроме hover** — открывается офлайн быстро, не «слайды»
- **Длина артефакта:** ~600-900 строк HTML+JS, не больше — иначе генерация займёт >2 минут

### Anti-slop guard

В промпт сборки артефакта обязательно встроить:

> *Запрещены: глянцевые стоковые улыбки, корпоративные иллюстрации, синие градиенты-голограммы, эмодзи в качестве иллюстраций, размытые «футуристичные» backgrounds, типографика «жирно курсивом подчёркнуто», карусели с автопрокруткой. Стиль: документальный, текст-первый, цифры в монохроме, цветной только акцент Brand Book, минимум декора.*

---

## 5. Шаг 4 — Output

```bash
OUTPUT_PATH="projects/<main>-audience/deliverable/audience-report.html"
mkdir -p "$(dirname "$OUTPUT_PATH")"
# Записываем артефакт в файл (через Write tool)

# Также копия в shared чтобы клиент мог быстро открыть
cp "$OUTPUT_PATH" "projects/<main>-audience/audience-report.html"
```

**Сообщение клиенту (живым языком):**

> *«Готово. Отчёт лежит в `<main>-audience/deliverable/audience-report.html` — открой в браузере, посмотри. Можешь скинуть ментору / партнёру — там всё что нужно для разговора: сегменты, цитаты, цифры, следующие шаги.
>
> Если что-то не так в подаче — скажи, перепакую. Если зашло — закрываю Stage 1 на /accept и идём в Stage 2 Product (оффер).»*

---

## 6. Шаг 5 — Update agent-state.md и memory.md

```yaml
# agent-state.md
active_skill: /audience-deliverable
active_step: completed
last_checkpoint: <now>
deliverable_path: projects/<main>-audience/deliverable/audience-report.html
```

```markdown
# memory.md — append в Decisions
## YYYY-MM-DD — Phase E собран для <client>
- N сегментов в карточках, K цитат в карусели, цвет primary <hex>
- Brand Book: <использован|fallback>
- Сообщение клиенту: «Скинь ментору, жду обратку»
```

---

## 7. Acceptance criteria

- [ ] Pre-flight пройден: NORTH-STAR /accepted, ≥1 segment-portrait, ≥5 цитат в voice-of-customer
- [ ] JSON-данные собраны из всех артефактов корректно (не «из головы»)
- [ ] Brand Book прочитан если есть, иначе fallback палитра использована и клиент уведомлён
- [ ] HTML-артефакт ≤900 строк, открывается офлайн, mobile-friendly
- [ ] Все цитаты в карусели имеют источник (`source:`)
- [ ] Anti-slop guard применён к промпту генерации
- [ ] Файл записан в `projects/<main>-audience/deliverable/audience-report.html`
- [ ] agent-state.md обновлён, memory.md дописан
- [ ] Сообщение клиенту живым языком, без жаргона, с CTA на /accept Stage 1

---

## 8. Связки

- ← `/audience-stage` Phase D финал (auto-call) или ручной триггер клиента
- ← Pre-flight gate из `/audience-status` (если клиент пытается запустить раньше времени)
- → `/unpack-product` (Stage 2) — после согласия клиента двигаться дальше
- ↔ Дизайнер — если Brand Book проекта собран через `/brand-onboarding`, скилл его читает; иначе предлагает клиенту запустить Дизайнера

---

## 9. Anti-patterns (НЕ делать)

- **HTML с motion-эффектами и параллаксом** — клиент шлёт ментору, тот открывает на телефоне в метро, артефакт не грузится. Документальный стиль > красота.
- **Цитаты без источника** — отчёт уровня ментора требует доказательств. Каждая цитата = `text + source + (tags)`.
- **Сегменты «общие»** — если у тебя нет конкретного segment-core для hot, не выдумывай Hero-формулу. Пиши «—» с пометкой «нужна Phase D углубление».
- **Brand Book галлюцинации** — если Brand Book не найден, не выдумывай палитру под «вкус клиента». Используй fallback и предложи Дизайнера.
- **Перезапуск без /accept нового NORTH-STAR** — если клиент попросил пересобрать, но артефакты Stage 1 не менялись — скажи «нечего пересобирать, артефакт уже актуальный».

---

## 10. Память

**Перед задачей:**
- `grep` по `failures.md` ключи: deliverable, html, артефакт, brand-book
- `memory.md` секция Context

**После задачи:**
- Append в `memory.md` Decisions: что собрали, какие сегменты, как клиент отреагировал
- Если ментор/партнёр прислал фидбек на отчёт — отдельный append в Patterns
- Если Brand Book не нашёлся и клиент после артефакта пошёл к Дизайнеру — append в Context

**Append-only.**
