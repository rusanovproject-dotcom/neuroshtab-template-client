---
title: Роутинг и триггеры
updated: 2026-05-05
source_research: 2026-05-04-office-architecture
status: live
---

# Роутинг и триггеры

> Дистиллят по роутингу: triggers + anti-triggers, конфликты, conflict resolution, naming convention. Читать ПЕРЕД созданием нового скилла/агента или при правке routing-patterns.

Главная мысль: **триггеры в `description` + ANTI-TRIGGERS — обязательны.** Без них collision гарантирован при росте офиса. Главная боль реальных офисов — два скилла подписаны на одну фразу, Director не знает кому передать.

---

## 1. Как user-задача попадает к нужному агенту

```
User → CLAUDE.md (инжектит контекст всех @include агентов)
      ↓
   Director (Atlas) — читает routing-patterns.md
      ↓
   Соответствует ли triggers какому-то агенту в AGENTS.md?
      ├─ Да → Handoff yaml → агент исполняет
      ├─ Нет, но _agent-packs/<name> есть → /install-agent <name> → handoff
      └─ Нет → Honest fallback («такого помощника пока нет, могу так через [агент]»)
```

**Главный закон:** Director читает **только** routing-patterns.md и AGENTS.md. Не пытается сам решить «что делать» — он смотрит таблицу.

---

## 2. Triggers + ANTI-TRIGGERS обязательны в каждом скилле

```yaml
---
name: jtbd
description: |
  JTBD-распаковка ЦА...

  TRIGGERS: "распакуй ЦА", "JTBD", "кто наша ЦА", "работа клиента"
  ANTI-TRIGGERS: онбординг не пройден (onboarding_completed != true) → /alex-onboarding;
                 has_paying_customers: false → /custdev сначала
---
```

**Anti-triggers** — описаны в человеческой форме, проверяются Director'ом из `agent-state.md`.

**Зачем.** Без anti-triggers Director вызовет JTBD когда:
- онбординг ещё не пройден (получим бессмысленный анализ)
- нет платящих клиентов (нет фактуры — нечего распаковывать)

С anti-triggers Director сначала отправит на `/alex-onboarding` или `/custdev`, потом вернётся к JTBD.

---

## 3. Главная боль офисов — collision триггеров

**Реальный кейс из этого исследования** (`research/08-reviewer-report.md:34-63`):

> *«install.md правит routing-patterns.md в формате который НЕ существует в шаблоне. Триггеры «проверь офис», «наведи порядок» УЖЕ занятые в шаблоне за `/audit-project`. install.md тупо добавит дублирующую строку. Routing Validator (M3) при первом же запуске выдаст trigger collision как P0 finding на сам себя. Это иронично и сломанно одновременно.»*

**Что происходит при collision:**

1. Пользователь: «проверь офис»
2. Director смотрит routing-patterns.md → находит **два** маппинга:
   - `/audit-project` (старый, через Demiurg)
   - `/office-cleaner` (новый, через Architect-of-Order)
3. Director не знает кому передать. Скорее всего выберет первый по очереди (legacy).
4. Architect-of-Order никогда не запустится из-за collision.

**Решение — миграция:**

```diff
- "проверь офис" / "наведи порядок" / "есть дыры" / "аудит" → /audit-project
+ "проверь офис" / "наведи порядок" → /office-cleaner (scan по умолчанию)
+ "новый аудит структуры" / "deep audit" → /office-cleaner deep
+ "что не так с офисом" → /office-cleaner
- (старая запись /audit-project удаляется или мигрирует на узкие триггеры
   типа «аудит проекта», «проверка перед сборкой»)
```

При установке нового агента — install.md должен **переписать** существующие маппинги, не просто добавить новые рядом.

---

## 4. Второй кейс — два пака маркетологов

**Из аудита client-office-template** (`research/07-audit-client-template.md:157`):

> *«Конфликт триггеров двух паков-маркетологов. `_agent-packs/marketer/install.md` и `_agent-packs/alex-marketer/install.md` оба содержат: маркетинг, маркетолог, ЦА, сегмент, распакуй ЦА. Если клиент скажет «нужен маркетолог» — install-agent не знает кого ставить (по `install-agent/SKILL.md:36-38` маппится только на `marketer`, а `alex-marketer` остаётся скрытым).»*

**Disambiguation step в install-agent.** Из `research/07-audit-client-template.md:165`:

> *«Если по ключевику нашлось 2+ пака — спроси у пользователя.»*

Реализация: в `install-agent/SKILL.md` шаг проверки collision:

```markdown
## Step 3 — Disambiguation

Если по ключевику нашлось 2+ пака:
1. Покажи пользователю список с описаниями
2. Спроси: «Какой ставить — A или B?»
3. Не ставь ничего пока не выберет
```

**Anti-pattern.** Жёстко прописать маппинг в коде: `«маркетолог» → marketer`. При появлении alex-marketer — старая запись блокирует. Решение: маппинг динамический, читается из `_agent-packs/INDEX.md` каждый раз.

---

## 5. Conflict resolution внутри одного агента

