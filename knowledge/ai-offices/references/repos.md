---
title: Эталонные публичные репозитории — что украсть для AI-офиса
updated: 2026-05-05
source_research: 2026-05-04-office-architecture
---

# Эталонные публичные репозитории

Подборка 12 публичных Git-репозиториев, на которые стоит смотреть при сборке шаблона AI-офиса. Для каждого — звёзды, ключевая ценность, главные файлы и лицензия. Источник — `research/2026-05-04-office-architecture/05-tools-services-mcp.md` (секция 6) и `research/2026-05-04-office-architecture/01-youtube-research.md`.

---

## 1. anthropics/skills

- **URL:** https://github.com/anthropics/skills
- **Звёзды:** ~128k
- **Лицензия:** MIT
- **Что умеет:** официальная коллекция Anthropic с production-grade Skills (skill-creator, claude-api, docx, pdf, pptx, xlsx)
- **Что украсть:** канонический формат `SKILL.md` с YAML-frontmatter (`name`, `description`); эталон описаний под автоматический triggering; reference-формат документ-скиллов
- **Главные файлы:** `skill-creator/SKILL.md`, `pdf/SKILL.md`, `docx/SKILL.md`

---

## 2. disler/claude-code-hooks-mastery

- **URL:** https://github.com/disler/claude-code-hooks-mastery
- **Звёзды:** ~3.6k
- **Лицензия:** MIT
- **Что умеет:** энциклопедия паттернов всех 13 lifecycle-событий Claude Code (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Notification, Stop, SubagentStop, PreCompact, SessionEnd и пр.) с детерминированной/недетерминированной логикой
- **Что украсть:** все рабочие шаблоны хуков на UV single-file Python (каждый хук со своими зависимостями); SessionStart context-injection; PostToolUse logging; паттерн Builder + Validator (read-only QA); meta-agent (агент, генерирующий других агентов)
- **Главные файлы:** `.claude/settings.json`, `.claude/hooks/session_start.py`, `.claude/hooks/pre_tool_use.py`, `.claude/agents/meta-agent.md`, `.claude/agents/team/builder.md`, `.claude/agents/team/validator.md`

---

## 3. disler/claude-code-hooks-multi-agent-observability

- **URL:** https://github.com/disler/claude-code-hooks-multi-agent-observability
- **Звёзды:** ~1.4k
- **Лицензия:** MIT
- **Что умеет:** real-time мониторинг multi-agent системы через хуки + WebSocket-dashboard; закрывает слепую зону MCP-tool-calls в Helicone/Langfuse
- **Что украсть:** идея observability через `PostToolUse` → WebSocket → dashboard; JSON-логи всех hook-executions в `logs/`; status-lines (9 версий) — токены/контекст/стоимость в каждой точке
- **Главные файлы:** `.claude/hooks/post_tool_use.py`, `apps/server/`, `apps/dashboard/`

---

## 4. obra/superpowers (Jesse Vincent)

