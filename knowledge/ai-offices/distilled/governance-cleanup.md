---
title: Governance и уборщики офиса
updated: 2026-05-05
source_research: 2026-05-04-office-architecture
status: live
---

# Governance и уборщики офиса

> Дистиллят по архитектуре «уборщиков»: 6 архетипов, защиты от destructive cleanup, AutoDream, Florian rubric. Читать ПЕРЕД проектированием/правкой агента-смотрителя или запуском аудита офиса.

Главная мысль: **«уборщик» — это не один агент, а семейство ролей с разной частотой запуска.** Continuous (hooks) → periodic (cron) → on-demand (ручной audit) → pre-release (review) → annual (regulatory). Все эти роли можно собрать в одного агента в 3 режимах (scan/tidy/deep), но внутри они работают как разные модули.

И главная защита — **read-only by default + approval-gate перед mutation**. Реальный кейс 2026-04: Claude-Cursor агент удалил production-БД за 9 секунд (`research/04-governance-cleanup-agents.md:333`). Без защит от destructive cleanup офис превращается в источник риска.

---

## 1. Шесть архетипов уборщиков

Из таксономии `research/04-governance-cleanup-agents.md:39-149`. Все шесть собираются в одном агенте Architect-of-Order, но с разной частотой запуска:

| # | Архетип | Частота | Что чистит | Деструктивен? |
|---|---------|---------|------------|---------------|
| 1 | **Memory Cleaner** | Раз в сутки (`>=24h && >=5 sessions`) | AutoDream: redundancy / contradictions / stale timestamps / outdated debugging notes. Лимит MEMORY.md ≤200 строк. | Да, нужен soft-delete |
| 2 | **Skill Auditor** | На pre-commit hook / при `/cleanup` | Frontmatter, `description:`, triggers, `effort:`, `allowed-tools:` каждой SKILL.md | Нет, fail-fast отчёт |
| 3 | **Routing Validator** | Еженедельно | Каждый агент достижим, триггеры не пересекаются, нет циклов в handoff | Нет, отчёт |
| 4 | **Structure Linter** | На SessionStart hook | PARA-структура, файл в правильной папке, symlinks целы, INDEX.md актуален | Нет, read-only |
| 5 | **Knowledge Dedup** | Раз в месяц | Embeddings cosine ≥0.85 или Jaccard на heading sets, заголовочные коллизии | Нет, кандидаты на ручное удаление |
| 6 | **Failure Pattern Detector** | Еженедельно | Группировка `failures.md` → правило в `core.md` если 3+ повтора за месяц | Нет, отчёт + предложение правил |

---

## 2. Memory Cleaner — AutoDream правила

Классический пример: AutoDream в Claude Code (`research/04-governance-cleanup-agents.md:43-60`).

Что чистит — 4 категории:

1. **Redundancy** — дубли в MEMORY.md между сессиями.
2. **Contradictions** — конфликтующие факты («PostgreSQL note + MySQL note → keeps the current truth»).
3. **Stale Timestamps** — относительные даты («yesterday we decided to use Redis» → «On 2026-03-15 we decided to use Redis»).
4. **Outdated Debugging Notes** — записи на удалённые файлы.

**Принцип ранжирования:** *«long-term relevance over short-term specifics»* — заметка про testing framework важнее чем конкретный bug fix.

**Триггер.** `>=24 часа` с прошлой уборки И `>=5 новых сессий`. Лимит — MEMORY.md ≤200 строк (Anthropic auto-load технический лимит).

**Стандартный цикл уборки** — 8-10 минут.

**Adjusted thresholds для редкого использования.** Клиент с 2 сессиями в неделю — стандартный `>=24h && >=5 sessions` никогда не сработает. Альтернатива: `>=72h && >=3 sessions` для клиентского профиля.

---

## 3. Florian audit-prompt — 8-мерная рубрика (100 баллов)

