---
name: audience-stage
description: |
  МЕТА-ОРКЕСТРАТОР Stage 1 (Audience) Internet-First пайплайна v2.0. Запускает 4 фазы
  последовательно: Phase A (`/audience-quick-capture`) → Phase B (`/audience-internet-research`)
  → Phase C (`/audience-validation`) × N сегментов → Phase D (`/audience-awareness-lite`)
  для hot-сегмента. Stop+wait между фазами, явный /accept от клиента на закрытие
  Stage 1 перед переходом в Stage 2 Product.

  ПРИНЦИП Internet-First: Алекс не выкачивает БПСВ из клиента. Он берёт минимальный
  контекст в Phase A, уходит в интернет за реальными данными в Phase B, валидирует
  с клиентом галочками в Phase C, добивает hot-сегмент в Phase D. Финальный artifact
  по жирности — как VoC «Эксперт в потолке» (30-50 валидированных болей дословно
  с источниками + лингво + метафоры + конкуренты с тарифами).

  КОГДА:
  - Старт нового проекта распаковки ЦА после выбора направления (такт 6 первого контакта)
  - Re-run после большого пивота (раз в 6+ месяцев)
  - Resume прерванной сессии через `/audience-resume`

  НЕ ИСПОЛЬЗОВАТЬ:
  - Если Stage 1 уже закрыта на /accept — это `/marketer-revision` (lite) или `/revise-segment`
  - Если нужна одна доработка на одном сегменте — `/segments-unpack` или `/revise-segment`

triggers:
  - audience stage
  - распакуй ЦА
  - распакуй аудиторию
  - сегментация
  - найди сегменты
  - старт распаковки
  - stage 1 audience
  - первая фаза распаковки
---
---

🎙 **ГОЛОС:** прочитай `knowledge/voice.md` ПЕРЕД любой репликой клиенту. Слова «Шаг», «Pre-flight», «AskUserQuestion», «Phase», «Stage Lock», «гейт», «trigger», «mode» — **внутренняя структура для тебя**, в речи клиенту **НЕ произносить**. Стиль = живой партнёр-маркетолог с насмотренностью, не методолог из учебника. Если хоть в одной реплике появилось «Шаг 1 / Phase A / Pre-flight / 4 вопроса по одному» — это робот. Перепиши.


# `/audience-stage` — Мета-оркестратор Stage 1 (Internet-First v2.0)

📍 **Где это в проекте:** Stage 1 из 4 (Audience → Product → Funnel → Brand).

> **Цель:** провести клиента через 4 фазы распаковки ЦА с минимальной активной нагрузкой (2-3 часа в чате) и максимальной фоновой работой Алекса (30-60 мин на сегмент в интернете). На выходе — закрытая Stage 1 с жирным `voice-of-segment.md` × N + `segment-portrait.md` × N + `segment-core.md` для hot.

> **Маркетинговая логика:** старый pipeline («выкачиваем БПСВ из клиента → потом валидируем») = 10-12 часов клиента в чате, 80% догадок. Новый pipeline = 2-3 часа клиента, 80% валидированных интернет-цитат. Это качественный сдвиг, не косметика.

---

## 1. Pre-flight checks (БЛОКИРУЮЩИЕ)

