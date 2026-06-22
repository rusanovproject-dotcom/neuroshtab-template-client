---
title: 10 главных принципов AI-офиса
updated: 2026-05-05
source_research: 2026-05-04-office-architecture
status: live
---

# 10 главных принципов AI-офиса

> Дистиллят executive summary из BLUEPRINT и FINAL-REPORT. Читать ПЕРЕД проектированием офиса с нуля или крупным рефакторингом существующего.

Это не дисциплинарный список, это **фильтры решений**. Каждый раз когда добавляешь агента, скилл, протокол, MCP — прогон через эти 10. Не проходит — не добавляем.

---

## 1. Vanilla > custom

**Суть.** Не кастомизируй то что и так работает out-of-the-box. Custom только там где видно конкретную дыру в первый день у клиента.

**Почему так.** Boris Cherny (Head of Claude Code, Anthropic): *«My setup might be surprisingly vanilla! Claude Code works great out of the box, so I personally don't customize it much.»* Каждая кастомная строка съедает контекст и плодит долг — без неё могло бы работать.

**Как проверить.** Перед добавлением — спроси «эта штука решает реальную боль клиента или это decoration?». Если decoration — убирай.

**Anti-pattern.** «У нас 17 агентов потому что в идеальном офисе их должно быть много». Нет. У эталона 4-7 базовых агентов в ядре, остальное — паки по запросу.

---

## 2. Folder structure = context engineering

**Суть.** Сама файловая иерархия учит Claude где что искать. Никаких декоративных папок без `INDEX.md`. Папка с 3+ файлами обязана иметь `INDEX.md` — это часть Definition of Done.

**Почему так.** Anthropic: *«The folder and file structure of an agent becomes a form of context engineering.»* (`research/01-youtube-research.md:402`). Кастом-аватаром структуры офиса экономишь токены на routing-rules.

**Как проверить.** Запусти `find . -type d -mindepth 1 -maxdepth 3` — для каждой папки с >3 файлами должен быть INDEX.md. Если нет — добавь или удали папку.

**Anti-pattern.** «Создал папку `research/` и положил туда 5 файлов. INDEX.md потом сделаю.» Потом не делается. Создаёшь папку — сразу INDEX.

---

## 3. Layered memory обязательна

**Суть.** Каждый агент имеет 5 файлов: `core.md` (template), `soul.md` (характер), `overrides.md` (пользователь), `memory.md` (append-only от агента), `failures.md` (append-only). Плюс `CLAUDE.md` склейка.

**Почему так.** Без слоёв память агента — статичный промпт без обучения. Слои дают раздельные владельцы (template vs пользователь vs агент), append-only защищает от потери, `failures.md` обеспечивает compound learning.

**Как проверить.** В каждом `office/agents/<name>/` должны быть все 5 файлов + CLAUDE.md. `failures.md` каждого агента — не пустой шаблон, а минимум 1-2 затравочные записи реальных кейсов.

**Anti-pattern.** Все `failures.md` пустые с заглушкой «(пока пусто)». Это значит обучаемость нулевая. См. `distilled/memory-architecture.md` и `distilled/failures-to-avoid.md` секцию «пустые failures.md».

---

## 4. Hook = детерминизм. Skill = workflow с триггером. Subagent = изоляция

**Суть.** Когда что использовать — единая ментальная модель:

```
Hook       = детерминизм («каждый раз когда X»)
Skill      = workflow с триггером («когда юзер просит Y»)
Subagent   = изоляция контекста + параллельность («исследуй и верни report»)
CLAUDE.md  = правила, применимые везде
MEMORY.md  = усвоенный опыт, грузится в начало
Agent      = долгоживущая роль с памятью, скиллами, knowledge
```

**Почему так.** Owen Fox (`research/02-forums-communities.md:208`) и Dean Blank (там же:211): *«If a rule applies to nearly every task, put it in CLAUDE.md. If it's a specific workflow that only matters sometimes, make it a Skill. Add hooks when you need deterministic enforcement. Use subagents when parallel work or context isolation matters.»*

**Как проверить.** Решающий вопрос: надо ли это **детерминированно**? — hook. Только когда юзер сам попросит? — skill. Параллельно/в изоляции? — subagent. Правило везде? — CLAUDE.md.

**Anti-pattern.** Сделать «чтобы при каждом старте читало контекст» — через скилл. Не сработает: скилл вероятностный, hook детерминированный.

