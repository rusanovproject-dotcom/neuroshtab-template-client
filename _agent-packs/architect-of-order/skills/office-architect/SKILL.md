---
name: office-architect
description: |
  Архитектор-Порядка офиса. Главная точка входа: scan (5 мин read-only inventory),
  tidy (15 мин soft-fixes под approval), deep (60 мин полный аудит по 6 архетипам
  уборщиков + 8-мерной Florian-rubric). Не делает контентную работу — только
  следит за порядком в структуре, памяти, роутинге, knowledge.

  TRIGGERS: "наведи порядок", "проверь офис", "office audit", "что не так с офисом",
  "почистим офис", "ревизия офиса", "стало мусорно", "почему офис тормозит",
  "архитектор офиса", "смотритель", "/office-architect", "/architect-scan",
  "/architect-tidy", "/architect-deep"

  ANTI-TRIGGERS: "новый агент" / "собери помощника" → /build (Демиург);
  "настрой офис первый раз" → /setup;
  "обнови офис" → /update-office;
  пользователь работает над Tier 1 задачей и не просил аудит → не отвлекать;
  uncommitted changes в git → попросить зафиксировать сначала.

  OUTPUT: office/ops/audits/YYYY-MM-DD-<mode>.md (новый файл за дату-режим).
disable-model-invocation: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(ls *)
  - Bash(find *)
  - Bash(wc *)
  - Bash(grep *)
  - Bash(head *)
  - Bash(tail *)
  - Bash(cat *)
  - Bash(jq *)
  - Bash(git log *)
  - Bash(git status)
  - Bash(git diff *)
  - TodoWrite
  - Edit
effort: high
---

# /office-architect — Универсальный аудит и чистка AI-офиса

Архитектор офиса смотрит на готовый офис и выдаёт диагностический отчёт по 6 направлениям. Что хорошо, что плохо, что средне. Дальше — план улучшений с приоритизацией.

**Принцип:** не громи. Цель — **аккуратно прокачивать**, не ломать. Каждое улучшение должно делать офис **проще** для пользователя, не сложнее.

---

## Когда запускать

| Триггер пользователя | Действие | Режим по умолчанию |
|----------------------|----------|-------------------|
| «проверь офис», «наведи порядок» | Запускай | **scan** |
| «что не так с офисом», «полный аудит» | Запускай | **deep** |
| «почистим офис», «лёгкая чистка» | Запускай | **tidy** |
| После установки нового пака (Demiurg вызвал как Quality Gate) | Запускай | **scan** |
| Минорная правка одного файла пользователем | НЕ нужен | — |
| Стратегическое решение по офису | НЕ нужен → `/interview` | — |

**Антитриггеры (анти-паттерны запуска):**
- Пользователь делает Tier 1 / Tier 2 — не лезть. Спроси: *«Сейчас проверю или дождаться когда закончишь с [текущая задача]?»*
- В git uncommitted changes — попроси зафиксировать. Аудит на грязной рабочей копии = ложные finding'и про «дрейф».
- Сессия только началась (<5 сообщений) и нет явного «проверь офис» — не предполагай.

---

## Аргументы

```
/office-architect [mode] [path]

mode (опц):
  scan         — 5 мин, read-only (DEFAULT)
  tidy         — 15 мин, soft-fixes под approval
  deep         — 60 мин, полный аудит + Florian-rubric

path (опц):
  default      — текущий офис (.)
  client-office-template  — для разработки самого шаблона
  /path/to/office         — конкретный путь
```

Примеры:
- `/office-architect` → scan текущего офиса
- `/office-architect tidy` → лёгкая чистка
- `/office-architect deep client-office-template` → полный аудит шаблона

---

## Pipeline (5 фаз)

Все 3 режима проходят 5 фаз. Различаются только глубиной архетипов и наличием Phase 4 mutation.

### Phase 1 — Inventory (≤30 секунд, bash-only)

