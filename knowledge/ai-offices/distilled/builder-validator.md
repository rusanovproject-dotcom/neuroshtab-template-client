---
title: Builder + Validator — паттерн Writer/Reviewer
updated: 2026-05-05
source_research: 2026-05-04-office-architecture
status: live
---

# Builder + Validator — паттерн Writer/Reviewer

> Дистиллят по паттерну ревью: когда обязателен независимый ревьюер, как организовать, score gates, dogfooding. Читать ПЕРЕД любой задачей где результат планируешь отдавать дальше.

Главная мысль: **автор слеп.** Кто построил — не может честно проверить. Нужен независимый ревьюер с чистым контекстом и без write-доступа. Self-validation систематически завышает оценку на ~20%.

---

## 1. Главное правило

**Builder** строит фичу/артефакт со всеми инструментами.
**Validator** — read-only (`tools: Read, Grep, Glob` в frontmatter), проверяет.

Validator без write-доступа = честная QA. Если он не может «незаметно починить» — он становится честным проверяющим, не пытается прикрыть свои находки.

**Цитата-якорь** (Disler `research/01-youtube-research.md:339`):

> *«Subagents без write-доступа = quality assurance pattern. Validator не может фиксить, только репортить — это превращает его в честного проверяющего.»*

---

## 2. Реальный кейс: Демиург 92 → 74

В этом самом исследовании (`research/08-reviewer-report.md:475`):

> *«Demiurg выставил себе self-score 92/100. Реальный — 74/100 после независимого ревью. Дельта 18 пунктов. Завышение системное — Demiurg смотрел изнутри пака, не на пересечение с шаблоном (P0-1, P0-3). Self-review не заменяет independent review.»*

**Что Demiurg пропустил при self-review:**

1. **Trigger collision сам с собой.** Установка пака `architect-of-order` добавляла триггеры «проверь офис», «наведи порядок» — но они уже заняты `/audit-project` Демиурга. Routing Validator (M3 самого нового агента) при первом же запуске сфейлил бы свой агент.
2. **first_task block отсутствует** в install.md — install-agent скилл не сможет дать CTA.
3. **README hyperbole + дубль 6/7 модулей** — терминологическая каша между core.md (6 модулей) и knowledge/7-modules.md (7 модулей). Demiurg бы поймал это в M5 Knowledge Dedup на собственных файлах если бы запустил dogfooding.
4. **`.env` defense только prompt** — Demiurg сам себе записал «нужен fix install.md», но fix не сделал. Validate → Iterate цикл оборван.

**Главный урок:** *«Demiurg прошёл всё своё validation pipeline, но не сделал dogfooding — не запустил `/office-architect scan` на собственном паке. Это бы поймало P0-1 (trigger collision) и P0-4 (heading collision Module 7) в первый же прогон.»*

---

## 3. Когда Builder/Validator обязателен

| Артефакт | Объём | Триггер | Validator |
|----------|-------|---------|-----------|
| Код | > 50 строк или Tier 1-3 | merge / PR | `compound-engineering:review:correctness-reviewer` + `maintainability-reviewer` параллельно |
| Продающий артефакт (КП, лендинг, оффер, лонгрид, презентация) | любой | перед отправкой | `equalizer` (жирность оффера) или `review-longread` (скилл) |
| Стратегический документ | методология / концепция / план запуска / спек | перед раздачей | `compound-engineering:document-review` или адверсарный reviewer |
| Агент / скилл | любой | после `/build`, до WIRE | `agent-quality-reviewer` (скилл) + smoke-test |
| JTBD-анализ | любой | финал распаковки ЦА | `/jtbd-critic` (новый чат, чистый контекст) |
| Аудит офиса | любой | перед mutation | independent reviewer перед `tidy`/`deep` |
| Критичный бот / скрипт | деплой / миграция / автоматизация клиентов | перед prod | smoke-test + LLM Validator |

**Когда НЕ нужен.**
- Мелкая правка (< 50 строк, один файл).
- Ответ на вопрос без артефакта.
- Research/discovery (там другой паттерн — параллельные субагенты).
- Если пользователь явно пишет «без ревью» / «быстро» / «набросай» — флаг `--no-review`.

---

## 4. Как организовать — 2-3 субагента

**Минимальная схема (2 агента):**

```
Builder (writer)         Validator (reviewer, read-only)
   │                              │
   ↓ создаёт артефакт              ↓ читает + проверяет
   draft.md  ────────────────►   review-report.md
                                   │
                                   ↓ возвращает
                                  Builder (refine)
                                   │
                                   ↓ финал
                                  artifact.md
```

**Расширенная (3 агента):**

```
Writer → Validator → Refiner
            │
            └── findings.md
```

**Refiner** — отдельный агент который применяет findings от Validator'а. Полезно если Builder сам не видит свои проблемы (cognitive bias).