Самая зрелая публичная рубрика для Claude Code-офиса (`research/04-governance-cleanup-agents.md:155-171`). 700 строк, скачано в `/tmp/audit-prompt-florian.md`.

| # | Измерение | Макс | Что меряют |
|---|-----------|------|------------|
| 1 | Memory & Context | 20 | CLAUDE.md, rules, token budget, % от 200K окна |
| 2 | Rules Hygiene | 10 | Frontmatter, `paths:` valid, размер <150 строк |
| 3 | Skills Quality | 10 | `description:`, `effort:`, `allowed-tools:` в каждой SKILL.md |
| 4 | Agents/Commands Quality | 10 | Frontmatter, `argument-hint` для команд с `$ARGUMENTS` |
| 5 | Security Posture | 20 | `permissions.deny` для `.env*`, PreToolUse hooks, no hardcoded secrets |
| 6 | MCP Ecosystem | 10 | Хотя бы 1 MCP, no production DB MCP, есть Documentation MCP |
| 7 | Workflow Commands | 10 | `/morning`, `/wrap-up`, `/triage`, `/setup`, `/audit` |
| 8 | Freshness | 10 | Нет deprecated моделей, git-активность <90 дней |

**Tier'ы по итогу:**
- **Starter** (<40)
- **Growing** (40-59)
- **Established** (60-79)
- **Optimized** (80+)

**Token-budget пороги:**
- **<20K фиксированного контекста** — зелёный, 18-20 pts
- **20-40K** — жёлтый, 12-17 pts
- **40-60K** — оранжевый, 6-11 pts
- **>60K** — красный, 0-5 pts

Фиксированный контекст съедает окно ДО того как Claude увидел задачу. У офиса с 17 агентами и большой knowledge-базой — реальный риск.

---

## 4. Pipeline аудита — 5 фаз (4 от Florian + 5-я наша)

Из ТЗ Architect-of-Order (`research/04-governance-cleanup-agents.md:490-525`):

**Phase 1 — Inventory (30 секунд, bash-only)**

Один bash-блок выгребает всё структурное:
- Список агентов в `office/agents/`
- Список скиллов
- Размер каждого core.md / SKILL.md
- INDEX.md статусы
- Symlinks integrity
- Tech stack

**Защита от cleanup-induced context pollution.** Phase 1 читает только метаданные через bash (find, ls, wc), не содержимое файлов.

**Phase 2 — Dimension Audit (3-30 мин)**

Прогон 7 модулей. В quick-режиме — только bash-чеки. В standard — bash + LLM-аудит на 3 слабых агентов. В deep — полный прогон + Florian 8-мерная рубрика.

**Phase 3 — Unified Report**

Структура отчёта:
- Executive Summary: total score, maturity tier, top-3 quick wins, top-3 critical gaps
- Dimension Scorecard (table 8 строк)
- Detailed Findings — сгруппированы по модулям с file:line citations
- **«Looks bad but is actually fine»** — обязательная секция (см. защиту 5)
- Next Actions — что фиксить сейчас, что отложить

**Phase 4 — Validation Request**

Никаких изменений без явного:
- `да` → применить top-3 quick wins
- `только важное` → только critical gaps
- `«1, 3»` → конкретные пункты
- `нет` → оставить отчёт, ничего не трогать

**Phase 5 — Memory Update (наша добавка)**

После одобренных изменений:
- Append в `office/agents/<architect>/memory.md` (Decisions / Patterns / Context)
- Если фейл — `failures.md`
- Старые версии — в `_archive/<YYYY-MM-DD>/`
- Обновить дату в `agent-state.md`

---

## 5. Шесть защит от destructive cleanup

Реальный кейс провала (`research/04-governance-cleanup-agents.md:333`): *«Claude-Cursor агент удалил production-базу за 9 секунд (cxtoday.com, futurism.com, euronews.com).»* Поэтому защиты — обязательны:

### 5.1 settings.json deny-rules