Собираем структурную карту через **метаданные**, не читая содержимое (защита от cleanup-induced context pollution).

```bash
# Структура офиса
ls -la office/agents/ 2>/dev/null
find office/agents -maxdepth 2 -name "core.md" -exec wc -l {} \; 2>/dev/null
find office/agents -maxdepth 3 -name "memory.md" -exec wc -l {} \; 2>/dev/null
find office/agents -maxdepth 3 -name "failures.md" -exec wc -l {} \; 2>/dev/null
find office/agents -maxdepth 3 -name "soul.md" -exec wc -l {} \; 2>/dev/null

# Скиллы
find .claude/skills -maxdepth 3 -name "SKILL.md" -exec wc -l {} \; 2>/dev/null
find office/agents -maxdepth 4 -path '*/skills/*/SKILL.md' -exec wc -l {} \; 2>/dev/null

# Knowledge
find knowledge -maxdepth 4 -name "*.md" -type f 2>/dev/null | head -100
find knowledge -maxdepth 2 -name "INDEX.md" 2>/dev/null

# Config & hooks
ls -la .claude/ 2>/dev/null
test -f .claude/settings.json && echo "settings.json: exists" || echo "settings.json: MISSING"
test -f .claude/.mcp.json && echo ".mcp.json: exists" || echo ".mcp.json: MISSING"
test -d .claude/hooks && echo "hooks: exists" || echo "hooks: MISSING"

# Protocols
find office/protocols -maxdepth 2 -name "*.md" 2>/dev/null

# Git status
git status --short 2>/dev/null | head -10
git log --oneline -5 2>/dev/null

# Symlinks (защита от false positives на дубликаты)
find office -maxdepth 3 -type l 2>/dev/null

# Плейсхолдеры (детектим P0-7)
grep -rln '{{[A-Z_][A-Z_0-9]*}}' . --include="*.md" 2>/dev/null | head -10

# Hardcoded secrets prelim (для Skill Auditor M2)
grep -rln -E '(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{20,}|xox[baprs]-)' . --include="*.md" --include="*.json" 2>/dev/null | head -5
```

**Сохрани результат в TodoWrite как baseline.** На этом этапе никаких выводов — только сбор фактов.

### Phase 2 — Dimension Audit

Зависит от режима:

#### scan (5 мин wall clock cap)

Surface-уровень всех 6 архетипов уборщиков. Только critical findings (P0). Тулы: `Read` (только метаданные через wc/head), `Grep`, `Glob`. Никаких `Edit`.

**Минимальный прогон:**
- M3 Routing: orphan agents, missing @include в CLAUDE.md, broken `/<skill>` references
- M4 Structure: отсутствие settings.json/.mcp.json/hooks/, плейсхолдеры в репо, неправильный `client-profile.md`
- M2 Skill Auditor: hardcoded secrets, oversize core.md (>300 строк), отсутствие frontmatter
- M6 Failure Detector: все `failures.md` пусты при работающем офисе >7 дней

Остальные архетипы — отметить «не запускался в scan-режиме, для полного запусти `/office-architect deep`».

#### tidy (15 мин cap)

scan + детальный M1 (Memory Cleaner) + M4 (Structure Linter) + готовность soft-fixes.

**Дополнительно:**
- M1 — детектируем contradictions, redundancy, stale timestamps
- M4 — детально по PARA, INDEX.md, symlinks
- Phase 4 включается — собираем top-3 quick wins для approval

**Soft-fixes доступные в tidy:**
- Frontmatter: `updated:` дата, недостающие поля `description:` / `name:`
- Stale timestamps: `yesterday` / `last week` → ISO YYYY-MM-DD (по контексту, спрашивая)
- Move в `_archive/<YYYY-MM-DD>/` для устаревших файлов (после approval)