- **URL:** https://github.com/obra/superpowers
- **Лицензия:** MIT (распространяется через Anthropic plugin marketplace)
- **Что умеет:** методологический фреймворк из 14 ядерных скиллов разработки на Claude Code: `using-superpowers`, `brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `test-driven-development`, `systematic-debugging`, `requesting-code-review`, `verification-before-completion`, `simplify`, `git-commit`, `git-worktree`, `skill-creator`, `remembering-conversations`
- **Что украсть:** ядро 6 скиллов — `brainstorming` (отказ писать код пока не уточнил), `writing-plans` (фича → задачи 2-5 минут), `test-driven-development` (RED/GREEN/REFACTOR), `requesting-code-review` (gate перед merge), `verification-before-completion` (не говори done без проверки), `systematic-debugging` (научный метод)
- **Главные файлы:** `skills/<name>/SKILL.md` для каждого из 14

---

## 5. coleam00/context-engineering-intro

- **URL:** https://github.com/coleam00/context-engineering-intro
- **Звёзды:** ~13.3k
- **Лицензия:** MIT
- **Что умеет:** шаблон Cole Medin для context-engineering с PRP (Product Requirements Prompts), command-инфраструктурой `/generate-prp`, `/execute-prp`, библиотекой паттернов кода для подражания
- **Что украсть:** концепция «context engineering 10x better than prompt engineering» (большинство падений агента — context failures); структура `PRPs/` (templates + examples) + `examples/` + `validation/`; формат `INITIAL.md` для feature-request
- **Главные файлы:** `CLAUDE.md`, `INITIAL.md`, `PRPs/templates/prp_base.md`, `.claude/commands/generate-prp.md`

---

## 6. coleam00/ai-transformation-workshop

- **URL:** https://github.com/coleam00/ai-transformation-workshop
- **Лицензия:** MIT
- **Что умеет:** 15 reusable Claude Code commands; концепт «AI layer» (двухслойный codebase = код + AI-контекст); PIV-loop (Plan → Implement → Verify)
- **Что украсть:** минимальный набор generic-команд для любого проекта (`/create-prd`, `/prime`, `/plan`, `/implement`, `/test`, `/review`, `/debug`, `/refactor`, `/docs`, `/commit`, `/handoff`, `/wrap-up`, `/cleanup`, `/research`, `/explore`); PIV как универсальный паттерн slash-команд
- **Главные файлы:** `.claude/commands/*.md` (15 штук)

---

## 7. OneRedOak/claude-code-workflows

- **URL:** https://github.com/OneRedOak/claude-code-workflows
- **Лицензия:** MIT
- **Что умеет:** production-ready code-review, design-review, security-review с GitHub Actions + slash-командами + субагентами
- **Что украсть:** dual-loop архитектура code-review (slash-команда `/review` + GitHub Action на каждый PR); design-review через Playwright MCP с UI-консистентностью; security-review по OWASP Top 10 со severity-классификацией
- **Главные файлы:** `.claude/commands/review.md`, `.github/workflows/claude-review.yml`, `.claude/agents/security-auditor.md`

---

## 8. wshobson/agents

- **URL:** https://github.com/wshobson/agents
- **Лицензия:** MIT
- **Что умеет:** 185 агентов + 16 оркестраторов + 153 скилла + 100 команд в 80 плагинах
- **Что украсть:** концепт «плагин = single-purpose pack» (плагин загружает только свои агенты/команды/скиллы — не раздувает контекст); preset-команды для review/debug/feature/fullstack/security/migration; structured workflow Context → Spec & Plan → Implement
- **Главные файлы:** `plugins/<name>/agents/`, `plugins/<name>/commands/`, `plugins/<name>/skills/`

---

## 9. zircote/.claude

- **URL:** https://github.com/zircote/.claude
- **Лицензия:** MIT
- **Что умеет:** 100+ агентов в 10 категориях, 60+ скиллов, custom commands, includes по языкам/фреймворкам
- **Что украсть:** таксономия агентов (core dev / language / infra / quality / data-AI / business / meta-orchestration) — переиспользовать как карту расширения; формат `includes/` с language-specific стандартами (подгружаются по path-frontmatter)
- **Главные файлы:** `agents/` (по категориям), `includes/`, `skills/`

---

## 10. VoltAgent/awesome-claude-code-subagents

- **URL:** https://github.com/VoltAgent/awesome-claude-code-subagents
- **Лицензия:** MIT
- **Что умеет:** 100+ субагентов в 10 категориях с консистентным форматом (role-descriptor, kebab-case, суффиксы `-pro`, `-specialist`, `-expert`, `-architect`, `-engineer`)
- **Что украсть:** naming convention для субагентов (`typescript-pro`, `devops-engineer`, `security-auditor`); шаблон фронтматтера с обязательными `name`, `description`, `tools`, `model`
- **Главные файлы:** `categories/<category>/<agent>.md`

---

## 11. FlorianBruniaux/claude-code-ultimate-guide

- **URL:** https://github.com/FlorianBruniaux/claude-code-ultimate-guide
- **Лицензия:** MIT
- **Что умеет:** `audit-prompt.md` v5.0 — 700-строчный аудит-промпт с 8-мерной 100-балльной рубрикой и 4-фазовым pipeline (Inventory → Audit → Score → Approval gate)
- **Что украсть:** 8 dimensions качества офиса (Memory / Routing / Skills / Hooks / Security / Freshness / Context Hygiene / Structure); Phase 4 approval-формат `yes/high/«1,3»/none`; citation-rule (каждое finding со ссылкой на файл:строку)
- **Главные файлы:** `tools/audit-prompt.md`

---

## 12. anthropics/claude-code (plugin-dev)

- **URL:** https://github.com/anthropics/claude-code
- **Лицензия:** MIT
- **Что умеет:** официальный гайд от Anthropic по разработке хуков и плагинов, включая `hook-development/SKILL.md`
- **Что украсть:** канонический workflow создания хуков; описание всех 13 lifecycle-событий с exit-code-семантикой; правила timeout (60 сек на хук, parallel execution)
- **Главные файлы:** `plugins/plugin-dev/skills/hook-development/SKILL.md`

---

## Бонус — affaan-m/everything-claude-code

- **URL:** https://github.com/affaan-m/everything-claude-code
- **Что умеет:** harness performance optimization system с 1282 тестами, 98% покрытием, 102 правилами static analysis (Cerebral Valley × Anthropic Hackathon, февраль 2026)
- **Что украсть:** уровень дисциплины — тесты для агентских харнессов, security-first подход, инстинкт «писать тесты для промптов»

---

## Бонус — microsoft/agent-governance-toolkit

- **URL:** https://github.com/microsoft/agent-governance-toolkit
- **Что умеет:** policy enforcement, zero-trust identity, execution sandboxing, reliability engineering для автономных агентов; покрывает все 10/10 OWASP Agentic Top 10
- **Что украсть:** RBAC/ABAC модель на тулы; short-lived credentials в vault; data minimization с redaction; session-level traceability (step-by-step traces tool-calls)