```bash
# 0a. ОНБОРДИНГ-ГЕЙТ — самым первым, до всего остального
ONBOARDING=$(grep -E "^onboarding_completed:\s*true" office/agents/alex-marketer/agent-state.md 2>/dev/null)
if [ -z "$ONBOARDING" ]; then
  # Онбординг не пройден — STOP, перенаправляем
  echo "❌ Онбординг Алекса не пройден. Перенаправляю на /alex-onboarding."
  echo "Реплика клиенту живым языком (НЕ упоминать «скилл», «правило», «гейт»):"
  echo "  «Никит, прежде чем начать распаковку, дай мне 5 минут вникнуть в твой офис"
  echo "   и понять куда тебе сейчас жирнее всего вкладывать силу. Я открою файлы,"
  echo "   посмотрю что у тебя живое — и вернусь с диагнозом и одним вопросом."
  echo "   Поехали?»"
  # → запустить /alex-onboarding
  exit 1
fi

# 0b. RESUME CHECK
[ -f "projects/<main>-audience/_state/pipeline-progress.md" ] && {
  cat _state/pipeline-progress.md
  ASK_USER "Сессия в процессе. Что делаем?"
  options:
    a) Продолжить с этого места → /audience-resume
    b) Начать заново (старая папка → _archive/) → продолжить ниже
    c) Завершить досрочно → отметить DONE в state
}

# 1. Определить main проект
projects=$(ls projects/ | grep -v "_template\|_example")
if [ ${#projects} -eq 1 ]; then
  main=$projects
else
  ASK_USER "по какому проекту распаковываем ЦА?"
fi

# 2. Проверить шаблон _template-audience
[ -f "projects/_template-audience/audience/INDEX.md" ] || STOP "Шаблон отсутствует. Эскалация — переустановить пак"

# 3. Hard Pre-flight памяти (см. core.md)
grep -i "{ключевые слова направления}" failures.md
cat memory.md | grep -A3 "Active Projects"
# Служебная строка в первой реплике (если N>0 OR M>0):
# «📚 Прочитал память: N failures, M decisions. Релевантно: [...]»

# 4. Найти diagnostic-card от Стратега
DIAG=""
[ -f "projects/<main>/audience/diagnostic-card.md" ] && DIAG="..."
[ -f "projects/<main>/diagnostic-card.md" ] && DIAG="..."
# Если есть — используем как starter в Phase A
```

**Wayfinding (обязательно в начале):**

> *«📍 Stage 1 (Audience) — распаковка ЦА. Запускаю Internet-First пайплайн v2.0:*
>
> *• Phase A — быстрый захват контекста (10-15 мин активно)*
> *• Phase B — я ухожу в интернет за реальными данными (30-60 мин фон, ты свободен)*
> *• Phase C — ты валидируешь жирный портрет галочками (15-25 мин активно × N сегментов)*
> *• Phase D — добивка hot-сегмента до материала для копирайтера (30-45 мин активно)*
>
> *Итого: 2-3 часа активной работы тебя в чате. На выходе — закрытая Stage 1 с финальным портретом для лендинга.*
>
> *Поехали?»*

**Stop+wait.** Без явного «да» — не запускаем.

---

## 2. Шаг 1 — Создать папку Stage 1

```bash
# Создать структуру из шаблона
cp -r projects/_template-audience/. projects/<main>-audience/

# Init pipeline-progress.md
cat > projects/<main>-audience/_state/pipeline-progress.md <<EOF
# Pipeline Progress — Stage 1 Audience

**Started:** $(date -Iseconds)
**Current phase:** A (Quick Capture)
**Mode:** TBD (auto-detect in Phase A)

## Phases
- [ ] Phase A — Quick Capture
- [ ] Phase B — Internet Deep Research
- [ ] Phase C — Validation Through Choices
- [ ] Phase D — Awareness Lite (hot only)

## Active state (для resume)
EOF

# Update agent-state.md
yq -i '.active_skill = "/audience-stage" | .active_phase = "A" | .active_project = "<main>" | .last_checkpoint = now' agent-state.md
```

⭐ **Если diagnostic-card от Стратега есть** — мигрируем starter-гипотезы в `audience/segments/hypotheses.md` (там их подхватит Phase A).

---

## 3. Шаг 2 — Phase A: Quick Context Capture

**Запуск:**

```
Skill: /audience-quick-capture
Context: <main> проект, diagnostic-card если есть, mode TBD
```

**Что Phase A делает (см. `/audience-quick-capture` SKILL.md):**
1. 6 тактов первого контакта (если ещё не сделано)
2. Запрос материалов из багажа клиента (6 категорий)
3. 4 ключевых вопроса по одному за раз
4. Формулирование 1-3 гипотез сегментов через AskUserQuestion
5. /accept клиента на гипотезы