**Никогда не делает в tidy** (для этого нужен deep + manual):
- Правка тела core.md / soul.md / memory.md (только metadata)
- Удаление файлов
- Изменение routing-patterns.md или AGENTS.md

#### deep (60 мин cap)

Все 6 архетипов уборщиков детально + 8-мерная Florian-rubric (финальная сборка с расчётом score 0-100).

**Дополнительно к tidy:**
- M5 Knowledge Dedup — Jaccard на heading sets всех пар knowledge-файлов
- M6 Failure Pattern Detector — группировка failures.md за 30 дней, поиск повторяющихся правил
- 8-мерная rubric → score по каждой dimension с обоснованием
- Предложения правил в `core.md` агентов (если 3+ повторов в failures)

#### Citation rule (закон во всех режимах)

Каждое finding должно иметь `file:line` или `file` если применимо к файлу целиком. Без citation → не finding.

#### Read code before judging it (закон)

Если паттерн «выглядит плохо» в одном месте — проверь не load-bearing ли он. Например:
- Длинный `failures.md` — это feature (append-only), не bug
- Symlink между папками — может быть фундамент, не дубль
- `prework.md` с YAML-frontmatter но пустыми ответами — это template для пользователя, не полузаполнение
- `_archive/*` папки с дублями файлов — намеренно, история

### Phase 3 — Unified Report

Структура (фиксированная — никаких свободных эссе):

```markdown
# Office Audit — YYYY-MM-DD (mode: scan|tidy|deep)

## Executive Summary

Total Score: XX/100 — [Starter | Growing | Established | Optimized]
Detected: N agents, M skills, K knowledge cards, L protocols
Mode: <режим>
Time spent: X min (cap: 5|15|60)

Top 3 Quick Wins:
- ...
- ...
- ...

Top 3 Critical Gaps:
1. ❌ ...
2. ⚠️ ...
3. ⚠️ ...

## Dimension Scorecard

| # | Dimension | Score | Max | Notes |
|---|-----------|-------|-----|-------|
| 1 | Memory & Context | X | 20 | ... |
| 2 | Memory Hygiene | X | 15 | ... |
| 3 | Routing & Skills | X | 15 | ... |
| 4 | Hooks & Settings | X | 10 | ... |
| 5 | Identity & Voice | X | 10 | ... |
| 6 | Knowledge Hygiene | X | 10 | ... |
| 7 | Freshness | X | 10 | ... |
| 8 | Security Posture | X | 10 | ... |
| **Total** | — | **XX** | **100** | <Tier> |

## Detailed Findings

### Module 1 — Memory Cleaner
**Finding M1.1 — Contradiction**
Files: office/agents/<name>/memory.md:42 vs :118
Issue: «Stage 1 закрыта при 3 цитатах» (line 42) vs «требуется ≥5 цитат» (line 118)
Impact: Агент не знает какому правилу верить
Fix: Объединить в один блок с датой 2026-05-04, выбрать актуальное
Severity: P1

(архетипы M2-M6 аналогично)

## Looks bad but is actually fine

ОБЯЗАТЕЛЬНАЯ секция (защита от cleanup'а load-bearing patterns).
Если секция пустая — отчёт FAIL, не сохраняется.

- failures.md каждого агента >300 строк — намеренно append-only, фича
- Symlink office/ → ai-office-v2/office/ (если существует) — фундамент архитектуры
- prework.md с YAML-frontmatter — template для setup, не полузаполнение
- (минимум 2-3 примера load-bearing patterns)

## Next Actions

apply top 3? (да / только важное / "1,3" / нет)
```

**Если режим = scan**, секция Next Actions меняется на:
> *«Это разведка. Если хочешь чтобы я что-то починил — скажи "почистим" (легкая чистка под approval) или "полный аудит" (всё подробно).»*

### Phase 4 — Validation Request (только tidy / deep)

В `scan`-режиме — пропускаем, только показываем отчёт.

В `tidy` / `deep` — после отчёта вопрос пользователю:

> *Что применить?*
> *— **да** — все top-3 quick wins сразу*
> *— **только важное** — только critical gaps (P0)*
> *— **"1,3"** — конкретные пункты по номерам*
> *— **нет** — оставить отчёт, ничего не трогать*

**Никаких mutation без явного ответа из этого списка.** Если ответ непонятный — переспроси, не предполагай. Если пользователь говорит «давай» / «ок» / «вперёд» без выбора — переспроси: *«Ты про "да" (все 3) или "только важное" (только P0)?»*

**Auto-fix только для one-clear-correct-fix:**
- frontmatter правки (`updated:` дата, недостающее поле)
- relative timestamps → ISO в memory.md
- перенос файла в `_archive/<YYYY-MM-DD>/` (move, не delete)

**Никогда auto-fix:**
- Тело `core.md` / `soul.md` агентов — только рекомендация
- Содержимое `memory.md` / `failures.md` — только append, не редактирование старого
- Удаление файла — только move
- `.env`, `.env.*`, `*.pem`, `credentials*`, `secrets*` — двойная защита

### Phase 5 — Memory Update

После cycle (даже если в Phase 4 было `нет`):

1. **Append в `office/agents/architect-of-order/memory.md`** под секции:
   - **Decisions** — какие правила применил, почему
   - **Patterns** — что заметил в этом офисе («пользователь любит когда findings со score»)
   - **Context** — что помнить о специфике (PARA, symlinks, особые файлы)

2. **Если что-то пошло не так** (over-cleaned, не заметил dup, missed collision) → append в `failures.md` по формату:
   ```
   YYYY-MM-DD → что предположил → что оказалось → правило на будущее
   ```

3. **Сохрани отчёт** в `office/ops/audits/YYYY-MM-DD-<mode>.md`. Если файл за сегодня уже есть — добавь суффикс: `2026-05-04-deep-2.md`.

4. **Idempotency check.** Если вчерашний отчёт того же режима имеет идентичные findings → добавь в текущий отчёт строку:
   > `## Note: idempotent — same findings as YYYY-MM-DD audit. No new issues since last run.`

---

## Файлы — что Архитектор пишет / не трогает

**Пишет:**
- `office/ops/audits/YYYY-MM-DD-<mode>.md` (всегда, новый файл за дату-режим)
- `office/agents/architect-of-order/memory.md` (append после задачи)
- `office/agents/architect-of-order/failures.md` (append при фейле)

**В tidy после approval:**
- frontmatter в `office/agents/*/core.md`, `.claude/skills/*/SKILL.md`
- datestamp в `memory.md` (relative → ISO)
- move в `_archive/<YYYY-MM-DD>/`

**НИКОГДА не трогает:**
- `.env`, `.env.*`, `.env.example`
- `*.pem`, `credentials*`, `secrets*`
- `_archive/*` (история, read-only логически)
- Untracked changes в git (попроси `git add`)
- Тело `core.md` / `soul.md` агентов (только рекомендации в отчёте)
- `overrides.md` любого агента (персональные данные пользователя)
- `office/strategy/*` (Strategist owner)

---

## Self-check (перед отдачей отчёта)

- [ ] Все 6 архетипов уборщиков запущены (scan: surface, tidy/deep: детально)
- [ ] Каждое finding имеет `file:line` citation
- [ ] Секция «Looks bad but is actually fine» НЕ пуста (минимум 2-3 примера)
- [ ] Top 3 Quick Wins имеют estimate времени
- [ ] Top 3 Critical Gaps имеют severity (P0/P1/P2)
- [ ] Dimension Scorecard собран (все 8 строк)
- [ ] Total Score соответствует tier'у (Starter <40, Growing 40-59, Established 60-79, Optimized 80+)
- [ ] Не превысил time cap (5/15/60 мин)
- [ ] Не предложил трогать `.env*` / secrets / `_archive/`
- [ ] Phase 4 — спросил approval (только в tidy/deep)
- [ ] Phase 5 — записал в memory.md и сохранил отчёт

