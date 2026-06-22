---
title: Инструменты, MCP и стек AI-офиса
updated: 2026-05-05
source_research: 2026-05-04-office-architecture
status: live
---

# Инструменты, MCP и стек AI-офиса

> Дистиллят по инструментам: минимальный пакет MCP, hooks, settings.json, транскрипция, картинки, observability. Читать ПЕРЕД подбором стека для нового офиса или ревью существующего.

Главная мысль: **каждый MCP ест контекст.** Anthropic рекомендует 3-8 MCP максимум. Нужно `ENABLE_TOOL_SEARCH=auto:5` для on-demand загрузки (-47% bloat). И главное — **Skills > MCP когда можно**: markdown + lazy-load закрывает 95% кейсов без MCP-инфраструктуры.

---

## 1. Минимальный пакет 5 MCP «День 1»

Из `research/05-tools-services-mcp.md:91`. Это пакет «без которого офис не запустится»:

| # | MCP | Пакет | Что делает |
|---|-----|-------|------------|
| 1 | **Filesystem** | `@modelcontextprotocol/server-filesystem` | Чтение/запись файлов офиса. Без него агенты не работают. |
| 2 | **Memory** | `@modelcontextprotocol/server-memory` | Knowledge graph для долговременной памяти. JSONL на диске. |
| 3 | **Notion** | `mcp.notion.com` (OAuth) | Единый источник правды для задач/знаний |
| 4 | **Telegram Channels** | официальный плагин Anthropic | DM с офисом из любого места |
| 5 | **Context7** | `upstash/context7` | Актуальные доки библиотек, anti-hallucination |

**Принцип отбора:** must-have = критично для базового офиса (без этого либо нет связи, либо нет памяти, либо клиент не сможет работать).

---

## 2. Опционально по профилю клиента (Неделя 1)

| MCP | Когда подключать |
|-----|------------------|
| **GitHub MCP** | Когда у клиента появляется код / автоматизация PR |
| **Sequential Thinking** | Для сложных стратегических задач |
| **Google Drive / Sheets** | Если клиент работает в Google Workspace |
| **Helicone** (proxy) | Когда LLM-расходы > $50/мес и хочется аналитику |
| **Chrome DevTools** | Когда офис делает frontend |
| **Brave Search** | Альтернатива WebSearch для агентов-исследователей |
| **Gmail MCP** | Если есть продажи / email follow-up |
| **Playwright** | Если есть E2E-тесты или скрейпинг |
| **Figma Dev Mode** | Если активная дизайн-разработка |

---

## 3. Что НЕ подключать на старте

Из `research/06-blueprint.md:681`:

- **Linear** (если уже выпилили / не нужен — не дублируем).
- **Slack** (для команды клиентов клиента, не для самого клиента).
- **Playwright** (тяжёлый по токенам, только при E2E-тестах).
- **Sentry / PostgreSQL** (только когда есть прод).
- **DALL-E 3** (устарел, дороже Imagen в 3×, GPT Image 1.5 лучше).
- **OpenAI Whisper API напрямую** (Groq дешевле в 10× с тем же качеством).
- **LangSmith** (если не на LangChain — это локап).
- **Multiple browser MCP одновременно** (выбрать Playwright или Chrome DevTools, не оба).
- **«Все 1000 skills из awesome-list»** (раздуют контекст, потеряете фокус).
- **Self-hosted Langfuse на старте** (слишком инфра-нагрузка ради observability которая в первый месяц не нужна).

---

## 4. Жёсткое правило — 3-8 MCP максимум

Anthropic (`research/02-forums-communities.md:374-376`):

> *«Most effective setups use between 3 and 8 MCP servers, with each server adding tool definitions to your agent's context — start with the 2-3 servers that cover your primary workflow, then add more only when you have a clear use case.»*

**Каждый MCP добавляет все свои tools в context.** 15 MCP = 200+ tools = 50K+ tokens до того как Claude увидел задачу.

**ENABLE_TOOL_SEARCH=auto:5** — Tool Search в свежих версиях Claude Code. Загружает tools on-demand, снижает context bloat на ~47% (`research/01-youtube-research.md:569`).

В `.claude/settings.json`:

```json
{
  "env": {
    "ENABLE_TOOL_SEARCH": "auto:5"
  }
}
```

Apgrade CLI обязателен — иначе 5 MCP сожрут весь контекст.

---

## 5. Skills > MCP когда можно

**Cole Medin (`research/01-youtube-research.md:171`):**

> *«Markdown files for memory, Claude Code skills for capabilities, hooks for persistence, and a Claude Agent SDK heartbeat for proactive action — with no vector databases or complex orchestration frameworks.»*

**Когда скилл, когда MCP:**