**Output Phase A:**
- `inbox/_raw/` — материалы клиента
- `audience/segments/hypotheses.md` — 1-3 гипотезы с 3-circle-fit
- `agent-state.md` → `active_phase: A_completed → ready_for_B`

**Stop+wait** между Phase A и Phase B (короткое подтверждение клиента «поехали в разведку»).

---

## 4. Шаг 3 — Phase B: Internet Deep Research

**Запуск (для каждого target_segment из hypotheses.md):**

```
for slug in target_segments:
  Skill: /audience-internet-research
  Args: --segment={slug}
  Background: false (но 5 субагентов внутри запускаются параллельно через Task tool)
```

⭐ **Важно:** оркестратор `/audience-stage` НЕ запускает Phase B параллельно для разных сегментов — это перегруз WebSearch квот. **По одному сегменту за раз**, внутри сегмента — 5 субагентов параллельно.

**Что Phase B делает (см. `/audience-internet-research` SKILL.md):**
1. 5 параллельных субагентов: YouTube + Forums + Search + Competitors + БПСВ-синтезатор
2. Match-методика: VALIDATED / SIGNAL / HYPOTHESIS статусы
3. Финал: `voice-of-segment.md` × N с 30+ цитатами болей дословно

**Wayfinding во время Phase B:**

> *«🗺 Phase B запущена для {slug}. Я ушёл в интернет на 30-60 мин. Dashboard прогресса вижу в чате. Ты можешь отдохнуть, заняться своим, или скинуть ещё материалов в `inbox/_raw/`.»*

**Output Phase B (на каждый сегмент):**
- `intel/{slug}/voice-of-segment.md` — жирный артефакт
- `intel/{slug}/youtube-cuts.md`, `community-voc.md`, `search-queries.md`, `competitors-map.md`, `bpsv-patterns.md` — интермедиаты

**Stop+wait** после возврата всех сегментов: «Phase B закрыта. Готов к Phase C валидации?»

---

## 5. Шаг 4 — Phase C: Validation Through Choices (× N сегментов)

**Запуск (по очереди для каждого сегмента, не параллельно):**

```
for slug in target_segments:
  Skill: /audience-validation
  Args: --segment={slug}
  
  # После каждого сегмента — пауза для отдыха клиента
  if not last_segment:
    ASK_USER "Сегмент {slug} закрыт. Сразу к {next_slug} или паузу?"
```

**Что Phase C делает (см. `/audience-validation` SKILL.md):**
1. 7 мультиселектов через AskUserQuestion: боли / желания / возражения / лингво / метафоры / каналы / конкуренты
2. Цветовая схема 🟢 GOLD / 🟡 SIGNAL / 🟠 FROM CLIENT
3. Финал: `segment-portrait.md` × N

**Wayfinding между сегментами:**

> *«✅ Сегмент {slug} закрыт ({N} из {M}). На руках portrait с {X} GOLD-болями + {Y} SIGNAL.*
> *Дальше → сегмент {next_slug}? Или паузу? (рекомендую паузу 5-10 мин между сегментами — глаз замыливается)»*

**Output Phase C:**
- `audience/segments/{slug}/segment-portrait.md` × N (с цветовой схемой)
- `agent-state.md` → `active_phase: C_completed → ready_for_D` (если есть hot) или `→ ready_for_NORTH-STAR_accept` (если нет hot)

---

## 6. Шаг 5 — Phase D: Awareness Lite (только для hot)

⚠️ **Запускается ТОЛЬКО для hot-сегмента.** Warm/cold остаются на уровне Phase C — это достаточно для Stage 2.

**Если нет hot в hypotheses.md** (все warm/cold) — пропускаем Phase D, переходим к Шагу 6 NORTH-STAR.

**Запуск:**

```
hot_slug = $(yq '.hypotheses[] | select(.priority == "hot") | .slug' hypotheses.md)
Skill: /audience-awareness-lite
Args: --segment={hot_slug}
```

