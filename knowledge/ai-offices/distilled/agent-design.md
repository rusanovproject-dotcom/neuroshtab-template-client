---
title: Проектирование агентов
updated: 2026-05-05
source_research: 2026-05-04-office-architecture
status: live
---

# Проектирование агентов

> Дистиллят по агентам: 5-файловая структура, лимиты, frontmatter, soul vs core, output contract, Builder/Validator. Читать ПЕРЕД сборкой/правкой агента.

Главная мысль: **агент — это долгоживущая роль с памятью, скиллами и knowledge.** Агент строится **вокруг знаний**, а не знания подгоняются под агента (`research/03-internal-knowledge.md:193`). Структура файлов агента — это context engineering, она учит Claude где что искать.

---

## 1. Структура агента — 5 файлов + CLAUDE.md склейка

Эталонная структура `office/agents/<name>/`:

```
office/agents/<name>/
├── CLAUDE.md       # склейка @core.md @overrides.md (@soul.md если есть) — НЕ трогать
├── core.md         # ядро роли: что делает, как работает, output, ≤200 строк
├── soul.md         # характер, голос, душа, ≤150 строк (опц)
├── overrides.md    # личные правила пользователя — агент НЕ трогает
├── memory.md       # APPEND-ONLY: Decisions / Patterns / Context — пишет агент после задач
├── failures.md     # APPEND-ONLY: журнал ошибок и правил-выходов — grep перед задачей
├── knowledge/      # rag-материалы агента (методологии, примеры, edge-cases)
│   ├── INDEX.md
│   └── <topic>.md
└── skills/         # скиллы агента (если есть свои)
    └── <skill-name>/SKILL.md
```

**Закон файлов** (из client-office-template/CLAUDE.md):

| Файл | Кто пишет | Что туда |
|------|-----------|----------|
| `core.md` | Демиург при создании / `/build` | Идентичность, роль, процесс, output contract |
| `soul.md` | Демиург при создании | Характер, голос, биография — НЕ дублирует identity из core |
| `overrides.md` | **Пользователь** | Личные правила, агент НЕ трогает при `/update-office` |
| `memory.md` | **Агент сам** после задач | Decisions / Patterns / Context (append-only) |
| `failures.md` | **Агент сам** после фейлов | YYYY-MM-DD → что предположил → что оказалось → правило (append-only) |
| `CLAUDE.md` | Генерится один раз | Просто склейка `@core.md @overrides.md @soul.md` — НЕ трогать |

**Принципиально:** разделение писатель → читатель. CLAUDE.md = пишет человек/template, читает Claude каждую сессию. memory.md = пишет Claude, фиксирует learnings. overrides.md = пишет пользователь, защищён от обновлений ядра.

---

## 2. Frontmatter агента — обязательные поля

```yaml
---
name: alex-marketer
description: |
  Маркетолог-навигатор. Находит точку приложения усилий
  где деньги жирные именно для этого клиента. Hormozi operating
  system (Рынок > Оффер > Копия), JTBD-методология.

  TRIGGERS: маркетинг, маркетолог, ЦА, сегмент, распакуй ЦА,
  оффер, упакуй оффер, найди сегменты, провёл диагностику
  ANTI-TRIGGERS: новый клиент в продажах → Hermes; контент → Copywriter
reports_to: Director
model: opus
tools: Read, Write, Edit, Bash, Grep, Glob, Agent
mcp: Notion, Memory
version: v3.1.1
updated: 2026-05-04
disable-model-invocation: false
---
```

**Жёсткие лимиты на identity-блок:** ≤300 токенов (Anubhav `research/01-youtube-research.md:457`). Если у тебя в `description` 500 строк — это не frontmatter, это монолог. Сжимай.

**`disable-model-invocation: true`** — для агентов которые опасно запускать на автомате. Architect-of-Order должен иметь `disable-model-invocation: true` (`research/04-governance-cleanup-agents.md:420`) — иначе будет дёргаться при каждом упоминании «порядок» в чате.

---

## 3. Лимиты — каждая строка конкурирует за внимание

| Файл | Лимит | Что делать при превышении |
|------|-------|---------------------------|
| `core.md` | ≤200 строк | Стек инструментов / edge-cases → `knowledge/<agent>/` |
| `soul.md` | ≤150 строк | Не дублируй identity из core, soul — биография |
| `memory.md` (главный) | ≤500 токенов | Старое → `_archive/<date>/`, индекс в `memory.md` |
| `failures.md` | без лимита (append-only feature) | Pattern detector раз в неделю → правило в core.md |
| Identity-блок описания | ≤300 токенов | Сжимай до сути роли |