| Задача | Что использовать | Почему |
|--------|------------------|--------|
| Запрос в Notion API | **MCP** notion | Внешний инструмент с auth |
| Workflow «упакуй оффер» | **Skill** | Внутренняя логика, без внешних вызовов |
| Чтение/запись файлов | **MCP** filesystem | Стандартный инструмент |
| Методология JTBD | **Skill** + knowledge | Просто markdown с инструкциями |
| Отправка письма в Gmail | **MCP** gmail | Внешний API |
| «Создай карточку клиента из шаблона» | **Skill** + template | Файловая операция через filesystem MCP, обёрнутая в скилл |

**Правило.** Если функция требует внешнего API или сложной интеграции — MCP. Если это workflow на основе Read/Write файлов — Skill.

---

## 6. Vector DB — не нужен в большинстве случаев

Cole Medin доказал на проде Second Brain (`research/01-youtube-research.md:171-180`).

**Когда vector DB нужен:**
- Корпус заметок > 10 000 документов
- Нужен semantic search с латентностью <20ms
- Embedding-сходство критично (например, реко-система)

**Когда не нужен:**
- Меньше 1K заметок — grep работает быстрее
- 1K-10K заметок — markdown + skills с lazy-loading через `description:`
- Для одиночного пользователя — markdown побеждает по простоте

**Если когда-то понадобится** — выбор сводится к трём (`research/02-forums-communities.md:411`):

| DB | Когда |
|----|-------|
| **ChromaDB** | Локальный store, быстрый старт |
| **Qdrant / Weaviate** | Внешняя persistence, scale beyond one process |
| **pgvector** | Если уже есть Postgres, до 50K векторов — без затрат |

Для большинства офисов — **markdown + grep + skills с lazy-loading**.

---

## 7. Hooks — минимальный набор 5

13 lifecycle событий доступны (Disler `research/01-youtube-research.md:288-308`). Минимальный набор для офиса — **5 хуков**:

| Hook | Что делает | Скрипт |
|------|------------|--------|
| **SessionStart** | Инжект context.md, дата, активный клиент, флаги setup'а | `.claude/hooks/session-start.sh` |
| **PreToolUse** | git-safety: deny `rm -rf`, `git push --force`, `Edit(.env)` | `.claude/hooks/pre-tool-use.sh` |
| **PostToolUse** | Auto-commit snapshot после Edit/Write на ветку `claude-snapshots` | `.claude/hooks/post-tool-use.sh` |
| **Stop** | Nudge от Architect-of-Order после N сообщений (опц) | `.claude/hooks/stop.sh` |
| **UserPromptSubmit** | Tier-classifier: определяет Revenue Tier и подсказывает скилл | `.claude/hooks/user-prompt-submit.sh` (опц) |

**Особенность.** SessionStart различает `source=startup` vs `source=resume` (`research/02-forums-communities.md:75`). На startup — полный пакет, на resume — только дельта.

**Время выполнения hook'а ≤ 30 секунд** (Disler `research/01-youtube-research.md:308`). Если падает — продолжаем без контекста, не блокируем сессию.

---

## 8. Все 13 lifecycle событий

| Событие | Когда срабатывает | Зачем |
|---------|-------------------|-------|
| **Setup** | Repo init / периодическое обслуживание | Persistence env-переменных |
| **SessionStart** | Старт/возобновление сессии (sources: startup, resume, clear, compact) | Загрузка контекста |
| **UserPromptSubmit** | После каждого ввода пользователя | Триаж, фильтрация, инжекция контекста |
| **PreToolUse** | Перед вызовом инструмента | Защита от опасных команд |
| **PermissionRequest** | Показ разрешения юзеру | Аудит, авто-allow read-only |
| **PostToolUse** | После tool успеха | Логирование, форматирование |
| **PostToolUseFailure** | После tool провала | Структурированный error log |
| **PreCompact** | Перед компакцией | Бэкап транскрипта в `office/ops/sessions/` |
| **Notification** | Notification от Claude | TTS, Telegram push |
| **Stop** | Claude закончил отвечать | Force continuation, nudge |
| **SubagentStart** | Спавн субагента | Лог |
| **SubagentStop** | Субагент закончил | Верификация completion |
| **SessionEnd** | Конец сессии | Финальный snapshot, итоги |

---

## 9. settings.json template — минимальный

Из `research/06-blueprint.md:705-781`:

```json
{
  "permissions": {
    "allow": [
      "Read(*)",
      "Glob(*)",
      "Grep(*)",
      "Write(office/**)",
      "Write(projects/**)",
      "Write(clients/**)",
      "Write(knowledge/**)",
      "Write(inbox/**)",
      "Bash(ls *)",
      "Bash(git status)",
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(grep *)",
      "Bash(find *)",
      "Bash(wc *)",
      "Bash(cat *)",
      "Bash(head *)",
      "Bash(tail *)"
    ],
    "ask": [
      "Write(.env)",
      "Write(office/agents/*/core.md)",
      "Write(office/agents/*/soul.md)",
      "Bash(npm install *)",
      "Bash(pip install *)",
      "Bash(git push *)",
      "WebFetch"
    ],
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
  },
  "env": {
    "BASH_DEFAULT_TIMEOUT_MS": "120000",
    "MCP_TIMEOUT": "30000",
    "ENABLE_TOOL_SEARCH": "auto:5"
  },
  "hooks": {
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {"type": "command", "command": "bash .claude/hooks/session-start.sh"}
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash|Edit|Write",
        "hooks": [
          {"type": "command", "command": "bash .claude/hooks/pre-tool-use.sh"}
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {"type": "command", "command": "bash .claude/hooks/post-tool-use.sh"}
        ]
      }
    ]
  }
}
```

**Правила evaluation** (из `research/05-tools-services-mcp.md:264`): `deny` → `ask` → `allow`. Первый матч побеждает. Managed scope (enterprise) перебить нельзя.

**Принцип минимума** — Claude как «ненадёжный, но мощный стажёр». Только нужные права.

---

## 10. Транскрипция — Groq default, Deepgram fallback

Из `research/05-tools-services-mcp.md:138-146`:

| Сервис | Цена/мин | Скорость | Языки | Слабое |
|--------|----------|----------|-------|--------|
| **Groq Whisper Large v3 Turbo** | ~$0.0006 | 164–299× реалтайм | 99 | Не стриминг, чанки |
| **Deepgram Nova-3** | ~$0.0036–$0.0059 | 200–400ms финал | 36+, лучше на коде/жаргоне | Дороже, меньше языков |
| **OpenAI Whisper API** | ~$0.006 | средне | 99 | Дороже Groq в 10× |

**Эталонный выбор:** **Groq Whisper Turbo** — default (дёшево, быстро, мультиязык). **Deepgram Nova-3** — fallback когда нужна точность по терминологии или real-time стриминг.

Аудио > 10 минут — через Deepgram API, не локальный whisper (тяжёлый, медленный, плохое качество).

---

## 11. Картинки — Imagen 4 Standard default

Из `research/05-tools-services-mcp.md:149-159`:

| Модель | Цена/img | Качество (Elo) | Сильное |
|--------|----------|----------------|---------|
| **Imagen 4 Fast (Google)** | $0.02 | хорошее | Самый дешёвый прод |
| **Imagen 4 Standard** | $0.04 | хорошее+ | Default баланс |
| **Imagen 4 Ultra** | $0.06 | топ | Премиум, для финалов |
| **Flux 2 Pro v1.1** | $0.055 | 1265 Elo | Топ качество, фотореализм |
| **GPT Image 1.5** | $0.04–$0.12 | 1264 Elo | Топ качество, текст в картинке |

**Эталонный выбор:**
- **Imagen 4 Standard** — default
- **Flux 2 Pro** — фотореализм / особый стиль
- **GPT Image 1.5** — текст внутри картинки (постеры, упаковка)

DALL-E 3 устарел — пропустить.

---

## 12. Observability — Helicone один прокси

Из `research/05-tools-services-mcp.md:163-171`:

| Платформа | Сильное | Когда брать |
|-----------|---------|-------------|
| **Helicone** | Простейший setup (1 строка), proxy-кэш, analytics, мульти-провайдер | Простой старт, кэш экономит 20-40% LLM-расходов |
| **Langfuse self-host** | Open-source, framework-agnostic OTel, dev-friendly | Когда офис вырастет и нужен серьёзный трейсинг |
| **LangSmith** | Глубочайшая интеграция с LangChain | Только если на LangChain |

**Эталонный выбор:** **Helicone** для простого старта (one-line proxy). **Langfuse self-host** на VPS когда офис вырастет.

**Замечание:** ни одна из платформ толком не интегрируется с MCP-tool-calls Claude Code из коробки — это слепая зона observability в 2026. Решение — отдельный логирующий PostToolUse hook, который пишет в свою БД или Helicone.

---

## 13. Запретить через managed-settings

Жёстко через managed-settings (enterprise scope, перебить нельзя):

```json
{
  "permissions": {
    "deny": [
      "Bash(*--dangerously-skip-permissions*)"
    ]
  }
}
```

`--dangerously-skip-permissions` — никогда вне изолированной dev-среды. Реальный кейс удаления продакшн-БД через Claude (`research/04-governance-cleanup-agents.md:333`).

---

## 14. .env.example — без призраков

Минимум, без переменных которые никто не читает:

```bash
# Notion (OAuth через Cloud MCP — обычно не нужно вручную)
# NOTION_API_KEY=

# Telegram (для офисного бота если ставишь Telegram Channels)
# TELEGRAM_BOT_TOKEN=

# Groq (транскрипция аудио > 10 мин)
# GROQ_API_KEY=

# Deepgram (fallback транскрипция)
# DEEPGRAM_API_KEY=
```

**Anti-pattern из аудита** (`research/07-audit-client-template.md:61`): `.env.example` имеет `ANTHROPIC_API_KEY=` — но ни один скилл его НЕ читает. Призрак. Клиент будет недоумевать зачем эта переменная.

Удалить из `.env.example` всё что **никто не использует**.

---

## 15. .gitignore — минимум

```
.env
.env.*
!.env.example
**/.DS_Store
node_modules/
.claude/agent-memory*
.claude/settings.local.json
_archive/
*.log
.swp
```

**Anti-pattern.** `.gitignore` не покрывает `**/.DS_Store` рекурсивно — только корневой. На диске накапливаются `.DS_Store` в подпапках, при следующем `git add .` улетают в репо.

**Замечание про `_archive/`.** Если Architect-of-Order перемещает файлы в `_archive/`, а `_archive/` в gitignore — ломается audit trail (Anthropic principle). Решение: либо `_archive/` коммитится, либо использовать `git mv` + commit, либо архивировать через переименование `<filename>-archived-<date>.md`.

---

## 16. Эталонные репо — что украсть

Из `research/05-tools-services-mcp.md:347-388`:

1. **`OneRedOak/claude-code-workflows`** — code-review, design-review, security-review с GitHub Actions + slash-командами. Production-ready.
2. **`wshobson/agents`** — 185 агентов + 16 оркестраторов + 153 скилла + 100 команд в 80 плагинах.
3. **`zircote/.claude`** — 100+ агентов в 10 категориях, таксономия (core dev / language / infra / quality / data-AI / business / meta-orchestration).
4. **`disler/claude-code-hooks-mastery`** (3.6k звёзд) — примеры hooks для всех 13 событий.
5. **`disler/claude-code-hooks-multi-agent-observability`** (1.4k) — real-time мониторинг через хуки и WebSocket.
6. **`anthropics/skills`** (128k звёзд) — официальные skills + канонический формат SKILL.md.
7. **`coleam00/ai-transformation-workshop`** — 15 reusable Claude Code commands, концепт «AI layer» и PIV-loop.

---

## 17. Универсальный интерфейс — Bash, не десятки tools

Cat Wu (Anthropic, `research/01-youtube-research.md:100`):

> *«The team emphasizes Bash as a universal interface rather than accumulating dozens of single-purpose tools.»*

Boris Cherny — то же. Не пытайся подключить single-purpose MCP для каждой задачи. Большинство закрывается через Bash + filesystem MCP + grep.

**Anti-pattern.** Подключить специальный MCP для git-операций когда `Bash(git ...)` работает out-of-box.

---

## 18. Цитаты-якоря

- Anthropic: *«Each MCP server adds all its tools to context. Use Tool Search feature (ENABLE_TOOL_SEARCH=auto:5) to load tools on-demand, reducing bloat by roughly 47%.»* (`research/01-youtube-research.md:569`)
- Cat Wu: *«Bash as universal interface rather than accumulating dozens of single-purpose tools.»* (`research/01-youtube-research.md:693`)
- Cole Medin: *«No vector databases or complex orchestration frameworks.»* (`research/01-youtube-research.md:171`)
- nevo.systems: *«Most effective setups use between 3 and 8 MCP servers... start with the 2-3 servers that cover your primary workflow.»* (`research/02-forums-communities.md:374`)

---

## Источники

- `research/2026-05-04-office-architecture/05-tools-services-mcp.md` — целиком, главный документ
- `research/2026-05-04-office-architecture/01-youtube-research.md:556-700` — MCP топ-12, observability
- `research/2026-05-04-office-architecture/02-forums-communities.md:356-432` — Notion vs Linear, vector DB
- `research/2026-05-04-office-architecture/06-blueprint.md:661-816` — секция 8 ИНСТРУМЕНТЫ блюпринта
- `research/2026-05-04-office-architecture/07-audit-client-template.md:308-345` — аудит MCP в шаблоне

## Связанные дистилляты

- `distilled/10-principles.md` — принцип 4 (Hook/Skill/Subagent), 9 (vector DB)
- `distilled/skill-design.md` — Skills vs MCP
- `distilled/governance-cleanup.md` — settings.json deny-rules как защита
- `distilled/failures-to-avoid.md` — `ANTHROPIC_API_KEY` призрак, `--dangerously-skip-permissions`
