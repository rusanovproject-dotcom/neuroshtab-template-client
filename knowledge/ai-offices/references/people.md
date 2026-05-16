---
title: Топ-практики архитектуры AI-офисов — кого читать и смотреть
updated: 2026-05-05
source_research: 2026-05-04-office-architecture
---

# Топ-практики архитектуры AI-офисов

Подборка людей, на которых стоит подписаться при сборке шаблона AI-офиса. Для каждого — роль, главные идеи (1-3 принципа), что забрать в методологию, знаковые материалы. Источник — `research/2026-05-04-office-architecture/01-youtube-research.md` и `research/2026-05-04-office-architecture/02-forums-communities.md`.

---

## 1. Boris Cherny — создатель Claude Code (Anthropic)

- **Роль:** Head of Claude Code в Anthropic
- **Где читать/смотреть:** [howborisusesclaudecode.com](https://howborisusesclaudecode.com/), X [@bcherny](https://x.com/bcherny), Lenny's Podcast, Pragmatic Engineer
- **Главные идеи:**
  1. **Vanilla > custom.** «Claude Code works great out of the box, so I personally don't customize it much» — не кастомизируй то, что и так работает. Добавляй только когда видишь конкретную дыру.
  2. **Verify loop = 2-3x качества.** «Give Claude a way to verify its work — it will 2-3x the quality of the final result». Линтер, тесты, скриншот, LLM-as-judge.
  3. **CLAUDE.md как компаундирующая память.** «Anytime we see Claude do something incorrectly we add it to the CLAUDE.md, so Claude knows not to do it next time». В PR-ревью тег `@.claude` автоматически уносит learning в файл.
- **Что забрать в методологию:** pipeline `spec → draft → simplify → verify`; параллелизм через worktrees (5 Claude'ов в разных tabs); Plan Mode по умолчанию для нетривиальных задач; bash как универсальный интерфейс вместо десятков single-purpose тулов
- **Знаковые материалы:**
  - [Inside Claude Code With Its Creator (Lightcone, фев 2026)](https://www.youtube.com/watch?v=PQU9o_5rHC4)
  - [Building Claude Code with Boris Cherny (Pragmatic Engineer, март 2026)](https://www.youtube.com/watch?v=julbw1JuAz0)

---

## 2. Cat Wu — founding engineer Claude Code (Anthropic)

- **Роль:** founding engineer Claude Code
- **Где читать/смотреть:** [Every.to podcast](https://every.to/podcast/how-to-use-claude-code-like-the-people-who-built-it)
- **Главные идеи:**
  1. **Bash как универсальный интерфейс.** «The team emphasizes Bash as a universal interface rather than accumulating dozens of single-purpose tools».
  2. **Tools должны быть max-efficient.** Тулы должны featured в context window, designed for max efficiency, ограничены frequently-used операциями.
- **Что забрать:** дисциплина «не плодить тулы ради тулов»; 3-5 MCP-серверов максимум одновременно
- **Знаковые материалы:** Every.to podcast про Claude Code

---

## 3. Kieran Klaassen — Compound Engineering (Cora, ex-37signals)

- **Роль:** строит Cora (AI inbox), создатель Compound Engineering plugin для Claude Code
- **Где читать/смотреть:** [creatoreconomy.so](https://creatoreconomy.so/p/how-to-make-claude-code-better-every-time-kieran-klaassen), YouTube канал
- **Главные идеи:**
  1. **Compound Engineering 4-фазный цикл.** Plan (sub-agents параллельно) → Work (clarifying questions → build → tests) → Assess (review-агенты) → Compound (capture learnings в docs).
  2. **Treat every task as an investment.** «Treat every task as an investment so the next time is faster».
  3. **Custom skills как just-in-time context.** Скиллы подгружаются только когда нужны (DHH-style для Rails — Claude знает стиль не выгружая контекст).
- **Что забрать в методологию:** 4-фазный Plan→Work→Assess→Compound вместо линейного «пиши код»; Playwright MCP как «AI QA team»; учиться от ошибок через `failures.md` append-only
- **Знаковые материалы:**
  - [How to Make Claude Code Better Every Time (50min)](https://www.youtube.com/watch?v=g6z_4TMDiaE)
  - [Compound Engineering: Manage Teams of AI Agents (Lenny's How I AI)](https://www.youtube.com/watch?v=srh0zy1MQcI)

---

## 4. Cole Medin — AI Second Brain + Context Engineering

- **Роль:** AI-инженер, 170k+ subs на YouTube, автор Archon (20.7k★) и context-engineering-intro (13.3k★)
- **Где читать/смотреть:** [@ColeMedin на YouTube](https://www.youtube.com/@ColeMedin), [coleam00 на GitHub](https://github.com/coleam00)
- **Главные идеи:**
  1. **Context engineering 10x > prompt engineering.** «Most agent failures aren't model failures — they're context failures».
  2. **Markdown + RAG > Vector DB.** «Markdown files for memory, Claude Code skills for capabilities, hooks for persistence — with no vector databases or complex orchestration frameworks». Vector DB добавляешь только когда корпус >10k.
  3. **Daily Reflection pattern.** Daily logs пишутся в течение дня → reflection-агент перебирает и переносит важное в долгосрочную память.
- **Что забрать в методологию:** структура `SOUL.md / USER.md / MEMORY.md / daily logs`; PRP (Product Requirements Prompts) как универсальный шаблон; команды `/generate-prp` + `/execute-prp` для любого проекта; AI-second-brain поверх Obsidian
- **Знаковые материалы:**
  - [Claude SDK: 24-Hour Coding Agent](https://www.youtube.com/watch?v=BGouphNN5hg)
  - [Crush building anything with Claude Code](https://github.com/coleam00/ai-transformation-workshop)

---

## 5. Dan Disler / IndyDevDan — anti-hype agentic coding

- **Роль:** anti-hype продакшн-агентика, 3.6k★ на claude-code-hooks-mastery
- **Где читать/смотреть:** [@indydevdan на YouTube](https://www.youtube.com/@indydevdan/videos), [disler на GitHub](https://github.com/disler)
- **Главные идеи:**
  1. **Subagent = system prompt, не user prompt.** «The #1 misunderstanding when creating agents is treating agent files as user prompts. They are system prompts configuring behavior when the primary agent delegates work».
  2. **Builder + Validator (read-only).** Validator без write-доступа = честная QA. Не может фиксить, только репортить — превращает в честного проверяющего.
  3. **Meta-agent.** «Build the thing that builds the thing» — агент, генерирующий других агентов из описания.
- **Что забрать в методологию:** все 13 lifecycle-хуков с примерами на UV single-file Python; паттерн Builder+Validator для парных агентов (`/jtbd-critic` — наш аналог); meta-agent как точка роста офиса; observability через PostToolUse → WebSocket → dashboard
- **Знаковые материалы:**
  - [The One Agent to RULE them ALL — Advanced Agentic Coding](https://www.youtube.com/watch?v=p0mrXfwAbCg)
  - [Agent Experts: Finally, Agents That ACTUALLY Learn](https://www.youtube.com/watch?v=zTcDwqopvKE)

---

## 6. Anubhav (Data Science Collective) — production tuning

- **Роль:** AI-инженер, 6 месяцев тюнил Claude Code в проде
- **Где читать/смотреть:** [Medium @ Data Science Collective](https://medium.com/data-science-collective/i-spent-6-months-tuning-claude-code-heres-the-exact-setup-that-finally-worked-b41c67628478)
- **Главные идеи:**
  1. **Меньше, точнее, сфокусированнее.** «The main memory file is under 500 tokens on purpose». Анти-паттерн всех «толстых» CLAUDE.md.
  2. **Subagent definitions ≈30 строк.** «Subagent definitions are maybe thirty lines each, emphasizing conciseness over exhaustive documentation».
  3. **Modular design.** Концерны разделены: rules / subagents / skills / hooks / MCP. Никаких монолитных конфигов.
- **Что забрать:** жёсткие лимиты (CLAUDE.md <300 строк, memory <500 токенов, субагент ~30 строк); modular `.claude/` (rules/agents/skills/hooks/.mcp.json по отдельности)
- **Знаковые материалы:** [I Spent 6 Months Tuning Claude Code](https://medium.com/data-science-collective/i-spent-6-months-tuning-claude-code-heres-the-exact-setup-that-finally-worked-b41c67628478)

---

## 7. Andrej Karpathy — LLM Wiki memory pattern

- **Роль:** ex-Tesla AI / OpenAI co-founder, теоретик AI-инфраструктуры
- **Где читать/смотреть:** X [@karpathy](https://x.com/karpathy), [gist с расширением от rohitg00](https://gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2)
- **Главные идеи:**
  1. **3-layer memory architecture.** Raw sources (daily logs) → Wiki (компиляция) → Schema (для инжекта).
  2. **3 операции.** `ingest` (сбор), `query` (доступ), `lint` (удаление противоречий и stale entries). Третья — почти никем не реализована.
  3. **«Stop re-deriving, start compiling».** Conversations → daily logs → wiki → инжект в next session. Агент строит свою базу знаний.
- **Что забрать:** lint-операция как еженедельная работа Architect-of-Order по `memory/`; daily logs → MEMORY.md перенос важного через Daily Reflection
- **Знаковые материалы:** Karpathy gist + расширение rohitg00, [LLM Wiki разбор](https://gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2)

---

## 8. Simon Willison — критик-обозреватель Claude

- **Роль:** разработчик Datasette, влиятельный обозреватель LLM-инструментов
- **Где читать/смотреть:** [simonwillison.net](https://simonwillison.net/), [Substack](https://simonw.substack.com/), X [@simonw](https://x.com/simonw)
- **Главные идеи:**
  1. **Skills — больший deal чем MCP.** Открытое мнение в Substack: Skills меняют user-facing UX больше чем MCP.
  2. **Граница skills/MCP не догма.** Skills — design pattern, можно реализовать через MCP. Решение — обе нужны: MCP даёт инструменты, Skills — workflow ими пользоваться.
- **Что забрать:** трезвая оценка хайпа; ссылки на новые паттерны в реальном времени; tag [sub-agents](https://simonwillison.net/tags/sub-agents/) — куратируемая лента
- **Знаковые материалы:** [Claude Skills are awesome (Substack)](https://simonw.substack.com/p/claude-skills-are-awesome-maybe-a)

---

## 9. Hamel Husain — evals для AI-продуктов

- **Роль:** ML-инженер, автор фреймворка по оценке LLM-продуктов
- **Где читать/смотреть:** [hamel.dev/blog](https://hamel.dev/blog/posts/evals/)
- **Главные идеи:**
  1. **Trust cannot be assumed.** «The bottleneck is no longer generation. It's verification».
  2. **3-level evals.** Level 1: unit tests (fast, cheap, every change). Level 2: human + model eval (periodic, with traces). Level 3: A/B testing (production validation).
  3. **Remove all friction from looking at data.** Build custom viewing tools showing domain-specific context.
- **Что забрать:** 3-level evals для критичных скиллов офиса (`/jtbd`, `/core-offer`); routing transparency (показ что Director увидел в фразе и куда роутил); eval traces как обязательный артефакт
- **Знаковые материалы:**
  - [Your AI Product Needs Evals](https://hamel.dev/blog/posts/evals/)
  - [LLM Evals FAQ](https://hamel.dev/blog/posts/evals-faq/)

---

## 10. Erik Schluntz (Anthropic) — design Claude Sonnet/Code

- **Роль:** инженер Anthropic, участвовал в дизайне Claude Sonnet и Claude Code
- **Где читать/смотреть:** [Latent Space podcast](https://www.latent.space/p/claude-sonnet)
- **Главные идеи:**
  1. **Verify-first дизайн.** Платформа должна давать механизмы проверки на каждом шаге.
  2. **Tools first, capabilities second.** Сначала проектируй какие инструменты у агента есть, потом — какие задачи он решает.
- **Что забрать:** обоснование verify-loop с точки зрения разработчиков платформы; почему Anthropic не предлагает фиксированный baseline-набор скиллов («start with evaluation»)
- **Знаковые материалы:** Latent Space с Erik Schluntz

---

## 11. Sander Schulhoff — prompt engineering 2026

- **Роль:** автор HackAPrompt, эксперт по prompt-инженерингу
- **Где читать/смотреть:** [Lenny's Newsletter](https://www.lennysnewsletter.com/p/ai-prompt-engineering-in-2025-sander-schulhoff)
- **Главные идеи:**
  1. **Adversarial-mindset для промптов.** Тестируй промпт как чёрный ящик: что сломает его?
  2. **Prompt injection — не теория.** Реальные кейсы взлома агентов через MCP-сервисы.
- **Что забрать:** мышление о безопасности промптов; идея adversarial-reviewer для критичных скиллов
- **Знаковые материалы:** Lenny's Newsletter с Sander Schulhoff

---

## 12. Jesse Vincent (obra) — Superpowers framework

- **Роль:** создатель Superpowers (фреймворк скиллов через Claude Code plugin marketplace)
- **Где читать/смотреть:** [blog.fsck.com](https://blog.fsck.com/2025/10/09/superpowers/), [obra на GitHub](https://github.com/obra/superpowers)
- **Главные идеи:**
  1. **6 ядерных скиллов несут основную нагрузку.** brainstorming + writing-plans + test-driven-development + systematic-debugging + verification-before-completion + simplify.
  2. **brainstorming отказывается писать код пока не уточнил.** Принудительный gate clarifying questions.
  3. **using-superpowers — мета-скилл.** Заставляет агента читать остальные.
- **Что забрать:** 6-скилловое ядро как минимум для любого офиса; gate «уточняющие вопросы перед кодом» — встроить в `/plan` и `/interview`
- **Знаковые материалы:** [Superpowers post](https://blog.fsck.com/2025/10/09/superpowers/)

---

## 13. Florian Bruniaux — audit-prompt v5.0

- **Роль:** автор `audit-prompt.md` v5.0 — самой подробной публичной рубрики аудита Claude-офисов
- **Где читать/смотреть:** [GitHub: FlorianBruniaux/claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide)
- **Главные идеи:**
  1. **8-мерная 100-балльная рубрика.** Memory / Routing / Skills / Hooks / Security / Freshness / Context Hygiene / Structure.
  2. **4-фазный pipeline.** Inventory (bash one-liner) → Audit (LLM-проверки) → Score (взвешенная сумма) → Approval gate (`yes/high/«1,3»/none`).
  3. **Citation rule.** Каждое finding — со ссылкой `файл:строка`. Без ссылки = неprovenable.
- **Что забрать в методологию:** вся рубрика встроена в Architect-of-Order; approval-формат для любых destructive операций; принцип citation для всех аудитов и обзоров
- **Знаковые материалы:** [audit-prompt.md в репо](https://github.com/FlorianBruniaux/claude-code-ultimate-guide/blob/main/tools/audit-prompt.md)

---

## 14. Addy Osmani — The Code Agent Orchestra

- **Роль:** инженер Google, автор по теме code agents
- **Где читать/смотреть:** [addyosmani.com/blog](https://addyosmani.com/blog/code-agent-orchestra/)
- **Главные идеи:**
  1. **«The bottleneck is no longer generation. It's verification».**
  2. **Trust cannot be assumed** — все находки требуют независимой проверки.
- **Что забрать:** обоснование Writer/Reviewer паттерна; почему агент-инспектор должен сначала прогнать себя
- **Знаковые материалы:** [The Code Agent Orchestra](https://addyosmani.com/blog/code-agent-orchestra/)

---

## 15. Harper Reed — Spec-First Interview pattern

- **Роль:** ex-CTO Obama for America, автор Spec-First Interview паттерна
- **Главные идеи:**
  1. **Один сессия = собрать SPEC.md через интервью.** Claude задаёт по одному вопросу за раз, не выливает чек-лист.
  2. **Новая сессия = имплементировать с чистым контекстом.** Не смешивать сбор требований и работу — контекст загрязняется.
- **Что забрать в методологию:** скилл `/interview` для крупных размытых задач; SPEC.md как hand-off артефакт между сессиями
- **Знаковые материалы:** упоминается в Generative.inc Complete Guide 2026 + Karpathy reposts

---

## Бонус — каналы и комьюнити

- **Dave Ebbelaar** ([@daveebbelaar на YouTube](https://www.youtube.com/@daveebbelaar)) — lasting engineering principles для AI, не хайповые паттерны
- **Norah Sakal** ([norahsakal.com](https://norahsakal.com/)) — RAG-паттерны, embeddings, vector DBs
- **Patrick Ellis** — open-sourced AI code-review (Slash Commands + Subagents + GitHub Actions); талк «Claude Code: Tips and Tricks»
- **Anthropic Academy** ([anthropic.skilljar.com](https://anthropic.skilljar.com/)) — 13 бесплатных курсов, март 2026