**Что Phase D делает (см. `/audience-awareness-lite` SKILL.md):**
1. Subagent-классификатор: цитаты → 4 уровня осознанности (L1-L4)
2. Lingvo по 4 правилам: якоря / триггеры / метафоры / антипаттерны
3. Dream Outcome (3-этапная сборка: кейс + голос эксперта + желания)
4. Anti-avatar (3-5 типов с дисквалификаторами)
5. Финал: `segment-core.md` для копирайтера

**Output Phase D:**
- `audience/segments/{hot_slug}/segment-core.md` — финальный сжатый артефакт
- Дополнения в `segment-portrait.md` (awareness + dream + anti-avatar секции)

---

## 7. Шаг 6 — NORTH-STAR + /accept Stage 1

После всех фаз → собрать `NORTH-STAR.md` из топ-3 (или сколько есть) сегментов:

```markdown
# NORTH-STAR — ТОП-сегменты Stage 1

> Stage 1 закрыта: YYYY-MM-DD HH:MM
> Mode: established | early-stage | greenfield
> Pipeline: A → B (5 субагентов) → C (7 мультиселектов) → D (hot only)

## ТОП сегменты (1-3, по приоритету)

### 🔥 {hot-slug} — {Имя hot-сегмента}
- voice-of-segment.md: ✅ ({X} GOLD цитат болей)
- segment-portrait.md: ✅
- segment-core.md: ✅ (готов для копирайтера)
- 5 must-use цитат для лендинга:
  1. ...

### 🔸 {warm-slug} — {Имя warm}
- voice-of-segment.md: ✅
- segment-portrait.md: ✅
- segment-core.md: ⏳ (опционально, не критично)

### ❄️ {cold-slug} — {Имя cold}
- voice-of-segment.md: ✅
- segment-portrait.md: ✅
- (Phase D не делалась — это warm/cold)

## Backlog (отложенные гипотезы)
- {имя} — {почему отложили}

## /accept Stage 1
status: PENDING_ACCEPT
accepted_by: null
accepted_at: null
```

**AskUserQuestion для финального /accept:**

```yaml
question: |
  📋 Stage 1 распаковка ЦА завершена. Готов закрыть на /accept?
  
  На руках:
  - {N} сегментов с жирными портретами
  - {M} GOLD-цитат болей дословно
  - segment-core.md для hot-сегмента (готов копирайтеру)
  - Готовность к Stage 2 Product

multiSelect: false
options:
  - id: accept
    label: "✅ /accept — Stage 1 закрыта, переходим в Stage 2 Product"
  - id: revise-hot
    label: "🔄 Доработать hot-сегмент через /revise-segment"
  - id: revise-other
    label: "🔄 Доработать warm/cold сегмент"
  - id: pause
    label: "⏸ Пауза — вернёмся через {неделю/месяц}"
```

**Если /accept** → пометить в NORTH-STAR.md `status: ACCEPTED, accepted_by: {client}, accepted_at: {date}` + предложить опциональный Phase E (HTML-артефакт для ментора).

---

## 8. Шаг 7 — Phase E (опционально): HTML-артефакт для ментора

**ASK_USER:**

> *«Stage 1 закрыта на /accept. Готов собрать финальный HTML-артефакт для отправки ментору на ревью? Это 5-10 минут, на выходе интерактивная страница со всеми сегментами.»*

Если да → `/audience-deliverable`. Если нет → переход в `/unpack-product` (Stage 2).

---

## 9. Output Stage 1 (что есть на руках после полного цикла)