---

## 5. Score gates — единый язык оценок

Из demiurg pipeline (`research/03-internal-knowledge.md:457`):

| Score | Решение | Что делать |
|-------|---------|------------|
| **<60 FAIL** | Не отдавать. Пересборка. | Вернуться к BUILD или KNOWLEDGE-фазе |
| **60-79 NEEDS WORK** | Max 2 итерации iterate. | Validator даёт diff-список fix'ов |
| **≥80 PASS** | Идёт в WIRE / прод | Финальная фиксация |

**Stop-кран.** 2 раунда iterate без роста score — STOP, не долбить. Анти-паттерн «давай ещё одну попытку» приводит к loop. Если 2 итерации не подняли — фундамент сломан, иди обратно в KNOWLEDGE / BRIEF.

**Цитата** (Anthropic про iteration limits): *«rewind proves more effective than sequential correction messages»* — после 2 фейлов лучше откатиться к точке X и подойти иначе, чем долбить корректирующими промптами.

---

## 6. Промпт ревьюеру — ключевая часть

Ревьюер должен:
1. **Найти слабые места, противоречия, дыры — не хвалить.** Если ревьюер хвалит — он плохой ревьюер. Бронебойный реакция: *«где ты увидел проблему?»*
2. **Структурированный фидбек:** жёсткие проблемы → средние → мелкие.
3. **Прямые цитаты + file:line** для каждого findings'а. Без citation — finding unfalsifiable, не зафиксят.

**Шаблон промпта ревьюеру:**

```
Это [артефакт] для [целевой аудитории].
Должен решать [задача].
Найди слабые места, противоречия, дыры.
НЕ хвали. Если плохо — скажи.

Верни в формате:
## P0 — нельзя отдавать
[file:line]: проблема, почему критично, как фиксить

## P1 — серьёзные не блокеры
...

## P2 — улучшения качества
...
```

**Anti-pattern.** Промпт «оцени артефакт». Ревьюер вернёт «всё хорошо». Из-за того что нет инструкции искать — ищет одобрение.

---

## 7. 7 параллельных reviewers — Compound Engineering паттерн

`compound-engineering/document-review` от Every.to (`research/04-governance-cleanup-agents.md:271`):

> *«7 параллельных reviewer-агентов. Всегда запускаются 2 core: coherence-reviewer + feasibility-reviewer. Условно добавляются 5 на основе сигналов в документе:*
> - product-lens-reviewer — если есть claims о том «что строить»
> - design-lens-reviewer — если упомянуты UI/UX
> - security-lens-reviewer — если auth/APIs/sensitive data
> - scope-guardian-reviewer — если есть priority tiers
> - adversarial-document-reviewer — для high-stakes доменов*»

**Findings → 3 класса:**
1. **«One clear correct fix»** — auto-applied (например, frontmatter правки, datestamps).
2. **«Requires judgment»** — presented to user.
3. **«Strategic question»** — to user decision.

**Зачем параллельно.** Каждая персона = свои слепые пятна. Один ревьюер ловит coherence (логика), другой feasibility (выполнимость), третий security. Объединение findings даёт полное покрытие. И параллелизм = быстро.

---

## 8. Idempotency check — защита от loop

После каждой итерации — проверка:

> *«Если запустить ещё раз с теми же входными данными — выдаст ли тот же результат?»*

Если **да** — можно идти дальше, validator стабилизировался.
Если **нет** — у validator'а недетерминированное поведение, нельзя доверять score.

**Anti-pattern в Architect-of-Order** (`research/08-reviewer-report.md:217`):

> *«Idempotency check читает только last audit того же режима за сегодня. Если запуск через 3 дня — сравнения не будет. И midnight rollover ломает: запустил 23:55, повторно 00:05 через 10 минут — даты разные, отчёт fresh.»*

Решение: читать **последний** отчёт того же режима независимо от даты.

---

## 9. Dogfooding — ОБЯЗАТЕЛЬНО для инспекционных агентов

**Главное правило:** любой агент-инспектор сначала прогоняет себя.

Architect-of-Order должен запустить `/office-architect scan` на собственном паке ДО того как его раздавать.

В этом исследовании Demiurg **не сделал dogfooding** (`research/08-reviewer-report.md:476`):

> *«Demiurg прошёл всё своё validation pipeline, но не сделал dogfooding — не запустил /office-architect scan на собственном паке. Один прогон поймал бы 2 из 4 P0 сразу. Любой агент-инспектор должен сначала прогнать себя.»*

**Будущим итерациям `/build`** — добавить **Phase 9 Dogfooding** для агентов которые могут проверить сами себя. Пример: Architect-of-Order, /audit-project, agent-quality-reviewer.

---

## 10. Smoke-test — ручная проверка

После Validator PASS — обязателен smoke-test.

