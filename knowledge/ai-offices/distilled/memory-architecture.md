---
title: Архитектура памяти AI-офиса между сессиями
updated: 2026-05-05
source_research: 2026-05-04-office-architecture
status: live
---

# Архитектура памяти между сессиями

> Дистиллят по памяти: layered memory, лимиты, compaction, SessionStart hook. Читать ПЕРЕД проектированием/правкой памяти агентов или офиса.

Главная мысль: **память — это не один файл, а 4 слоя с раздельными владельцами и разной частотой обновления.** Без слоёв агент либо не учится, либо постоянно забывает, либо засоряется и тупеет.

---

## 1. Четыре слоя памяти

```
Уровень 1 — context.md (живой snapshot дня)
            office/context.md, владелец Director, обновляет при /morning
            ≤50 строк, перезаписывается каждый день

Уровень 2 — Эпизодическая память Claude
            .claude/MEMORY.md — индекс ≤200 строк (Anthropic auto-load лимит)
            .claude/memory/<topic>.md — топик-файлы lazy-loading
            Аналог memory у Никиты в ~/.claude/projects/.../memory/

Уровень 3 — Layered agent memory (5 файлов на агента)
            office/agents/<name>/
              core.md       # ядро роли, ≤200 строк, обновляется из template
              soul.md       # характер, ≤150 строк (опц)
              overrides.md  # личные правила пользователя — агент НЕ трогает
              memory.md     # APPEND-ONLY, агент пишет сам после задач
              failures.md   # APPEND-ONLY, grep перед задачей обязателен
              CLAUDE.md     # склейка @core.md @overrides.md (@soul.md если есть)

Уровень 4 — Институтская память офиса
            office/ops/lessons-learned.md     # сводный журнал ошибок
            office/ops/decisions/<date>.md    # ADR append-only
            office/ops/audits/<date>.md       # отчёты Архитектора-Порядка
```

**Закон распределения** (`research/02-forums-communities.md:36`): **routing rules → CLAUDE.md** (грузится целиком), **learnings → MEMORY.md** (грузится первые 200 строк). Перепутать = терять 10-20% контекста на boilerplate.

---

## 2. Жёсткие лимиты — не рекомендации, а технические границы

| Файл | Лимит | Источник | Что делать при превышении |
|------|-------|----------|---------------------------|
| Корневой `CLAUDE.md` | ≤200 строк | `02-forums-communities.md:255` | Лишнее → `office/protocols/` или `knowledge/` |
| Агентский `core.md` | ≤200 строк | `04-governance-cleanup-agents.md:216` | Стек инструментов / edge-cases → `knowledge/<agent>/` |
| Агентский `soul.md` | ≤150 строк | блюпринт | Биография куратора, не дублировать identity из core |
| `.claude/MEMORY.md` | ≤200 строк | Anthropic auto-load (жёсткий технический) | Архивация старого, разбиение по топикам |
| Главный `memory.md` агента | ≤500 токенов | Anubhav `01-youtube-research.md:457` | Старое → `_archive/<date>/`, индекс в `memory.md` |
| `failures.md` | без лимита (append-only feature) | tech-debt-skill | Pattern-detector раз в неделю → правило в core.md если 3+ повтора |
| `SKILL.md` | ≤500 LOC | `04-governance-cleanup-agents.md:217` | Длинные ссылки → `references/` рядом |
| Субагент-промпт | ~30 строк | Anubhav `01-youtube-research.md:458` | — |

**Главный закон.** Anubhav 6 месяцев тюнил Claude Code в проде: *«The main memory file is under 500 tokens on purpose. Subagent definitions are maybe thirty lines each, emphasizing conciseness over exhaustive documentation.»* Делай **меньше, точнее, сфокусированнее**.

**MEMORY.md ≤200 строк — самый частый промах.** Цитата от claudekit.cc (`research/02-forums-communities.md:30`): *«Subagents' system prompts include the first 200 lines or 25KB of MEMORY.md in the memory directory, whichever comes first, with instructions to curate MEMORY.md if it exceeds that limit.»* Это не preference — это как Anthropic построил функцию.

---

## 3. MEMORY.md — индекс, не помойка

Структура файла (≤200 строк):

```markdown
---
name: NeuroShtab Memory Index
date: 2026-05-04
status: active
agent: Director
tags: [memory, index]
---

# Memory Index

## User
- [user_owner.md](user_owner.md) — профиль владельца офиса (имя, стиль, drives)

## Project
- [project_<slug>.md](project_<slug>.md) — активный проект программы

## Feedback
- [feedback_<slug>.md](feedback_<slug>.md) — что пользователь поправил, что не любит

## Reference
- [reference_notion_db.md](reference_notion_db.md) — ID баз Notion
- [reference_mcp.md](reference_mcp.md) — список подключённых MCP

## Decisions (ADR-индекс)
- [2026-05-04-template-baseline.md](../../office/ops/decisions/2026-05-04-template-baseline.md)
```