**Реальный пример провала** (`research/07-audit-client-template.md:226-228`):

> *«designer/core.md 301 строка при правиле ≤200. alex-marketer/core.md 327 строк — превышение ≤200, ≤300. Сами же aудит-чеки сфейлятся.»*

Architect-of-Order при первом запуске зафлагит свой собственный 213-строчный core.md как oversize если в нём прописано «core.md ≤200 строк». Сам себя сфейлит.

**Что выносить из core.md** (типичные кандидаты ≥30 строк):
- Anti-patterns checklist → `knowledge/<agent>/anti-patterns.md`
- Подробные методологии → `knowledge/<agent>/methodology.md`
- Edge cases / стек инструментов → `knowledge/<agent>/edge-cases.md`
- 8-мерные рубрики → `knowledge/<agent>/rubric.md`

В core оставить: идентичность, когда зовут, как работаешь (1-2 параграфа), output contract, память (правила), связки, guardrails. Всё остальное — references на knowledge.

---

## 4. core.md vs soul.md — разделение характера и процесса

**core.md = что делает, как работает.** Технический документ. Структура унифицирована:
- Идентичность (3-5 строк)
- Когда зовут (триггеры)
- Pre-flight (что читать перед задачей)
- Pipeline (фазы работы)
- Output contract (что возвращает)
- Память (правила записи в memory/failures)
- Связки (от кого получает, кому передаёт)
- Guardrails (запреты)

**soul.md = характер, голос, душа.** Это **биография**, не extended core.

Хороший пример — `_agent-packs/alex-marketer/soul.md` (96 строк): «3 круга жирной ЦА», «как работаю», «почему не лезу с советами», «3 книги в голове», чего не делаешь.

Плохой пример (`research/08-reviewer-report.md:251`): `architect-of-order/soul.md` повторяет identity из core (*«Спокойный, точный, без иронии. Видишь каждую запятую»* — есть и в core строка 33-34, и в soul строка 96-100). Soul пустой как самостоятельный документ.

**Правило симметрии.** Либо у всех 4 базовых агентов есть soul.md, либо ни у одного. Несогласованность (только у Demiurg есть soul.md, у трёх остальных нет — `research/07-audit-client-template.md:218`) — антипаттерн.

---

## 5. Двухуровневая иерархия — Director → лиды → специалисты

```
Пользователь
  └── Director (Atlas)              ← оркестратор, первая точка входа всегда
        ├── Strategist               ← 8-фазный pipeline (intake → roadmap)
        ├── Designer                 ← Brand Book + Claude Design / Code
        ├── Architect-of-Order       ← порядок, аудит, уборка
        ├── (alex-marketer)          ← из пака: маркетинг
        ├── (copywriter)             ← из пака: тексты
        └── (Demiurg)                ← из пака: только когда нужна сборка
```

**Не плоский список 17 равных.** Director не разговаривает с 17 агентами — он передаёт задачу одному, дальше внутри агента свои скиллы и под-фазы.

**Anthropic research:** *«+90.2% performance gain over single-agent Opus by distributing work across Sonnet subagents with isolated context windows.»* (`research/02-forums-communities.md:230`)

**Hierarchical Delegation для сложных задач** (Codebridge, `research/02-forums-communities.md:225`):

> *«Instead of an orchestrator spawning multiple subagents which fragments its context, spawn feature leads that spawn their own specialists, with the parent orchestrator only talking to two agents, keeping its context clean.»*

Для шаблона клиента в 95% случаев достаточно 2 уровней. 3-й уровень (specialists под feature leads) — для очень сложных задач.

**Anti-pattern.** Атлас сам диспетчирует 17 параллельных задач. Контекст фрагментируется (context explosion). Cab Wu (Anthropic): *«Smaller models with focused context outperform a single large model carrying full session history.»*

---

## 6. Output contract — что возвращает агент

В каждом core.md секция «Output contract» — какой формат отдачи.

5 форматов из core.md Алекса-маркетолога:

> *«Любой ответ клиенту — одно из 5:*
> 1. **Диагноз** — «вот что я увидел, 3 проблемы, приоритет»
> 2. **Развилка** — «3 варианта, моя рекомендация, выбирай»
> 3. **Челлендж** — «твоя гипотеза противоречит данным, давай пересмотрим»
> 4. **Согласование** — «собираюсь распаковать Z, согласен?»
> 5. **Отдача** — «вот артефакт, ключевые находки, следующий шаг»
>
> *Не пиши бесструктурный текст. В живом диалоге — есть цель, есть выход.»*

**Зачем.** Output contract превращает «Claude отвечает что-то» в «Claude отвечает в одном из 5 предсказуемых форматов». Пользователь сразу понимает что ждать. Director знает что вернётся, может встроить в дальнейший workflow.

**Anti-pattern.** «Я просто отвечу как смогу» — сегодня диагноз, завтра развилка, послезавтра поток сознания. Невозможно встроить в pipeline.

---

## 7. Builder + Validator паттерн — обязателен для критичных артефактов

**Главное правило** (Disler `research/01-youtube-research.md:339`):

> *«Subagents без write-доступа = quality assurance pattern. Validator не может фиксить, только репортить — это превращает его в честного проверяющего.»*

**Builder** — все инструменты, делает фичу.
**Validator** — `tools: Read, Grep, Glob` (read-only), проверяет.

В шаблоне уже есть пары:
- `/jtbd` (Builder) ↔ `/jtbd-critic` (Validator, новый чат, чистый контекст)
- `/build` (Demiurg) ↔ `validate-agent.sh` + LLM Validator
- agent-quality-reviewer как universal validator для агентов

**Когда обязателен:** код > 50 строк, продающий артефакт, агент, скилл, методология. Подробнее → `distilled/builder-validator.md`.

**Реальный кейс ущерба от self-review** (`research/08-reviewer-report.md:475`):

> *«Demiurg выставил себе self-score 92/100. Реальный — 74/100 после независимого ревью. Дельта 18 пунктов. Завышение системное — Demiurg смотрел изнутри пака, не на пересечение с шаблоном (P0-1, P0-3). Self-review не заменяет independent review.»*

---

## 8. Knowledge-First принцип

Из Demiurg core (`research/03-internal-knowledge.md:193`):

> *«Агент строится ВОКРУГ знаний, не знания подгоняются.»*

8-фазный конвейер `/build`: `INTAKE → BRIEF → SCOUT → KNOWLEDGE → BUILD → VALIDATE → ITERATE → WIRE`.

**SCOUT и KNOWLEDGE идут ДО BUILD.** Без знаний — агент пустой. Score knowledge-фазы <5 → **БЛОКЕР сборки**.

В реальности это значит:
- Перед сборкой Алекса-маркетолога — собрана JTBD-handbook (102K), methodology-core (21K), etalon-jobstories (13K). Это серьёзная knowledge-база, без которой Алекс был бы пустышкой.
- Перед сборкой Architect-of-Order — собраны florian-rubric.md, failure-archetypes.md, cleanup-anti-patterns.md, auto-dream-rules.md. 5 файлов knowledge.

**Anti-pattern.** Собрать агента из общих фраз без научной базы. Агент станет пустышкой и через 2 недели его заменят на ChatGPT.

---

## 9. Self-trigger rules — when-then автоматизация

В core агента — секция «Self-trigger rules»: 5-15 if-then правил автоматизации, которые агент выполняет без напоминания.

Пример из Демиурга (`research/03-internal-knowledge.md:200`):

```
- IF получил задачу собрать агента → ВСЕГДА начать с /scout (если ещё не было)
- IF score knowledge-фазы <5 → БЛОКЕР, не идти в Build
- IF Build завершён → ВСЕГДА Validate (validate-agent.sh + LLM)
- IF Validate score <60 → FAIL, итерация невозможна
- IF Validate score 60-79 → NEEDS WORK, max 2 iterate
- IF Validate score >=80 → PASS, идти в WIRE (AGENTS.md, CLAUDE.md, routing)
```

**Зачем.** Снимает ответственность с пользователя помнить что после Build идёт Validate. Агент сам срабатывает на состояние.

**Anti-pattern.** Все шаги вручную дёргать. Пользователь забывает Validate, агент уходит в прод с багами.

---

## 10. Hardware ограничения — Pre-flight перед задачей

В каждом core.md — секция «Pre-flight» (читать перед любым ответом):

```
1. agent-state.md — активный клиент, проект, Stage, был ли interrupted
2. memory.md — Decisions/Patterns/Context
3. failures.md — grep по ключевым словам задачи
4. soul.md — характер
5. client-profile.md — профиль владельца офиса
6. projects/<main>/hypotheses.md — текущие гипотезы
7. projects/<main>/inbox/_new/ — что свежего
```