---

## Anti-patterns (как НЕ аудитить)

| Анти-паттерн | Почему плохо |
|--------------|--------------|
| Громить всё что не идеально | Пользователь получит 200-пунктовый список и забьёт. Цель — аккуратная прокачка |
| Применять dev-критерии к контентному офису | Не требуй «test coverage» от Copywriter'а — глупо |
| Не учитывать что офис growing | Молодой офис ≠ зрелый. P2 для зрелого = P1 для молодого |
| Игнорировать «работает но некрасиво» | Если работает — оставь. Прокачка только если есть **реальная** боль |
| Скоринг без обоснования | «Хорошо» не оценка. 0-100 баллов с обоснованием по dimensions |
| Auto-fix без approval в tidy | Закон: Phase 4 yes/«только важное»/«1,3»/нет. Без явного ответа — стоп |
| Predict вместо инвентаризации | Phase 1 — facts only. Никаких «предположу что у вас есть» |
| Игнорировать «Looks bad but is actually fine» | Если секция пуста — не задумался про load-bearing. Отчёт FAIL |
| Mutation на untracked changes | Аудит на грязной рабочей копии = ложные дрейф-finding'и. Попроси `git add` сначала |
| Запускать каждый день | Перебор. Раз в 1-4 недели норма. Если чаще — что-то не так |

---

## Пример Input → Output

**Input:** `/office-architect deep`

```
→ Phase 1 (28 секунд):
  Detected: 5 agents (director, strategist, demiurg, designer, alex-marketer),
            18 skills, 23 knowledge cards, 1 protocol (INBOX.md only)
  settings.json: MISSING
  .mcp.json: MISSING
  hooks: MISSING
  Плейсхолдеры найдены в 3 файлах: office/strategy/strategy.md, ...

→ Phase 2 (24 мин):
  M1 Memory: 1 contradiction в alex/memory.md (P1)
  M2 Skills: designer/core.md = 301 строка (P1, oversize)
  M3 Routing: trigger collision marketer vs alex-marketer на «маркетолог» (P0)
  M4 Structure: client-profile.md в B2B-формате (P0), нет protocols/GOVERNANCE.md (P1)
  M5 Knowledge: 2 candidate dupes в knowledge/architecture/ (P2)
  M6 Failures: ВСЕ failures.md пусты при работе >7 дней (P0)

→ Phase 3 Report:
  Score: 47/100 — Growing
  Memory & Context: 14/20
  Memory Hygiene: 4/15  ← failures пустые, memory не пополняется
  Routing & Skills: 8/15  ← collision + oversize
  Hooks & Settings: 0/10  ← нет config/hooks/mcp
  Identity & Voice: 6/10  ← только Demiurg имеет soul.md
  Knowledge Hygiene: 6/10
  Freshness: 8/10
  Security Posture: 5/10  ← нет deny rules

→ Looks bad but is actually fine:
  - Demiurg copying в _agent-packs/ — намеренно, fallback при reinstall
  - prework.md с YAML — template для setup, не полузаполнение

→ Phase 4: спросил approval. Пользователь ответил «только важное»
→ Применил 2 P0 (collision rename + client-profile rewrite предложение в чат)
→ Phase 5: записал в memory.md / сохранил в office/ops/audits/2026-05-04-deep.md
```

---

## Quality Gate

Перед отдачей пользователю:
- [ ] Score не «по доброте» — каждый dimension обоснован
- [ ] P0 действительно критичны (не «было бы круто»)
- [ ] План работает — не противоречит сам себе
- [ ] Учитывает тип офиса (dev / marketing / client / mixed) — не одно правило для всех
- [ ] Все требования self-check ✓
- [ ] Approval получен (если tidy / deep)

Если что-то NO → стоп, эскалация пользователю.