Минимум для `.claude/settings.json`:

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(curl * | sh)",
      "Bash(wget * | bash)",
      "Bash(git push --force *)",
      "Edit(.env)",
      "Edit(.env.*)",
      "Bash(*--no-verify*)"
    ]
  }
}
```

См. `distilled/tools-mcp-stack.md` для полного template.

### 5.2 allowed-tools (Write/Edit запрещены в core)

Architect-of-Order frontmatter:

```yaml
allowed-tools: Read, Grep, Glob, Bash(ls,find,wc,grep,git log,head,tail,jq), TodoWrite, Edit
```

**Запрещены:** `Write` (создание новых файлов), `Bash(rm)`, `Bash(mv)` в scan-режиме. Деструктивные операции — только в `deep`-режиме после явного approval.

`Edit` — только для tidy-режима, только soft-fixes (frontmatter, datestamps).

### 5.3 disable-model-invocation: true

```yaml
disable-model-invocation: true
```

Архитектор запускается **только пользователем** (паттерн tech-debt-skill). Иначе он будет дёргаться при каждом упоминании «порядка» в чате.

### 5.4 Approval-gate перед mutation

Phase 4 — explicit approval с 4 опциями. Никаких авто-fixes кроме *«one clear correct fix»* (frontmatter правки, datestamps).

Compound: *«findings with one clear correct fix apply automatically and silently»* — но это только для тривиальных правок.

### 5.5 Append-only архивация (Anthropic Memory Tool API)

```
Old: file.md (current) → Edit → file.md (new, overwrite)  ← ПЛОХО
New: file.md → _archive/2026-05-04/file.md → file.md (new) ← ХОРОШО
```

Anthropic Memory Tool API цитата (`research/04-governance-cleanup-agents.md:336`):

> *«Every change to a memory creates an immutable memory version, giving you an audit trail and point-in-time recovery for everything the agent writes.»*

**Принципы:**
1. **Append-only > delete.** Старые версии в `_archive/` с датой, не перезаписываем.
2. **Immutable versions.** Каждое изменение memory.md = новая версия, восстанавливаем точкой во времени.
3. **Soft-delete + redact.** *«Redact scrubs content out of a historical version while preserving the audit trail.»* Хорошо для PII / секретов.

### 5.6 Section «Looks bad but is actually fine»

**Обязательная секция отчёта.** Защита от cleanup'а load-bearing patterns.

Если в отчёте секция **пустая** — Архитектор-Порядка возвращает FAIL. Это форсирует thinking: автор обязан подумать «а что выглядит как bug, но на самом деле feature?».

Примеры load-bearing patterns:
- `failures.md` каждого агента >300 строк — это намеренно append-only, фича, не bug.
- 2 INDEX.md в `clients/` — один root (текущий), второй `_archive/INDEX-2026-04.md` (исторический).
- Symlink `office/` → `ai-office-v2/office/` — фундамент архитектуры, не дубликат.

Из `tech-debt-skill` (`research/04-governance-cleanup-agents.md:317`): *«Read code before judging it — a pattern that looks wrong in isolation may be load-bearing.»*

---

## 6. Hard caps — защита от loop

Looping — самый частый failure-mode (Arize taxonomy `research/04-governance-cleanup-agents.md:143`). Уборщик может застрять: *«нашёл противоречие → попытался разрешить → создал новое противоречие → снова нашёл».*

**Защиты:**

1. **Hard cap на время** — AutoDream: 8-10 минут на цикл, deep-режим Architect ≤60 мин.
2. **Hard cap на iterations** — не больше 3 проходов по одному файлу.
3. **Idempotency check** — если после уборки следующий запуск находит то же самое — выходим. См. `distilled/builder-validator.md` секцию 9.

---

## 7. Privacy — не читать секреты

Уборщик читает все файлы и попадается на секреты в логах.

**Защиты:**

1. **Skip patterns.** Не читать `.env*`, `*.pem`, `credentials*`, `secrets*` — уборщику они не нужны.
2. **Redact в отчёте.** Если нашёл что-то похожее на токен, в отчёте — `[REDACTED-TOKEN-LIKE-STRING]`, а не сам токен.
3. **Privacy-first в core.md.** Жёсткое правило G4: *«Privacy first. .env*, *.pem, credentials*, secrets* — не читаю.»*

**Anti-pattern (`research/08-reviewer-report.md:96`):** Read разрешён без deny на `.env*`, единственный barrier — prompt в core.md G4. Это P0 — promise vs reality. Реально клиент или Director могут попросить «прочитай .env» — Read tool разрешит.

Решение: settings.json deny-rule + agent allowed-tools = двойная защита. Или физически переписать allowed-tools на узкий Read scope: `Read(office/**)`, `Read(.claude/**)`, `Read(_agent-packs/**)`.

---

## 8. False positives на специфике офиса

Generic-аудитор не знает специфики офиса. Например, у нас `failures.md` намеренно append-only, и большой размер — это feature.

**Реальный пример провала** (`research/08-reviewer-report.md:197`):

> *«M6 Failure Pattern Detector — false positive на день 1. Сценарий: клиент только что прошёл /setup, день 1, запускает «проверь офис». Архитектор делает scan, находит: M6: все failures.md пустые (>7 дней) — но офис работает 0 дней!»*

Решение — context-aware logic:

```
M6 Failure Detector =
  failures.md пусты
  И git log --reverse --format="%ai" | head -1 показывает что репо старше 14 дней
  И за последние 14 дней были коммиты от пользователя (не bot)
```

**Защиты:**

1. **Exemptions через frontmatter.** Файл может объявить `audit-rules: skip-size-check`.
2. **Project-specific config.** `.skill-policy.yml` (Skills Check) — переопределяет глобальные правила.
3. **Правило tech-debt-skill:** *«Don't pattern-match to generic best practices without grounding in this specific repo.»*

---

## 9. Citation rule — без file:line finding не зафиксят

Из tech-debt-skill (`research/04-governance-cleanup-agents.md:315`):

> *«A finding without a citation is unfalsifiable, and unfalsifiable findings don't get fixed.»*

Каждое finding в отчёте — `path/file.ext:LINE` минимум.

**Пример хорошего finding:**

```markdown
**Finding M3.1 — Trigger collision**
Files: office/agents/alex/skills/core-offer/SKILL.md:8
       vs office/agents/cherry/skills/polish-offer/SKILL.md:11
Issue: Оба триггерятся на «упакуй оффер»
Impact: Director не знает кому передать, эскалация к человеку
Fix: Алекс — упаковка ЦА→оффер. Cherry — полировка готового.
     Триггер Cherry уточнить: «отполируй оффер», «улучши формулировку»
```

**Anti-pattern.** Finding *«в офисе хаос с маркетологами»* — без file:line, унфальсифицируемо, не зафиксят.

---

## 10. Когда запускать — таблица частот

Сводная таблица из `research/04-governance-cleanup-agents.md:223-235`:

| Уборщик | Частота | Триггер | Время | Деструктивен? |
|---------|---------|---------|-------|---------------|
| Memory Cleaner | Раз в сутки | `>=24h && >=5 sessions` | 8-10 мин | Да, soft-delete |
| Structure Linter | На SessionStart hook | автоматически | <30 сек | Нет, read-only |
| Skill Auditor (lint) | На pre-commit hook | при изменении SKILL.md | 5-15 сек | Нет, fail-fast |
| Routing Validator | Еженедельно | пятница, ручной | 5 мин | Нет, отчёт |
| Knowledge Dedup | Раз в месяц | `/office-cleaner deep` | 15-30 мин | Нет, кандидаты |
| Failure Pattern Detector | Еженедельно | пятница, после log-review | 5 мин | Нет, отчёт + предложение |
| Health Check (Florian) | По запросу | пользователь говорит «аудит» | 5-8 мин | Нет, отчёт + Phase 4 approval |
| Security Audit | Перед deploy / Quarterly | вручную | 15 мин | Нет, отчёт |
| Document-Review (Compound) | Перед merge / handoff | при готовности артефакта | 2-5 мин | Auto-fix только тривиальное |

**Принципы запуска:**

1. **Background ≠ автоматическое удаление.** AutoDream бежит в фоне, но удаляет только идентичные дубли. Сложные кейсы — оставляет в `pending_review` для человека.
2. **Idle time предпочтителен.** Уборка не должна толкаться с активной задачей — отсюда «sleep» метафора.
3. **Manual override обязателен.** В AutoDream есть `dream` команда — пользователь может запустить вручную.
4. **Фиксированное окно для уборки.** Не работает >10 мин — иначе встаёт в очередь.

---

## 11. Three режима в одном агенте — scan / tidy / deep

Architect-of-Order реализует все 6 архетипов в **одном** агенте, но с тремя режимами интенсивности (`research/04-governance-cleanup-agents.md:418-419`):

| Режим | Время | Tools | Что делает |
|-------|-------|-------|------------|
| **scan** | ≤5 мин | Read-only | Phase 1 inventory + краткая dimension-audit, output отчёт без правок |
| **tidy** | ≤15 мин | Read + Edit (soft-fixes) | scan + soft-fixes (создание missing INDEX.md, перенос мёртвого кода в `_archive/`, обновление timestamps). Каждое изменение требует подтверждения. |
| **deep** | ≤60 мин | Read + Edit + Bash whitelist | Полный прогон 6 модулей + Florian 8-мерная рубрика с обоснованием score. Output: 5-страничный отчёт с P0/P1/P2. |

**SessionStart hook** дёргает только `scan` light (Phase 1 inventory ≤30 сек, read-only). Только если последний полный аудит >7 дней.

**Защиты для трёх режимов:**

- **scan** — никаких mutation. `Bash(rm)`, `Bash(mv)` запрещены.
- **tidy** — только soft-fixes (frontmatter, datestamps), требует approval на каждое изменение.
- **deep** — полный, но всё равно через Phase 4 approval gate.

---

## 12. Цитаты-якоря

- AutoDream: *«AutoDream is a background sub-agent that consolidates Claude Code's memory between sessions, mirroring how biological memory consolidation works during REM sleep.»* (`research/04-governance-cleanup-agents.md:46`)
- tech-debt-skill: *«A finding without a citation is unfalsifiable, and unfalsifiable findings don't get fixed.»* (`research/04-governance-cleanup-agents.md:315`)
- tech-debt-skill: *«Read code before judging it — a pattern that looks wrong in isolation may be load-bearing.»* (`research/04-governance-cleanup-agents.md:316`)
- Anthropic Memory Tool API: *«Every change to a memory creates an immutable memory version.»* (`research/04-governance-cleanup-agents.md:336`)
- Reviewer report: *«Любой агент-инспектор должен сначала прогнать себя.»* (`research/08-reviewer-report.md:476`)

---

## Источники

- `research/2026-05-04-office-architecture/04-governance-cleanup-agents.md` — целиком, главный документ
- `research/2026-05-04-office-architecture/06-blueprint.md:533-600` — секция 6 GOVERNANCE
- `research/2026-05-04-office-architecture/08-reviewer-report.md:96-130` — реальные баги защит
- `research/2026-05-04-office-architecture/03-internal-knowledge.md:282-303` — protocols/CLEANUP

## Связанные дистилляты

- `distilled/10-principles.md` — принципы 6, 8 (Builder/Validator, compaction)
- `distilled/memory-architecture.md` — Memory Cleaner детали
- `distilled/agent-design.md` — Architect-of-Order устройство
- `distilled/builder-validator.md` — independent reviewer как защита
- `distilled/tools-mcp-stack.md` — settings.json deny-rules
- `distilled/failures-to-avoid.md` — реальный кейс destructive cleanup