**Внутренняя проверка молча, не в чат:** убедись что прочитал memory + failures + agent-state. Если их нет — создай из шаблонов первым действием. **НЕ произноси клиенту** «прочитал память» / «failures» / «agent-state» — это нарушает живую речь.

**Anti-pattern** (`research/03-internal-knowledge.md:124`):

> *«failures.md grep перед задачей обеспечивает не-повторение ошибок. НО — production ai-office-v2 НЕ использует failure.md систематически. Многие агенты (17 штук) не заполняют memory.md даже на проде.»*

Pre-flight без content в файлах = бесполезный ритуал.

---

## 11. Antipattern: один большой агент vs специализированные

**Один большой агент** (anti-pattern):
- 17 разных функций в одном core.md (3000 строк)
- Контекст всегда забит
- Триггеры неоднозначны
- Невозможно ревьюить (Builder = тот же что Validator)

**Специализированные** (правильно):
- Каждый агент решает 1 класс задач
- Изоляция контекста через subagent-вызовы
- Чёткие триггеры, без collision
- Builder/Validator пары независимы

**Sankalp aргумент против subagents** (`research/02-forums-communities.md:465`):

> *«Важно чтобы модель прошла по релевантным файлам сама, чтобы весь ингестированный контекст мог attend друг к другу.»*

Для **сложного кодинга** — иногда лучше один умный, чем три специализированных. Но для **смешанной команды (маркетинг + dev + контент)** — однозначно специалисты с раздельным контекстом.

---

## 12. Реальные примеры качественных агентов

Изучить как эталоны (детали в `research/03-internal-knowledge.md`):

- **Strategist** в client-office-template — 8-фазный pipeline (`INTAKE → UNPACK → DISCOVERY → PREPARE → IDEAS → DISTILLATION → ROADMAP → HANDOFF + WEEKLY CHECK-IN`). Лучше чем в продакшене.
- **Demiurg** в client-office-template — 8-фазный конвейер `/build` с Knowledge Mining как блокер.
- **Designer** с Brand Book onboarding скиллом и каталогом 10 типов дизайнов.
- **Alex-marketer** v3.1.1 — JTBD-pipeline, 5 фаз, soul.md (96 строк) с тремя кругами и тремя книгами.
- **Architect-of-Order** — 6 архетипов уборщиков в одном агенте, 3 режима (scan/tidy/deep), Florian rubric. Built в этом исследовании.

---

## 13. Цитаты-якоря

- Disler: *«The #1 misunderstanding when creating agents is treating agent files as user prompts. They are system prompts configuring behavior when the primary agent delegates work.»* (`research/01-youtube-research.md:312`)
- Anubhav: *«The main memory file is under 500 tokens on purpose. Subagent definitions are maybe thirty lines each.»* (`research/01-youtube-research.md:457`)
- Codebridge: *«Hierarchical Delegation: spawn feature leads that spawn their own specialists, with the parent orchestrator only talking to two agents.»* (`research/02-forums-communities.md:225`)
- Demiurg: *«Агент строится ВОКРУГ знаний, не знания подгоняются.»* (`research/03-internal-knowledge.md:193`)

---

## Источники

- `research/2026-05-04-office-architecture/01-youtube-research.md:310-340` — Disler builder/validator
- `research/2026-05-04-office-architecture/02-forums-communities.md:223-294` — иерархия и принципы
- `research/2026-05-04-office-architecture/03-internal-knowledge.md:60-78` — layered memory агента
- `research/2026-05-04-office-architecture/06-blueprint.md:436-470` — иерархия офиса блюпринта
- `research/2026-05-04-office-architecture/07-audit-client-template.md:206-241` — реальные косяки агентов
- `research/2026-05-04-office-architecture/08-reviewer-report.md:148-200` — лимиты, дубли, soul vs core

## Связанные дистилляты

- `distilled/10-principles.md` — принципы 5 (иерархия), 6 (Builder/Validator), 7 (лимиты)
- `distilled/memory-architecture.md` — детали memory.md/failures.md
- `distilled/skill-design.md` — скиллы агента
- `distilled/builder-validator.md` — паттерн ревью
- `distilled/routing-triggers.md` — handoff между агентами
- `distilled/failures-to-avoid.md` — реальные ошибки в дизайне агентов