```
projects/<main>-audience/
├── inbox/_raw/                              ← материалы клиента (Phase A)
├── audience/
│   ├── segments/
│   │   ├── NORTH-STAR.md                    ← топ + /accept маркер
│   │   ├── hypotheses.md                    ← все гипотезы + бэклог
│   │   └── {slug}/
│   │       ├── voice-of-segment.md          ← Phase B жирный
│   │       ├── segment-portrait.md          ← Phase C валидированный
│   │       └── segment-core.md              ← Phase D (только hot)
│   └── voice-of-customer.md                 ← общий VoC
├── intel/{slug}/                            ← Phase B интермедиаты
│   ├── youtube-cuts.md
│   ├── community-voc.md
│   ├── search-queries.md
│   ├── competitors-map.md
│   ├── bpsv-patterns.md
│   └── awareness-classification.md          ← Phase D интермедиат
├── _state/pipeline-progress.md
├── deliverable/audience-report.html         ← Phase E (если делали)
└── hypotheses.md                            ← рабочие гипотезы (≤7 тегов)
```

---

## 10. Acceptance Stage 1 closed

- [ ] Phase A: hypotheses.md с 1-3 гипотезами + /accept клиента
- [ ] Phase B: voice-of-segment.md × N с 30+ GOLD цитатами на сегмент
- [ ] Phase C: segment-portrait.md × N с цветовой схемой
- [ ] Phase D: segment-core.md для hot (с awareness + lingvo + dream + anti-avatar)
- [ ] NORTH-STAR.md содержит сегменты + /accept маркер от клиента
- [ ] agent-state.md: `stage_1_status: closed_with_accept`
- [ ] pipeline-progress.md: все фазы [x]
- [ ] (опционально) audience-report.html — Phase E собран

---

## 11. Anti-patterns

❌ **Запустить старые скиллы** (`/segments-discover`, `/segments-unpack`, `/segments-awareness`, `/segment-money-map`, `/segment-hypotheses`) напрямую — они в `_legacy/`, заменены на Phase A/B/C/D.

❌ **Запустить Phase B параллельно для 3 сегментов** — перегруз WebSearch квот. Один сегмент за раз.

❌ **Запустить Phase D для warm/cold** — overkill, тратится время. Phase D только для hot.

❌ **Перейти в Stage 2 без /accept на NORTH-STAR** — нарушение Stage Lock (см. `knowledge/stage-lock.md`).

❌ **Не показывать wayfinding между фазами** — клиент не понимает где он. Каждая фаза начинается с «📍 Phase X из 4» и заканчивается «✅ Phase X закрыта, дальше → Phase Y».

❌ **Произносить «Phase A/B/C/D» в чате** — жаргон. Клиенту: «быстрый захват → разведка интернета → валидация → углубление главного сегмента».

---

## 12. Связь с другими скиллами

- ⬅️ **Запускается** триггером «распакуй ЦА» / «найди сегменты» / «старт Stage 1»
- ⬅️ **Может быть запущен через** `/audience-resume` после `/clear`
- ➡️ **Вызывает** `/audience-quick-capture` (Phase A) → `/audience-internet-research` (Phase B) × N → `/audience-validation` (Phase C) × N → `/audience-awareness-lite` (Phase D, hot only) → `/audience-deliverable` (Phase E, опционально)
- ➡️ **После /accept Stage 1** — handoff в `/unpack-product` (Stage 2) с Pre-flight gate
- 📊 **Auto-call** `/audience-check` каждые 5 ходов между фазами
- 🔄 **`/audience-status`** для read-only проверки прогресса в любой момент

---

## 13. Память

**Перед задачей:**
- `grep` по `failures.md` на «Stage 1 / pipeline / phase»
- Прочитать `memory.md` Active Projects: этот клиент был раньше? В каком mode?

**После каждой фазы:**
- Append в `memory.md` Decisions: что закрыли, какой mode, какой hot, время фазы (для будущих оценок)
- Patterns: типичные lingvo / каналы / конкуренты в нише (если 3+ клиентов в такой нише прошли Stage 1)
- Если фейл (фаза вернула partial / клиент сорвался) → `failures.md`

**После /accept Stage 1:**
- В memory.md секция «Active Projects» обновить: `<main>: Stage 1 closed YYYY-MM-DD, hot={slug}, ready for Stage 2`
