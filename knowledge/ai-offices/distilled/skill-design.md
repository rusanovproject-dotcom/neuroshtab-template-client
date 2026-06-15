---
title: Проектирование скиллов
updated: 2026-05-05
source_research: 2026-05-04-office-architecture
status: live
---

# Проектирование скиллов

> Дистиллят по скиллам: когда скилл vs hook vs subagent vs MCP, frontmatter, триггеры, naming. Читать ПЕРЕД созданием нового скилла или рефакторингом существующих.

Главная мысль: **скилл — это workflow с триггером, который Claude сам решает запускать на основе `description:`.** Если триггер слабый — скилл не вызовется. Если триггеров много и они пересекаются с другими скиллами — collision и Director не знает кому передать.

---

## 1. Скилл vs hook vs subagent vs MCP — когда что

Единая ментальная модель из `research/02-forums-communities.md:213-220`:

```
Hook       = детерминизм («каждый раз когда X»)
Skill      = workflow с триггером («когда юзер просит Y»)
Subagent   = изоляция контекста + параллельность («исследуй и верни report»)
MCP        = инструмент-расширение (запрос в Notion, отправка письма)
CLAUDE.md  = правила, применимые везде
MEMORY.md  = усвоенный опыт, грузится в начало
```

**Решающий вопрос.** Надо ли это **детерминированно** при каждом X — hook. Только когда юзер сам попросит — skill. Параллельно/в изоляции — subagent. Внешний инструмент-API — MCP. Правило везде — CLAUDE.md.

**Skills > MCP когда можно.** Cole Medin доказал на проде Second Brain: markdown + lazy-load skills закрывают 95% кейсов без MCP. MCP стоит дорого по контексту (каждый MCP добавляет все свои tools в context window).

См. `distilled/tools-mcp-stack.md` секция «Skills vs MCP».

---

## 2. Frontmatter SKILL.md — обязательный

Формат от Anthropic (`research/02-forums-communities.md:167`):

```yaml
---
name: jtbd
description: |
  JTBD-распаковка ЦА: генерирует гипотезы сегментов и работ
  по методологии Advanced JTBD. На выходе — единый документ
  JTBD_анализ_<main>.md с 3-5 сегментами.

  TRIGGERS: "распакуй ЦА", "JTBD", "кто наша ЦА", "работа клиента"
  ANTI-TRIGGERS: онбординг не пройден (onboarding_completed != true) → /alex-onboarding;
                 has_paying_customers: false → /custdev сначала
disable-model-invocation: false
allowed-tools: Read, Edit, Grep, Glob, TodoWrite
effort: high
---
```

**Триггерное слово — `description`.** Anthropic: *«The skill's name and description fields are critical since Claude will use these when deciding whether to trigger the skill.»* (`research/01-youtube-research.md:383`). Это **роутинг через семантику**, без явных правил.

**`disable-model-invocation: true`** — для скиллов которые опасно запускать на автомате (деплой, удаление, Architect-of-Order). Запускается только пользователем (`research/02-forums-communities.md:172`).

**`allowed-tools`** — белый список. Validator-скиллы (read-only QA) — никогда не включают `Write`/`Edit`.

**`effort: low | medium | high`** — подсказка пользователю про ожидаемое время.

---

## 3. MANDATORY TRIGGERS секция в SKILL.md

Триггеры в `description` дают семантический поиск. Но для критичных скиллов нужно **явно прописать MANDATORY TRIGGERS внутри SKILL.md** — фразы при которых скилл должен запуститься без сомнений.

Пример из реального скилла:

```markdown
## MANDATORY TRIGGERS

Запускай этот скилл сразу когда пользователь говорит:
- «сделай КП», «КП для», «коммерческое предложение», «напиши КП»

Не задавай уточняющих вопросов — иди в Phase 1 сразу.
```

