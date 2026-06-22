---
title: Методологии и стандарты архитектуры AI-офисов
updated: 2026-05-05
source_research: 2026-05-04-office-architecture
---

# Методологии и стандарты

Подборка методологий из публичных источников, которые применимы к шаблону AI-офиса. Внутренние методологии (Алекс / Стратег / Director) — не здесь, они в `office/`. Источники — `research/2026-05-04-office-architecture/01-youtube-research.md`, `02-forums-communities.md`, `04-governance-cleanup-agents.md`, `06-blueprint.md`.

---

## 1. Compound Engineering — Plan → Work → Assess → Compound

- **Автор / источник:** Kieran Klaassen (Cora, ex-37signals), Compound Engineering plugin для Claude Code от Every.to
- **Суть:** 4-фазный цикл работы над любой задачей, в котором каждая итерация делает следующую быстрее. Plan: суб-агенты параллельно ресёрчат codebase, best practices, версии фреймворков **до** написания кода. Work: Claude задаёт уточняющие вопросы → строит фичу → пишет тесты по плану. Assess: review-агенты проверяют security, architecture, code quality → triage по приоритету. Compound: захват learnings в доки, которые Claude прочитает в следующий раз. «Treat every task as an investment so the next time is faster».
- **Как применить у нас:** встроить 4-фазный цикл в `/plan` + `/implement` + `/review` + `/wrap-up`. Compound-фаза реализуется через append-only `failures.md` и `memory.md` каждого агента. Custom skills как just-in-time context — подгружаются только когда нужны.
- **Ссылка:** [creatoreconomy.so/p/how-to-make-claude-code-better-every-time-kieran-klaassen](https://creatoreconomy.so/p/how-to-make-claude-code-better-every-time-kieran-klaassen)

---

## 2. Spec-First Interview — собрать SPEC.md, потом работать только по нему

- **Автор / источник:** Harper Reed (адаптация Andrej Karpathy), упоминается в Generative.inc Complete Guide 2026
- **Суть:** для крупных размытых задач — отдельная сессия только для сбора требований через интервью «один вопрос за раз». Результат — `SPEC.md`. Имплементация идёт в новой сессии с чистым контекстом, читая только SPEC.md. Не смешиваешь сбор требований с работой — контекст не загрязняется обсуждением.
- **Как применить у нас:** скилл `/interview` уже есть — сделать его **триггером по умолчанию** для нового клиента, большой фичи, размытой задачи. После SPEC.md — новая сессия с чистым контекстом. Включена в Workspace CLAUDE.md секцию «Interview-me для крупных/размытых задач».
- **Ссылка:** [Generative.inc Complete Guide 2026](https://www.generative.inc/the-complete-claude-code-guide-2026-planning-context-engineering-and-high-leverage-development)

---

## 3. Builder + Validator — read-only QA-партнёр

- **Автор / источник:** Dan Disler (IndyDevDan), репо `claude-code-hooks-mastery`
- **Суть:** для каждого агента-исполнителя заводится парный валидатор без write-доступа. Builder делает фичу со всеми инструментами. Validator имеет только Read/Grep/Glob — может репортить, но не может фиксить. Это превращает QA в честный механизм: валидатор не «втянут» в задачу, потому что лишён возможности её решить. Subagent отдаёт только final report наверх — intermediate output живёт в его контексте.
- **Как применить у нас:** `/jtbd-critic` уже работает по этому паттерну (новый чат, чистый контекст, только чтение). Распространить на других агентов: `marketer-validator`, `strategist-critic`, `copy-validator`. Все скиллы-проверяющие — без `Edit` и `Write` в `tools:`.
- **Ссылка:** [github.com/disler/claude-code-hooks-mastery](https://github.com/disler/claude-code-hooks-mastery), `.claude/agents/team/validator.md`

---

## 4. AutoDream — консолидация памяти раз в день

- **Автор / источник:** AutoDream (Zen van Riel, Anthropic memory tool), описано в `04-governance-cleanup-agents.md`
- **Суть:** background sub-agent, консолидирующий память Claude Code между сессиями — так же как биологическая память консолидируется во сне (REM). Запускается по правилу `≥24h && ≥5 sessions`. Удаляет только идентичные дубли; противоречия и stale entries складывает в `pending_review` для человека. Hard cap: 8-10 минут на цикл. Manual override через команду `dream`.
- **Категории работы (4):** redundancy (дубли), contradictions (противоречия), stale timestamps (устаревшие даты), outdated debugging notes (неактуальные debug-записи).
- **Как применить у нас:** Architect-of-Order реализует AutoDream-правила в M1 Memory Cleaner. Adjusted thresholds для клиентского профиля (`≥72h && ≥3 sessions` вместо ежедневной нормы). Soft-delete в `memory/_archive/` с возможностью revival.
- **Ссылка:** [zenvanriel.com](https://www.zenvanriel.com/) (AutoDream), [Anthropic Memory tool docs](https://platform.claude.com/cookbook/misc-session-memory-compaction)

---

## 5. Florian audit-prompt v5.0 — 8-мерная рубрика качества

- **Автор / источник:** Florian Bruniaux, репо `FlorianBruniaux/claude-code-ultimate-guide`
- **Суть:** 700-строчный аудит-промпт с 4-фазным pipeline и 8-мерной 100-балльной рубрикой.
  - **Фазы:** Phase 1 Inventory (один bash-блок: метаданные структуры) → Phase 2 Audit (LLM-проверки по dimensions) → Phase 3 Score (взвешенная сумма 0-100) → Phase 4 Approval gate (формат `yes/high/«1,3»/none`).
  - **8 dimensions:** Memory / Routing / Skills / Hooks / Security / Freshness / Context Hygiene / Structure.
  - **Citation rule:** каждое finding со ссылкой `файл:строка`. Без ссылки = неprovenable, не считается.
- **Как применить у нас:** вся рубрика встроена в Architect-of-Order (deep-режим). Approval-формат адаптирован на русский (`да / только важное / «1,3» / нет`). Citation rule — обязательное правило для всех аудитов, обзоров и code-review субагентов.
- **Ссылка:** [github.com/FlorianBruniaux/claude-code-ultimate-guide/blob/main/tools/audit-prompt.md](https://github.com/FlorianBruniaux/claude-code-ultimate-guide/blob/main/tools/audit-prompt.md)

---

## 6. AGENTS.md стандарт (Linux Foundation, mid-2025)

- **Автор / источник:** Linux Foundation, кросс-платформенный стандарт для AI-агентов
- **Суть:** единый `AGENTS.md` в корне проекта работает в Claude Code, Cursor, Copilot, Gemini CLI, Windsurf, Aider, Zed. Universal agent brief — описывает кто работает, какие задачи, какие правила. CLAUDE.md остаётся для Claude-specific деталей (хуки, settings, скиллы).
- **Как применить у нас:** добавить `AGENTS.md` в корень `client-office-template/` если хотим чтобы шаблон работал и в других CLI. CLAUDE.md тогда — тоньше (только Claude-specific). У нас сейчас `office/AGENTS.md` — это карта команды, а не стандарт. Нужен корневой.
- **Ссылка:** [github.com/openai/agents.md](https://github.com/openai/agents.md), [Linux Foundation blog](https://www.linuxfoundation.org/)

---

## 7. Plan Mode by default (для Tier 1/3 задач)

- **Автор / источник:** Boris Cherny + Generative.inc Complete Guide 2026
- **Суть:** перед нетривиальной задачей — Shift+Tab дважды, попасть в Plan Mode. Plan Mode = read-only. Принуждает думать до делать. Цена ошибки в плане **<<** цена ошибки в коде. Логика: «если 80% accuracy per decision, и фича = 20 решений, то 0.8^20 = ~1% chance всё правильно. Plan mode front-loads review before context pollution».
- **Как применить у нас:** в Workspace CLAUDE.md уже есть «Plan Mode по дефолту (Tier 1/3)». Усилить: перед задачей с lifetime >30 минут — обязательный план в `plans/<task>.md` → ревью read-only субагентом → только после approve идёт implementation.
- **Ссылка:** [Generative.inc — Complete Guide 2026](https://www.generative.inc/the-complete-claude-code-guide-2026-planning-context-engineering-and-high-leverage-development)

---

## 8. Karpathy lint-операция для AI-памяти

- **Автор / источник:** Andrej Karpathy, расширение rohitg00 ([gist](https://gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2))
- **Суть:** AI-память как 3-слойная архитектура: **raw sources** (daily logs, conversations) → **wiki** (компиляция важного) → **schema** (формат для инжекта в next session). 3 операции: `ingest` (сбор), `query` (доступ), `lint` (удаление противоречий и stale entries). Третья — почти никем не реализована и комьюнити шумно об этом говорит. «Stop re-deriving, start compiling».
- **Как применить у нас:** lint-операция как еженедельная работа Architect-of-Order по `memory/`. Daily Reflection переносит важное из daily logs в `MEMORY.md` (ingest). Раз в неделю — поход по противоречиям и stale записям, складирование в `_archive/`.
- **Ссылка:** [Karpathy gist + rohitg00 расширение](https://gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2)

---

## 9. The Algorithm (Илон Маск) — QUESTION → DELETE → SIMPLIFY → ACCELERATE → AUTOMATE

- **Автор / источник:** Илон Маск, цитируется в Walter Isaacson биографии; адаптирован в наш `director/core.md`
- **Суть:** прежде чем оптимизировать процесс — **подвергни сомнению каждый шаг**. Затем **удали** что не нужно. Только потом **упрости** оставшееся. Дальше **ускорь**. И только в самом конце **автоматизируй**. Главная ошибка — автоматизировать ненужные шаги, делать сложные системы в обход простых решений.
- **Как применить у нас:** каждое добавление в шаблон (агент, скилл, протокол) проходит Algorithm. Если шаг не делает офис **проще** — он не добавляется. Это барьер от sprawl агентов и context bloat. Уже встроено в `director/core.md`.
- **Ссылка:** [Walter Isaacson — Elon Musk biography](https://www.simonandschuster.com/books/Elon-Musk/Walter-Isaacson/9781982181284)

---

## 10. Append-only ADR (Squad pattern)

- **Автор / источник:** Squad framework (GitHub), описано в `02-forums-communities.md`
- **Суть:** `decisions.md` как append-only audit trail архитектурных решений. Каждое решение — отдельный блок с датой и обоснованием. Старые решения **не редактируются** — если решение пересмотрено, добавляется новый блок «## YYYY-MM-DD — пересмотр такого-то». Это даёт честную историю как офис менялся, и не теряется контекст «почему так раньше делали».
- **Как применить у нас:** добавить `office/decisions.md` или `decisions/` папку с одним файлом на ADR (по дате). Этот файл `decisions/2026-05-04-architect-of-order.md` — первый такой ADR. Все агенты-уборщики обязаны не трогать `_archive/` и старые ADR.
- **Ссылка:** Squad framework (GitHub), [thoughtworks.com — Lightweight ADR](https://www.thoughtworks.com/insights/blog/architecture/scaling-the-practice-of-architecture-conversationally)

---

## 11. Hamel 3-level evals — обязательный verify для AI-продуктов

- **Автор / источник:** Hamel Husain, ML-инженер, [hamel.dev/blog/posts/evals/](https://hamel.dev/blog/posts/evals/)
- **Суть:** каждая критичная LLM-фича проходит 3 уровня:
  - **Level 1** — Unit Tests: fast, cheap, on every change. Тестировать промпты как код.
  - **Level 2** — Human + Model Eval: periodic, with traces. Человек + LLM-as-judge оценивают traces.
  - **Level 3** — A/B Testing: production validation на реальных юзерах.
  - **Главное правило:** «Remove all friction from looking at data. Build custom viewing tools showing domain-specific context».
- **Как применить у нас:** для критичных скиллов (`/jtbd`, `/core-offer`, `/marketer-revision`) — Level 1 unit tests на input/output формат, Level 2 — ручные ревью с трейсами через writer/reviewer паттерн, Level 3 — обратная связь от клиентов через реальные офисы.
- **Ссылка:** [Your AI Product Needs Evals](https://hamel.dev/blog/posts/evals/)

---

## 12. AGENTS / Hierarchical Delegation — двухуровневая иерархия

- **Автор / источник:** Anthropic multi-agent research + Codebridge Multi-Agent Orchestration Guide 2026
- **Суть:** оркестратор не разговаривает напрямую с десятком специалистов — это фрагментирует контекст. Вместо этого: orchestrator → feature leads → specialists. Orchestrator общается с 2-3 лидами. Лиды спавнят своих специалистов. Anthropic research: +90.2% performance gain через распределение работы по Sonnet-субагентам с изолированными контекст-окнами vs single-agent Opus.
- **Как применить у нас:** Director не общается со всеми 17 агентами напрямую. Director → Алекс (внутри роутит JTBD/CustDev/critic), Director → Стратег (внутри роутит intake/unpack/discovery), Director → Producer / Designer / Copywriter. Subagent отдаёт только final report наверх.
- **Ссылка:** [Anthropic multi-agent research](https://www.anthropic.com/engineering/building-effective-agents), [Codebridge Multi-Agent Orchestration 2026](https://www.codebridge.tech/articles/mastering-multi-agent-orchestration-coordination-is-the-new-scale-frontier)

---

## 13. Memory layout — 200-line cap + small focused files

- **Автор / источник:** Anubhav (6 months tuning), youngleaders.tech, claudekit.cc
- **Суть:** жёсткое правило Claude Code — `MEMORY.md` грузится первые **200 строк или 25KB** (что раньше). Subagent system prompts включают первые 200 строк автоматически. Routing rules идут в `CLAUDE.md` (грузится целиком), learnings — в `MEMORY.md` (только индекс). Перепутать — потерять 10-20% контекста на boilerplate. Принцип: «every memory note should help next session act faster, or be removed». Категории: `user/`, `project/`, `feedback/`, `failures/`, `decisions/`, `reference/`.
- **Как применить у нас:** уже работает. Закрепить в шаблоне `client-office-template/CLAUDE.md`: `CLAUDE.md ≤200 строк`, `MEMORY.md = index ≤200 строк`, маленькие топик-файлы рядом. core.md агента ≤200, memory.md ≤500 токенов, субагент-промпт ~30 строк.
- **Ссылки:**
  - [Anubhav: 6 months tuning](https://medium.com/data-science-collective/i-spent-6-months-tuning-claude-code-heres-the-exact-setup-that-finally-worked-b41c67628478)
  - [youngleaders.tech: How I Sorted My Claude Code Memory](https://www.youngleaders.tech/p/how-i-finally-sorted-my-claude-code-memory)
  - [claudekit.cc: Subagents Common Mistakes](https://claudekit.cc/blog/vc-04-subagents-from-basic-to-deep-dive-i-misunderstood)

---

## 14. Mental model — Hook / Skill / Subagent / CLAUDE.md / MEMORY.md

- **Автор / источник:** Owen Fox (dev.to), Dean Blank (level-up), синтез
- **Суть:** одна фразой формула «когда что использовать»:
  - **Hook** = детерминизм («каждый раз когда X»)
  - **Skill** = workflow с триггером («когда юзер просит Y»)
  - **Subagent** = изоляция контекста + параллельность («исследуй и верни report»)
  - **CLAUDE.md** = правила, применимые везде
  - **MEMORY.md** = усвоенный опыт, грузится в начало
- **Как применить у нас:** прямо в `client-office-template/CLAUDE.md` как короткая шпаргалка. Без неё ученики путают концепции и пишут хук там, где нужен скилл (или наоборот).
- **Ссылки:**
  - [Owen Fox — Hooks Subagents Skills Guide](https://dev.to/owen_fox/claude-code-hooks-subagents-and-skills-complete-guide-hjm)
  - [Dean Blank — Mental Model](https://levelup.gitconnected.com/a-mental-model-for-claude-code-skills-subagents-and-plugins-3dea9924bf05)

---

## 15. Specificity matters — конкретные инструкции 89% adherence

- **Автор / источник:** Generative.inc Complete Guide 2026, эмпирические данные Anthropic
- **Суть:** конкретные инструкции работают 2.5× лучше абстрактных. «Use 2-space indentation» — ~89% соблюдение. «Write clean code» — ~35%. Negation flip: «Use no-semicolons ESLint rule» лучше чем «Do NOT use semicolons». Конкретные команды (`bun run test`) важнее абстракций («run the tests»).
- **Как применить у нас:** прогнать все CLAUDE.md, core.md, SKILL.md через тест: «можно ли это интерпретировать двусмысленно?». Все правила — с конкретными командами, путями, цифрами. Никакого «следуй best practices», «пиши качественно».
- **Ссылка:** [Generative.inc — Complete Guide 2026](https://www.generative.inc/the-complete-claude-code-guide-2026-planning-context-engineering-and-high-leverage-development)

---

## 16. Compact на 60% — проактивно, не дотягивай до 95%

- **Автор / источник:** Anthropic compaction cookbook, mindstudio.ai
- **Суть:** Claude Code умеет компактить контекст. Анти-паттерн — ждать пока контекст забьётся на 83.5% (auto-compact) и получить деградацию качества. Правильно — `/compact` на 60-70%. Хорошо — пишешь в CLAUDE.md инструкции «при компакции сохраняй: список изменённых файлов, активные TODO, ключевые архитектурные решения, активные тесты».
- **Как применить у нас:** хук `compact-prompt.sh` мониторит `/context` и при 60% предлагает `/compact`. В `CLAUDE.md` шаблона — preservation instructions. Альтернатива — закрывать сессию с handoff document, открывать новую (часто чище компакции).
- **Ссылки:**
  - [mindstudio.ai — /compact best practices](https://www.mindstudio.ai/blog/claude-code-compact-command-context-management)
  - [Anthropic Compaction Cookbook](https://platform.claude.com/cookbook/misc-session-memory-compaction)

---

## Бонус — что осознанно НЕ берём

- **Multi-agent meeting patterns** (Six Thinking Hats, DACI, Design Sprint встречи агентов) — оверинжиниринг для одного юзера, может работать для команды
- **Vector DB пока корпус <10k** — markdown + grep + skills с lazy-loading закрывают 95% кейсов
- **15+ MCP одновременно** — каждый раздувает контекст, теряется фокус
- **Self-hosted Langfuse на старте** — слишком инфра-нагрузка ради observability которая в первый месяц не нужна
- **`--dangerously-skip-permissions`** — реальный кейс удаления продакшн-БД через Claude
- **DALL-E 3** — устарел, дороже Imagen в 3×
- **OpenAI Whisper API напрямую** — Groq дешевле в 10× с тем же качеством
- **LangSmith** — локап в LangChain, мы не на нём