Из ревью Architect-of-Order (`research/08-reviewer-report.md:309-355`) — пошаговый сценарий первого запуска:

1. Свежий клон шаблона + `/setup`.
2. Пользователь: «привет, проверь офис».
3. Director смотрит routing-patterns.md → нет ли collision триггеров?
4. Architect запускает Phase 1 Inventory bash.
5. Phase 2 — каждый из 6 модулей.
6. Phase 3 — формат отчёта правильный? Включает «Looks bad but is actually fine»?
7. Phase 4 — approval gate работает?
8. Phase 5 — memory update?

Если в любом шаге **дырка** (false positive, collision, формат неправильный, approval gate пропускает mutation) — это P0/P1 finding для следующей итерации.

---

## 11. Reviewer должен быть в чистом контексте

**Главное правило для критичных артефактов** (JTBD-анализ, оффер, стратегия):

> *«Запускать reviewer'а в НОВОМ чате — свежий взгляд, чистый контекст.»*

Зачем. Если reviewer работает в той же сессии что Builder — он видит весь builder process и подсознательно соглашается с ходом мыслей. Он не оспаривает фундамент потому что «уже обсуждали».

В новом чате reviewer:
- Не знает что предыдущие гипотезы уже отвергнуты.
- Не знает что у Builder'а был трудный день.
- Видит только конечный артефакт + промпт «найди дыры».

В нашем шаблоне это уже паттерн `/jtbd-critic` (`research/04-governance-cleanup-agents.md:271` style).

---

## 12. AI-слоп / наполнители — отдельная категория

Из ревью (`research/08-reviewer-report.md:25`):

> *«F. AI-слоп / наполнители. Дубли между core/soul/knowledge — это форма наполнителя; README завышен по самооценке.»*

**Что искать:**
- **Дубли контента** между файлами (core ↔ soul ↔ knowledge ↔ SKILL).
- **Hyperbole без citation** («устаканилось как канон», «революционно»).
- **AI-фразы** — «инновационный», «синергия», «парадигма», «exhaustive», «leverage».
- **Recap кода** который ревьюер «прочитал».
- **Восклицательные** «Отлично!», «Замечательно!».

См. `distilled/failures-to-avoid.md` секцию «AI-слоп».

---

## 13. Workflow в Workspace (пример)

Из Workspace CLAUDE.md (`/Users/macbookpro132017/workspace/.claude/CLAUDE.md`):

> *«Любой значимый артефакт проходит 2 фазы в РАЗНЫХ контекстах:*
> 1. **Writer** — ты (или субагент) пишешь первую версию
> 2. **Reviewer** — отдельный субагент с ЧИСТЫМ контекстом ревьюит
> 3. **Ты** синтезируешь фидбек, докручиваешь, показываешь пользователю»*

**Триггеры — когда включать автоматически:**
- Код > 50 строк или Tier 1-3
- Продающий материал
- Стратегический документ
- Критичный бот/скрипт

**Флаг `--no-review`** — если пользователь явно пишет «без ревью» / «быстро» / «набросай».

**Промпт ревьюеру всегда содержит:**
- Что это за артефакт и для кого.
- Какую задачу должен решать.
- Просьба найти слабые места — не хвалить.
- Вернуть структурированный фидбек.

---

## 14. Цитаты-якоря

- Disler: *«Validator без write-доступа = честная QA.»* (`research/01-youtube-research.md:339`)
- Anthropic про iteration: *«rewind proves more effective than sequential correction messages.»*
- Reviewer report: *«Demiurg систематически завышал на ~20 пунктов из-за слепых пятен self-review.»* (`research/08-reviewer-report.md:426`)
- Reviewer report: *«Любой агент-инспектор должен сначала прогнать себя.»* (`research/08-reviewer-report.md:476`)
- Addy Osmani: *«Trust cannot be assumed: 'The bottleneck is no longer generation. It's verification.'»* (`research/02-forums-communities.md:326`)

---

## Источники

- `research/2026-05-04-office-architecture/01-youtube-research.md:310-340` — Disler Builder/Validator
- `research/2026-05-04-office-architecture/02-forums-communities.md:316-353` — governance / verification
- `research/2026-05-04-office-architecture/04-governance-cleanup-agents.md:271-296` — Compound document-review
- `research/2026-05-04-office-architecture/08-reviewer-report.md` — кейс Demiurg 92→74
- `research/2026-05-04-office-architecture/03-internal-knowledge.md:457` — score gates
- `/Users/macbookpro132017/workspace/.claude/CLAUDE.md` — Writer/Reviewer протокол

## Связанные дистилляты

- `distilled/10-principles.md` — принцип 6
- `distilled/agent-design.md` — Builder/Validator пары
- `distilled/governance-cleanup.md` — Architect-of-Order (тот самый кейс)
- `distilled/failures-to-avoid.md` — self-validation, AI-слоп