**Зачем это нужно.** В `description` ты пишешь триггеры одной строкой. Внутри SKILL.md ты их **повторяешь и расширяешь** — это удваивает шанс что Claude вспомнит скилл при семантически близкой фразе.

**ANTI-TRIGGERS — обязательно.** Когда скилл НЕ запускать. Без них collision гарантирован при росте офиса.

```markdown
## ANTI-TRIGGERS

НЕ запускай этот скилл когда:
- сессия не выходит за scope текущей задачи
- пользователь работает над Tier 1 — отвлекать нельзя
- uncommitted changes в git — попроси зафиксировать сначала
```

---

## 4. Лимит ≤500 LOC + lazy-load supporting файлов

Anthropic: *«Like a well-organized manual that starts with a table of contents, then specific chapters, and finally a detailed appendix, skills let Claude load information only as needed.»* (`research/01-youtube-research.md:379`)

**Структура папки скилла:**

```
skills/<name>/
├── SKILL.md              # ≤500 LOC, ядро workflow
├── references/           # подгружаемые материалы (ссылки в SKILL.md)
│   ├── methodology.md
│   └── examples.md
└── templates/            # шаблоны output (ссылки в SKILL.md)
    └── output.template.md
```

**Главный SKILL.md** — точка входа. Описывает шаги workflow. На детали ссылается через `@references/methodology.md` или `office/agents/<name>/knowledge/<topic>.md`.

**Anti-pattern.** SKILL.md на 1000 строк с inline методологией. Раздувает контекст когда скилл не нужен. Проигрывает версии где в SKILL.md `@references/methodology.md` (200 строк) + сама методология (800 строк) подгружается только когда дошёл до этапа 3.

---

## 5. Когда скилл vs hook vs subagent — конкретные примеры

| Задача | Что использовать | Почему |
|--------|------------------|--------|
| Каждый старт сессии — читать context.md | **Hook** SessionStart | Должно быть детерминированно, скилл может не сработать |
| Утренний ритуал по запросу «утро» | **Skill** /morning | Пользователь явно вызывает |
| Проверка JTBD-анализа независимым ревьюером | **Subagent** через `/jtbd-critic` | Нужен чистый контекст, нельзя засорять основную сессию |
| Запрос в Notion API | **MCP** notion | Внешний инструмент с auth |
| Запрет `rm -rf` всегда | **Hook** PreToolUse | Детерминированный guard |
| Создать карточку нового клиента | **Skill** /new-client | По запросу, многошаговый workflow |
| Параллельный research по 5 источникам | **Subagent** через `/scout` | Изоляция контекста + параллельность |
| Правила работы с пользователем | **CLAUDE.md** | Применимо ко всем задачам |
| Опыт «не использовать local Notion MCP, протух токен» | **memory.md** агента | Усвоенный опыт |

---

## 6. Naming convention — kebab-case + role-descriptor

Зафиксировать в шаблоне раз и навсегда (`research/02-forums-communities.md:266`):

```
hooks       → snake_case.sh / .py    (session_start.sh, pre_tool_use.py)
agents      → kebab-case.md / папки  (alex-marketer/, architect-of-order/)
skills      → kebab-case/SKILL.md    (jtbd/SKILL.md, core-offer/SKILL.md)
commands    → kebab-case.md          (alex-onboarding.md)
docs        → UPPER_SNAKE.md         (CLAUDE.md, AGENTS.md, MEMORY.md, INDEX.md)
memory      → topic-snake.md         (decisions/api-conventions.md)
projects    → kebab-case/             (clients/grineva-yulia/)
agent role-descriptors → suffix      (-pro, -specialist, -expert, -architect, -engineer)
```

**Скиллы — verb или noun-fragment.** `commit-message-generator`, `pr-review`, `code-simplifier`. Не `do-commit` (глагольный prefix), не `CommitGenerator` (CamelCase).