В рамках одного агента — приоритет по `agent-state.md` фазе:

```yaml
# agent-state.md
current_stage: stage_1  # JTBD не закрыт
stage_1_critic_passed: false
has_paying_customers: false
```

| Триггер пользователя | Stage | Решение |
|----------------------|-------|---------|
| «упакуй оффер» | stage_1 не закрыта | мягко вернуть в `/jtbd` или `/jtbd-critic`, объяснить что без распакованной ЦА оффер пустой |
| «упакуй оффер» | stage_1_critic_passed: true | запустить `/core-offer` |
| «распакуй ЦА» | has_paying_customers: false | сначала `/custdev` (zero-data gate), потом `/jtbd` |
| «распакуй ЦА» | has_paying_customers: true | сразу `/jtbd` |

Жёстко прописано в `agent-state.md` поле `current_stage`. См. `distilled/agent-design.md` секцию 10.

---

## 6. Уровни роутинга — явный slash vs неявный keyword

| Уровень | Как | Пример | Когда |
|---------|-----|--------|-------|
| **Явный slash-command** | Пользователь печатает `/skill-name` | `/morning`, `/jtbd`, `/office-cleaner` | Когда пользователь знает что делать |
| **Неявный keyword match** | Director роутит на основе семантики triggers | «утро» → `/morning`, «упакуй оффер» → `/core-offer` | Когда пользователь говорит как обычно |

**Семантический поиск через `description:`.** Anthropic (`research/01-youtube-research.md:383`):

> *«The skill's name and description fields are critical since Claude will use these when deciding whether to trigger the skill.»*

Это **роутинг через семантику**, без явных правил.

---

## 7. Routing Validator — один из 6 архетипов уборщика

Из `distilled/governance-cleanup.md` модуль M3.

**Что проверяет:**

1. **Каждый агент достижим.** Есть триггер или явный вызов из Director.
2. **Триггеры не пересекаются.** Если две скилла отвечают на «упакуй оффер» — конфликт.
3. **Стейт-граф `agent-state.md` пройден до конца.** Нет «битых» состояний.
4. **Нет циклов.** Алекс не передаёт в Алекса через посредника.

**Запуск:** еженедельно (пятница) через `/office-cleaner`.

**Output:** список trigger collisions + dead links (`@office/agents/cherry/core.md` есть в CLAUDE.md, файла нет).

---

## 8. Naming convention — kebab-case + role-descriptor

Из `distilled/skill-design.md` секция 6 + `research/02-forums-communities.md:266`:

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

**Из VoltAgent 100+ subagents** (`research/02-forums-communities.md:267`):

> *«Subagents follow consistent patterns: role-descriptor format using hyphens (typescript-pro, devops-engineer, security-auditor). Suffixes indicate specialization levels: '-pro,' '-specialist,' '-expert,' '-architect,' '-engineer.'»*

---

## 9. Routing transparency — debug-mode

Hamel Husain (`research/02-forums-communities.md:340`):

> *«You must remove all friction from the process of looking at data. Build custom viewing tools showing domain-specific context.»*

В переводе: должна быть лёгкая команда «что Director увидел в твоей фразе и куда он хотел роутить». Сейчас этого нет, и пользователь узнаёт о неправильном роутинге только когда Director уже сделал что-то не то.

Реализация (опц): `/debug-routing` — Atlas объясняет почему передал Стратегу, а не Алексу. Можно встроить как часть `/triage`.

---

## 10. AGENTS.md — единственный источник правды о составе команды

**Linux Foundation mid-2025** (`research/01-youtube-research.md:594`). Работает в Claude Code, Cursor, Copilot, Gemini CLI, Windsurf, Aider, Zed.

Если клиент мигрирует с Claude Code на другой инструмент — AGENTS.md в корне переносится без правок. CLAUDE.md остаётся Claude-specific.

**Структура AGENTS.md:**

```markdown
# AGENTS.md — Карта команды

## Активные агенты

| Агент | Роль | Когда зовут | Скиллы |
|-------|------|-------------|--------|
| Director | Оркестратор | первая точка входа | /morning, /triage, /wrap-up |
| Strategist | Распаковка | новый клиент, новый проект | /strategist-* (6 скиллов) |
| Designer | Brand Book | визуал, лендинги | /brand-onboarding, /design-* |
| Architect-of-Order | Порядок офиса | проверь офис, аудит | /office-cleaner (scan/tidy/deep) |
| Alex-marketer (pack) | Маркетинг | распакуй ЦА, оффер | /jtbd, /core-offer, /jtbd-critic |

## Граф передачи задач

Пользователь
  └── Director (все задачи кроме личных)
        ├── Алекс ─→ Producer / Copywriter / Designer / Hermes
        ├── Strategist ─→ /strategist-pipeline
        ├── Demiurg (pack, on-demand) ─→ /build
        └── Architect-of-Order ─→ /office-cleaner
```

**Update protocol.** При установке нового агента через `/install-agent`:
1. Добавить строку в таблицу.
2. Обновить routing-patterns.md.
3. Обновить корневой CLAUDE.md (`@include` если нужен).
4. Обновить director/core.md (роутинг-правила).