См. `distilled/skill-design.md`, `distilled/tools-mcp-stack.md`.

---

## 5. Двухуровневая иерархия Director → лиды → специалисты

**Суть.** Не плоский список 17 равных агентов. Director (Atlas) → 4-7 базовых лидов → внутри лида свои скиллы и под-фазы. Лиды дальше могут спавнить специалистов параллельно.

**Почему так.** Anthropic research: **+90.2% performance** от sub-agents с изолированным контекстом vs single-agent (`research/02-forums-communities.md:230`). Codebridge: *«Hierarchical Delegation: Instead of an orchestrator spawning multiple subagents which fragments its context, spawn feature leads that spawn their own specialists, with the parent orchestrator only talking to two agents.»* (`research/02-forums-communities.md:225`).

**Как проверить.** Director не разговаривает с 17 агентами напрямую. Передаёт задачу одному лиду, дальше внутри агента свои скиллы. Атлас → Алекс-маркетолог → JTBD/CustDev/critic. Атлас → Стратег → intake/unpack/discovery.

**Anti-pattern.** Атлас сам диспетчирует 17 параллельных задач. Контекст фрагментируется, специалисты получают irrelevant history (context explosion).

См. `distilled/agent-design.md`, `distilled/routing-triggers.md`.

---

## 6. Builder + Validator паттерн без write-доступа

**Суть.** Для каждого критичного артефакта — пара: Builder делает, Validator проверяет. У Validator'а **нет write-доступа** (`tools: Read, Grep, Glob` в frontmatter). Без write он не может «починить незаметно» и становится честной QA.

**Почему так.** Disler (`research/01-youtube-research.md:339`): *«Subagents без write-доступа = quality assurance pattern. Validator не может фиксить, только репортить — это превращает его в честного проверяющего.»* Реальный кейс этого исследования: Демиург выставил себе self-score 92/100, независимый ревьюер реальный 74/100. Дельта 18 пунктов. Self-review не заменяет independent review (`research/08-reviewer-report.md:475`).

**Как проверить.** Любой код > 50 строк, продающий артефакт, агент, скилл, методология — обязательно через ревьюера с чистым контекстом. Score gates: <60 FAIL, 60-79 NEEDS WORK, ≥80 PASS.

**Anti-pattern.** «Я сам себя проверил, всё ок.» Проходишь свой же тест — слепые пятна остаются. Демиург не сделал dogfooding (не запустил собственный `/office-cleaner scan` на своём паке) — пропустил 4 P0 блокера.

См. `distilled/builder-validator.md`.

---

## 7. Жёсткие лимиты на размер файлов

**Суть.** Каждая строка в контекст-файле конкурирует с реальной работой за внимание. Лимиты:

| Файл | Лимит | Источник |
|------|-------|----------|
| Корневой `CLAUDE.md` | ≤200 строк | `02-forums-communities.md:255` |
| Агентский `core.md` | ≤200 строк | `04-governance-cleanup-agents.md:216` |
| Агентский `soul.md` | ≤150 строк | блюпринт |
| `.claude/MEMORY.md` | ≤200 строк | Anthropic auto-load лимит |
| Главный `memory.md` агента | ≤500 токенов | Anubhav `01-youtube-research.md:457` |
| Субагент-промпт | ~30 строк | Anubhav (там же) |
| `SKILL.md` | ≤500 LOC | `04-governance-cleanup-agents.md:217` |
| `failures.md` | без лимита (append-only feature) | — |

**Почему так.** Generative.inc: *«Every line in CLAUDE.md competes for attention with the actual work.»* (`research/01-youtube-research.md:528`). Anubhav 6 месяцев тюнил Claude Code в проде: *«The main memory file is under 500 tokens on purpose.»* MEMORY.md ≤200 — жёсткий технический лимит Anthropic auto-load (`research/02-forums-communities.md:30-36`): первые 200 строк подтягиваются автоматически, остальное — lazy.

**Как проверить.** `wc -l` по всем core.md, soul.md, CLAUDE.md. Превышение → выноси «Стек инструментов» и «Edge cases» в `knowledge/<agent>/`.

**Anti-pattern.** Designer 301 строка, Alex 327. Сами же aудит-чеки сфейлятся.

---

## 8. Compaction агрессивно (60%, не 95%)

**Суть.** Делай `/compact` на 60% контекста, не жди auto-compact на 83.5%. На 60% Claude ещё имеет полный uncompressed access.