**Из 100+ subagent-коллекции VoltAgent** (`research/02-forums-communities.md:267`): *«Subagents follow consistent patterns: role-descriptor format using hyphens (typescript-pro, devops-engineer, security-auditor). Suffixes indicate specialization levels.»*

---

## 7. Минимальный пакет скиллов «День 1»

Из синтеза 7 источников (`research/06-blueprint.md:387-414`). 12 must-have для базового офиса:

| # | Скилл | Назначение | Главный TRIGGER |
|---|-------|------------|-----------------|
| 1 | **/setup** | Первичная настройка офиса при первом «привет» | `привет`, `start`, `поехали` |
| 2 | **/morning** | Утренний ритуал: A+ Task + читает strategy + ставит фокус | `утро`, `план дня`, `что делаем` |
| 3 | **/wrap-up** | Завершение сессии: записывает learnings, обновляет memory | `wrap up`, `завершить сессию` |
| 4 | **/triage** | Разбор inbox через Revenue Filter | `triage`, `что в инбоксе` |
| 5 | **/intake** | Разбор папки `inbox/` — классифицирует файлы | `разбери инбокс`, `положи файл` |
| 6 | **/interview** | Интерактивное интервью (Harper Reed pattern) для размытых задач | `давай обсудим`, `придумай оффер`, `новый проект` |
| 7 | **/audit-project** или **/office-cleaner** | Аудит офиса, Architect-of-Order | `проверь офис`, `аудит` |
| 8 | **/install-agent** | Установка готового пака из `_agent-packs/` | `подключи копирайтера`, `нужен маркетолог` |
| 9 | **/update-office** | Безопасное обновление офиса до свежей версии | `обнови офис` |
| 10 | **/new-project** | Создание нового проекта со структурой папок | `новый проект` |
| 11 | **/skill-creator** | Создание/изменение скиллов (Anthropic recommendation) | `создай скилл`, `новый skill` |
| 12 | **/scout** | Research-фаза перед /build | `разведка`, `scout` |

**Принцип Anthropic** (`research/01-youtube-research.md:395`): *«No universal baseline skills are recommended; instead, Anthropic advises building skills incrementally to address your specific agent's identified shortcomings.»*

12 — не догма, а минимум закрывающий первый день клиента. Остальное — по мере появления пробоев. Подход — *«start with evaluation»* (найди где Claude косячит → создай скилл).

---

## 8. Дубли — типичная ошибка, как избегать

**Реальный кейс из аудита client-office-template** (`research/07-audit-client-template.md:189`):

> *«Дубль / коллизия скиллов между `.claude/skills/` и `_agent-packs/.../skills/`. `audit-project/` лежит И в `.claude/skills/` И в `_agent-packs/demiurg/skills/`. После установки демиурга скилл удвоится.»*

**Главные источники дублей:**

1. **Скилл живёт И в base, И в пакете агента.** При установке пака — copy-collision. Решение: один источник правды. Базовые скиллы только в `.claude/skills/`. Скиллы агента-специалиста — только в его паке `_agent-packs/<name>/skills/`.

2. **Триггер collision между скиллами.** Два скилла подписаны на «упакуй оффер». Director не знает кому передать. Решение: явные `ANTI-TRIGGERS`, разные семантические зоны. См. `distilled/routing-triggers.md`.

3. **Hardcoded маппинги ключевиков в `install-agent`** к несуществующим пакам. Например, `«копирайтер» → copywriter` когда пака `copywriter` нет. Клиент скажет «нужен копирайтер» — получит «нет такого пака». Решение: маппинг динамический, читается из `_agent-packs/INDEX.md`.

4. **Дубль контента core ↔ knowledge ↔ SKILL.** Те же таблицы повторяются в 3-х местах. Раздувает контекст когда все 3 файла попадают в session (`research/08-reviewer-report.md:166`). Решение: SKILL.md — workflow, knowledge — методология, core агента — реferences. Не дублируй полное содержимое.

См. `distilled/failures-to-avoid.md` секцию «дубли скиллов».