Каждая запись — 1 строка с пометкой `[LATEST YYYY-MM-DD]` для свежести. Перевешивает старые записи при конфликте.

**Категории по частоте упоминаний у комьюнити** (`research/02-forums-communities.md:48`):

| Категория | Что туда |
|-----------|----------|
| `user/` — профиль владельца | стиль речи, экспертиза, drives, чего избегать |
| `project/` — активные проекты | статус, ключевые решения, открытые блокеры |
| `feedback/` — что пользователь поправил | антипаттерны, не делать так |
| `failures/` — что попробовали и не сработало | дата + предположение + правда + правило |
| `decisions/` — ADR | один файл = одно решение |
| `reference/` — стабильные факты | имена API ключей, пути, ID БД |

**Правило обновления** (там же:58): *«Every memory note should either help the next session act faster, or it should be removed. If a memory note only records that something once happened, it probably belongs in a retrospective, not in active memory.»*

---

## 4. context.md — живой snapshot дня

```markdown
# Context — 2026-05-04

## A+ Task сегодня
[одна строка — что главное]

## В работе
- [агент / задача / статус]

## Блокеры
- [что мешает]

## Last sync
2026-05-04 09:00 — пользователь прошёл /morning

## Активные проекты
- <main> — Week 3 of 6, фаза DISTILLATION
- <secondary> — на паузе

## Заметка для следующей сессии
[что помнить если контекст потеряется]
```

**Owner:** Director.
**Обновление:** каждое утро при `/morning`, по необходимости при крупных хендоффах.
**SessionStart hook читает первым.**

---

## 5. ops/lessons-learned.md — институтская память офиса

```markdown
# Lessons Learned — Office Journal

Append-only. Самые острые уроки всех агентов.
Дублирует записи из failures.md только когда урок применим к нескольким агентам.

## 2026-04-04 — Notion MCP 401 token invalid
- **Кто:** Director
- **Что:** локальный токен MCP протух
- **Почему:** хардкод, нет ротации
- **Правило:** только Cloud MCP с OAuth, локальный = fallback
- **Распространить на:** всех агентов которые работают с MCP
```

Когда писать в `lessons-learned.md` (а не только в `failures.md` агента): когда урок применим **к нескольким агентам**. Если только к одному — хватит `failures.md` агента.

---

## 6. SessionStart hook — что инжектить

Из `research/02-forums-communities.md:67-77`. **Главный сдвиг с Claude Code 2.1.0:** *«SessionStart hooks no longer display user-visible messages. Context is silently injected via hookSpecificOutput.additionalContext.»*

**Hook должен различать `source=startup` vs `source=resume`** (`research/02-forums-communities.md:75`):

**На startup (полный пакет):**
1. Читает `office/context.md` (≤50 строк) — A+ Task / в работе / блокеры.
2. Проверяет `office/strategy/progress-index.md` если существует → текущая неделя.
3. Считает дату последнего обновления `office/agents/director/memory.md` — если >24ч, флагит «давно не сессий».
4. Проверяет наличие плейсхолдеров `{{...}}` в репо — если есть, значит `/setup` не доделан.
5. Дёргает `git status` — есть ли uncommitted (для git-safety snapshot).

**На resume (только дельта):**
1. Текущий A+ Task.
2. Незакрытые таски из `inbox/_new/`.
3. Что появилось в `failures.md` за последние сутки.

**Маленькая защита.** Hook всегда экранирует ≤30 секунд (Disler `research/01-youtube-research.md:308`). Если падает — продолжаем без контекста, не блокируем сессию.

---

## 7. Compaction — на 60%, не на 95%

**Главное правило** (`research/02-forums-communities.md:81`):

> *«The better approach: compact at around 60% context utilization, before quality starts degrading. At 60%, Claude still has full, uncompressed access to everything in your session. Most people use it wrong, waiting until the context window is nearly full instead of treating it as a proactive tool.»*

**Что сохранить при compaction.** В CLAUDE.md шаблона прописать:

> *«When compacting, always preserve the full list of modified files and any test commands.»* (`research/02-forums-communities.md:84`)

**Можно автоматизировать.** PreCompact hook → бэкап транскрипта в `office/ops/sessions/<date>.md` ДО compaction. Если что-то потерялось — восстанавливаем.

---

## 8. Cleanup памяти — раз в сутки

AutoDream-правило (`research/04-governance-cleanup-agents.md:54`): **`>=24h` И `>=5 sessions`** с прошлой уборки. Запускает Architect-of-Order через `/office-architect tidy` или раз в сутки автоматически.