**Почему так.** mindstudio.ai (`research/02-forums-communities.md:81`): *«The better approach: compact at around 60% context utilization, before quality starts degrading. Most people use it wrong, waiting until the context window is nearly full instead of treating it as a proactive tool.»*

**Как проверить.** В CLAUDE.md шаблона добавь правило: *«When compacting, always preserve the full list of modified files and any test commands»* (`02-forums-communities.md:84`). Можно автоматизировать через PreCompact hook + nudge при 60%.

**Anti-pattern.** Ждать пока контекст забьётся до 95%. Качество ответов начинает деградировать на 70-80%, к 95% Claude уже путает что было раньше.

См. `distilled/memory-architecture.md`.

---

## 9. Vector DB не нужен — markdown + skills с lazy-load закрывают 95%

**Суть.** Markdown-файлы для памяти, skills для capabilities, hooks для persistence. Vector DB подключай только когда корпус заметок > 10 000 документов и нужен semantic search.

**Почему так.** Cole Medin (`research/01-youtube-research.md:171`): *«Markdown files for memory, Claude Code skills for capabilities, hooks for persistence, and a Claude Agent SDK heartbeat for proactive action — with no vector databases or complex orchestration frameworks.»* Доказано на проде Second Brain.

**Как проверить.** Сколько у тебя заметок? Меньше 10K? Используй grep + lazy-load skills через `description:` в frontmatter. Больше 10K? Тогда pgvector / Chroma / Qdrant.

**Anti-pattern.** «Подключим Pinecone сразу, на вырост.» Пинекон сожрёт контекст инфраструктурой, а на 50 заметках работает хуже чем grep.

---

## 10. Compound learning loop через append-only failures.md

**Суть.** Каждая ошибка → запись в `failures.md` агента с правилом-выходом. Grep по `failures.md` перед каждой задачей агента. Срыв scope = обязательная запись в `failures.md` ДО продолжения работы.

**Почему так.** Boris Cherny (`research/01-youtube-research.md:50`): *«Anytime we see Claude do something incorrectly we add it to the CLAUDE.md, so Claude knows not to do it next time.»* Kieran Klaassen Compound Engineering: *«Treat every task as an investment so the next time is faster.»* (`research/01-youtube-research.md:139`). Append-only защищает от потери опыта, grep перед задачей блокирует повтор.

**Как проверить.** В `core.md` каждого агента есть правило «grep по failures.md перед задачей». В CI/pre-commit или в hook PostToolUse — проверка что после ошибки была дописана запись. Пустые `failures.md` через 7+ дней работы офиса — обучение не работает.

**Anti-pattern.** Failures.md есть формально, но никто не пишет. Или одна заглушка «(пока пусто)». Или мета-кейсы вместо реальных. См. `distilled/failures-to-avoid.md`.

---

## Bonus: Algorithm перед добавлением

Любое новое: агент / скилл / протокол / MCP / hook — прогон через 5 фильтров (из `office/agents/director/core.md`):

```
QUESTION → DELETE → SIMPLIFY → ACCELERATE → AUTOMATE
```

1. **Question.** А действительно ли это нужно?
2. **Delete.** Можно ли вместо этого что-то удалить?
3. **Simplify.** Можно ли упростить вместо добавления?
4. **Accelerate.** Сделает ли это работу быстрее?
5. **Automate.** Если да — автоматизируй через hook, иначе оставь skill.

Если шаг 1-3 убил идею — не добавляешь. Если выжила — иди дальше.

---

## Источники

- `research/2026-05-04-office-architecture/FINAL-REPORT.md` — executive summary
- `research/2026-05-04-office-architecture/06-blueprint.md:13-21` — 7 железных принципов
- `research/2026-05-04-office-architecture/01-youtube-research.md:646-671` — 10 железных принципов синтеза
- `research/2026-05-04-office-architecture/02-forums-communities.md:286-294` — ранжирование принципов
- `research/2026-05-04-office-architecture/08-reviewer-report.md:475` — урок про self-review

## Связанные дистилляты

- `distilled/memory-architecture.md` — детали лимитов и compaction
- `distilled/agent-design.md` — структура агента
- `distilled/skill-design.md` — когда скилл vs hook vs subagent
- `distilled/builder-validator.md` — паттерн ревью
- `distilled/failures-to-avoid.md` — что НЕ делать