---

## 9. Discovery test — заработал ли скилл

**Тест Hamel Husain** (`research/02-forums-communities.md:321`): после создания скилла — *«спроси у Claude Code "какие скиллы есть для X" — должен назвать минимум 3 включая твой»*. Если не называет — `description:` слабый, перепиши с конкретными триггерами.

**Можно встроить в `/audit-project`** или в smoke-test онбординга:

```bash
# Smoke-test discovery
echo "Какие скиллы есть для маркетинга?" | claude --headless | grep -c "marketer\|jtbd\|core-offer"
# Должно быть >=3
```

---

## 10. Где брать готовые скиллы

Три главных источника (`research/02-forums-communities.md:107`):

1. **`anthropics/skills`** (128k звёзд) — официальные: skill-creator, claude-api, pdf, xlsx, docx, pptx
2. **`obra/superpowers`** (Jesse Vincent) — методология «14 core skills» (brainstorming, writing-plans, TDD, simplify, verification-before-completion, requesting-code-review)
3. **`VoltAgent/awesome-agent-skills`** — 1000+ скиллов от комьюнити, кросс-платформенные

**Принцип:** не ставь все 1000. Возьми минимум 12 must-have, остальное добавляй когда видишь конкретную дыру.

См. также `distilled/tools-mcp-stack.md` для эталонных репо со скиллами.

---

## 11. Skill auditor — как проверять качество скилла

Из Florian audit-prompt (`research/04-governance-cleanup-agents.md:76`):

| Чек | Баллы | Что проверяет |
|-----|-------|---------------|
| Skills Directory exists | 1 pt | папка `.claude/skills/` есть |
| All SKILL.md have description: field | 2 pts | без description Claude не вызовет скилл |
| All SKILL.md have effort: field | 3 pts | подсказка пользователю про время |
| All SKILL.md have allowed-tools: field | 2 pts | белый список tools |
| Все commands с `$ARGUMENTS` имеют `argument-hint:` | 2 pts | UX подсказка |

Эти чеки автоматизируются через bash + jq в `/office-cleaner scan`. См. `distilled/governance-cleanup.md` модуль M2 Skill Auditor.

---

## 12. Цитаты-якоря

- Anthropic: *«The skill's name and description fields are critical since Claude will use these when deciding whether to trigger the skill.»* (`research/01-youtube-research.md:383`)
- Anubhav: *«Subagent definitions are maybe thirty lines each, emphasizing conciseness over exhaustive documentation.»* (`research/01-youtube-research.md:458`)
- Owen Fox: *«Skills are for changing how Claude works in your current conversation. Subagents are for delegating a task to a separate worker with its own memory space. Hooks are for intercepting and controlling lifecycle events with deterministic scripts.»* (`research/02-forums-communities.md:208`)
- Anthropic (`research/01-youtube-research.md:395`): *«No universal baseline skills are recommended; build skills incrementally to address your specific agent's identified shortcomings.»*

---

## Источники

- `research/2026-05-04-office-architecture/01-youtube-research.md:166-211` — Anthropic Skills, frontmatter
- `research/2026-05-04-office-architecture/02-forums-communities.md:106-198` — комьюнити по скиллам
- `research/2026-05-04-office-architecture/04-governance-cleanup-agents.md:62-92` — Skill Auditor
- `research/2026-05-04-office-architecture/06-blueprint.md:387-414` — must-have пакет
- `research/2026-05-04-office-architecture/07-audit-client-template.md:172-203` — дубли скиллов

## Связанные дистилляты

- `distilled/agent-design.md` — frontmatter агента, отношение skill-agent
- `distilled/routing-triggers.md` — триггеры, anti-triggers, конфликты
- `distilled/governance-cleanup.md` — Skill Auditor (M2)
- `distilled/tools-mcp-stack.md` — skills vs MCP
- `distilled/failures-to-avoid.md` — дубли, hardcoded маппинги