Что чистит (4 категории):

1. **Redundancy** — дубли в memory.md между сессиями.
2. **Contradictions** — конфликтующие факты (`«PostgreSQL note + MySQL note → keeps the current truth»`).
3. **Stale Timestamps** — относительные даты («yesterday we decided to use Redis» → «On 2026-03-15 we decided to use Redis»).
4. **Outdated Debugging Notes** — записи на удалённые файлы.

**Принцип ранжирования:** *«long-term relevance over short-term specifics»* — заметка про testing framework важнее чем конкретный bug fix.

**Защита от over-cleaning:** append-only архивация в `_archive/<YYYY-MM-DD>/`, обязательная секция «Looks bad but is actually fine», approval gate перед mutation. См. `distilled/governance-cleanup.md`.

**Adjusted thresholds для редкого использования.** У клиента может быть 2 сессии в неделю — стандартный `>=24h && >=5 sessions` тогда никогда не сработает. Альтернатива: `>=72h && >=3 sessions` для клиентского профиля (`research/06-blueprint.md` гипотеза 5).

---

## 9. Karpathy lint-операция — что почти никто не реализовал

Andrej Karpathy LLM Wiki (`research/02-forums-communities.md:87`):

> *«Conversations flow into daily logs. Daily logs get compiled into a wiki. The wiki gets injected back into the next session. Your agent builds its own knowledge base over time. Three operations — ingest, query, lint. Stop re-deriving, start compiling.»*

Три операции:
- **ingest** — daily log → wiki
- **query** — wiki → next session
- **lint** — удалять противоречия и stale entries

Третья операция (`lint`) почти ни у кого не реализована — комьюнити шумно об этом говорит. У Architect-of-Order это делает M1 Memory Cleaner (см. `distilled/governance-cleanup.md`).

---

## 10. Главные косяки реальных офисов

Из аудита client-office-template и продакшена ai-office-v2:

1. **Все `failures.md` пустые** — обучаемость нулевая. Декларация «grep перед задачей» работает в пустоту. Затравочно записать 1-2 реальных кейса в каждый.
2. **Дублирование между memory.md и lessons-learned.md** — одни и те же ошибки в двух местах. Решение: lessons-learned только для multi-agent уроков, остальное — в `failures.md` агента.
3. **Memory не теряется при `/clear`** — потому что хранится на диске. Но **теряется при перенаправлении origin репо** если папка `_archive/` в `.gitignore`. См. `distilled/failures-to-avoid.md`.
4. **Claude не знает про слои** — потому что в `core.md` агента не написано «grep failures.md перед задачей». Без явного правила правил agent does not learn.
5. **MEMORY.md > 200 строк** — auto-load обрезает на 200, остальное не подгружается. Часть памяти невидима.
6. **Routing rules в MEMORY.md, learnings в CLAUDE.md** — перепутали слои. Теряете 10-20% контекста на boilerplate (`research/02-forums-communities.md:36`).

---

## Цитаты-якоря (которые имеют смысл запомнить)

- Anubhav (6 месяцев в проде): *«The main memory file is under 500 tokens on purpose. Subagent definitions are maybe thirty lines each.»* (`research/01-youtube-research.md:457`)
- Karpathy: *«Stop re-deriving, start compiling.»* (`research/02-forums-communities.md:90`)
- claudekit.cc: *«MEMORY.md only loads the first 200 lines at session start — that's not a preference but how Anthropic built the feature.»* (`research/02-forums-communities.md:30`)
- Boris Cherny: *«Anytime we see Claude do something incorrectly we add it to the CLAUDE.md, so Claude knows not to do it next time.»* (`research/01-youtube-research.md:50`)
- youngleaders.tech: *«Every memory note should either help the next session act faster, or it should be removed.»* (`research/02-forums-communities.md:58`)

---

## Источники

- `research/2026-05-04-office-architecture/01-youtube-research.md:456-462` — лимиты Anubhav
- `research/2026-05-04-office-architecture/02-forums-communities.md:24-102` — память между сессиями (форумы)
- `research/2026-05-04-office-architecture/04-governance-cleanup-agents.md:43-60` — AutoDream
- `research/2026-05-04-office-architecture/06-blueprint.md:237-385` — секция 3 ПАМЯТЬ блюпринта
- `research/2026-05-04-office-architecture/03-internal-knowledge.md:42-115` — текущая система памяти

## Связанные дистилляты

- `distilled/10-principles.md` — принципы 3, 7, 8, 10
- `distilled/agent-design.md` — структура агента (5 файлов)
- `distilled/governance-cleanup.md` — Memory Cleaner модуль
- `distilled/failures-to-avoid.md` — пустые failures.md, потеря при /clear