См. `research/06-blueprint.md` секция 11.7 для AGENTS.md update формата.

---

## 11. routing-patterns.md формат

Из `client-office-template/office/agents/director/knowledge/routing-patterns.md`:

```markdown
# Routing Patterns

## Core-роутинг

| Запрос пользователя | Агент | Скилл | Комментарий |
|---|---|---|---|
| "проверь офис" / "наведи порядок" | Архитектор офиса | /office-cleaner | scan по умолчанию |
| "новый клиент" / "распакуй меня" | Стратег | /strategist-intake | 8-фазный pipeline |
| "распакуй ЦА" / "JTBD" | Алекс (pack) | /jtbd | если has_paying_customers |
| "упакуй оффер" | Алекс | /core-offer | если stage_1_critic_passed |
| "новый проект" | Director | /new-project | создаёт скелет |
| "разбери инбокс" | Director | /triage | через Revenue Filter |

## Triage Tier rules

Tier 1 (revenue): клиент, КП, продажа, оффер
Tier 2: контент, лендинг, лид-магнит
Tier 3: фича, продукт, платформа, деплой
Tier 4: операционка, изучение, рефакторинг (запрещён пока есть Tier 1)

## Phase Lock

Stage 1 (JTBD) не закрыта → возврат в /jtbd-critic при попытке Stage 2
Stage 2 (Core Offer) не закрыта → возврат в /core-offer при попытке Stage 3
```

---

## 12. /triage и /intake — не пропустить входящие

**`/triage` запускается:**
- При новой сессии если `inbox/_new/` >= 1 файл — Director сам предлагает.
- При утреннем `/morning`.
- По запросу «что в инбоксе».

**`/intake`** — классифицирует файлы из inbox в правильные папки:

| Тип материала | Куда кладём |
|---------------|-------------|
| Конкурент | `intel/competitors-osh/{slug}.md` |
| Клиентский кейс | `clients/{slug}/` |
| Методология | `methodology/{slug}.md` |
| Продуктовая гипотеза | `product/{slug}.md` |
| Deep research | `research/{slug}.md` |
| Бренд-материал | `brand/{slug}.md` |
| Аудио встречи | `clients/{slug}/calls/` |
| Голосовые заметки | `inbox/` или `intake/` |
| Всё остальное | `inbox/` + спросить |

Полная таблица в `knowledge/CLAUDE.md`.

---

## 13. Реальные косяки роутинга в шаблоне

Из аудита (`research/07-audit-client-template.md:142-167`):

1. **Hardcoded маппинги к несуществующим пакам.** `«копирайтер» → copywriter` когда у `copywriter` нет `install.md`. Клиент скажет «нужен копирайтер» — получит «нет такого пака», хотя в коде он прописан.

2. **Routing-patterns.md НЕ упоминает Алекса-Маркетолога.** Если поставить — Director не знает что Алекс есть пока не пройдёт `install-agent`-фаза с автоматическим обновлением routing-patterns.md.

3. **Дизайнер триггеры без оговорки «если установлен».** Designer **может быть и не установлен** (хотя CLAUDE.md его включает в layered include).

4. **Нет `/triage`-скилла** — разбора входящих задач через Revenue Filter.

5. **Нет «выходов» Phase Lock.** Если клиент в середине стратегии говорит «хочу пост написать» — что делает Director? Не описано.

См. `distilled/failures-to-avoid.md` для полного списка.

---

## 14. Цитаты-якоря

- Owen Fox: *«If a rule applies to nearly every task, put it in CLAUDE.md. If it's a specific workflow that only matters sometimes, make it a Skill.»* (`research/02-forums-communities.md:208`)
- Anthropic: *«The skill's name and description fields are critical since Claude will use these when deciding whether to trigger the skill.»* (`research/01-youtube-research.md:383`)
- Hamel Husain: *«You must remove all friction from the process of looking at data.»* (`research/02-forums-communities.md:340`)
- VoltAgent (100+ subagents): *«Subagents follow consistent patterns: role-descriptor format using hyphens.»* (`research/02-forums-communities.md:267`)

---

## Источники

- `research/2026-05-04-office-architecture/02-forums-communities.md:200-294` — принципы роутинга и naming
- `research/2026-05-04-office-architecture/06-blueprint.md:604-657` — секция 7 РОУТИНГ
- `research/2026-05-04-office-architecture/07-audit-client-template.md:142-167` — аудит роутинга в шаблоне
- `research/2026-05-04-office-architecture/08-reviewer-report.md:34-63` — реальный trigger collision
- `research/2026-05-04-office-architecture/04-governance-cleanup-agents.md:94-104` — Routing Validator

## Связанные дистилляты

- `distilled/skill-design.md` — frontmatter, anti-triggers
- `distilled/agent-design.md` — handoff между агентами
- `distilled/governance-cleanup.md` — Routing Validator (M3)
- `distilled/failures-to-avoid.md` — collision триггеров, hardcoded маппинги
