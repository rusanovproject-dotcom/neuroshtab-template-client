---
title: Каталог MCP, hooks и сервисов для AI-офиса
updated: 2026-05-05
source_research: 2026-05-04-office-architecture
---

# Каталог инструментов для AI-офиса

Сводка из `research/2026-05-04-office-architecture/05-tools-services-mcp.md`. Включает 20+ MCP-серверов по категориям, все 13 lifecycle-хуков, сравнение сервисов и template `settings.json` с deny-rules.

Anthropic рекомендует 3-5 MCP одновременно подключённых. Tool Search (`ENABLE_TOOL_SEARCH=auto:5`) уменьшает оверхед на ~95% — тулы загружаются on-demand.

---

## MCP-серверы

### Базовый слой (Anthropic-maintained)

| Имя | Use case | Лицензия | Статус | Рекомендация | Ссылка |
|-----|----------|----------|--------|--------------|--------|
| **Filesystem** | Чтение/запись файлов офиса с конфигурируемыми ACL | MIT | stable | must-have | [@modelcontextprotocol/server-filesystem](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem) |
| **Fetch** | Базовый веб-ресерч (HTML → markdown) | MIT | stable | must-have | [@modelcontextprotocol/server-fetch](https://github.com/modelcontextprotocol/servers/tree/main/src/fetch) |
| **Memory (Knowledge Graph)** | Долговременная память: сущности, отношения, наблюдения (JSONL) | MIT | stable | must-have | [@modelcontextprotocol/server-memory](https://github.com/modelcontextprotocol/servers/tree/main/src/memory) |
| **Sequential Thinking** | Структурированное «думание» цепочкой шагов | MIT | stable | nice-to-have | [@modelcontextprotocol/server-sequential-thinking](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking) |
| **Git** | Чтение/поиск/манипуляции с git-репо | MIT | stable | nice-to-have | [@modelcontextprotocol/server-git](https://github.com/modelcontextprotocol/servers/tree/main/src/git) |
| **Time** | Время и таймзоны | MIT | stable | nice-to-have | server-time |
| **Everything** | Тестовый/референсный сервер | MIT | stable | пропустить | server-everything |

### Связь и каналы

| Имя | Use case | Лицензия | Статус | Рекомендация | Ссылка |
|-----|----------|----------|--------|--------------|--------|
| **Telegram (Channels)** | DM с офисом из любого места | proprietary | beta | must-have | официальный плагин Anthropic, март 2026 |
| **Discord (Channels)** | Аналог Telegram для команд на Discord | proprietary | beta | nice-to-have | официальный плагин Anthropic |
| **iMessage (Channels)** | macOS-only пользователи | proprietary | beta | nice-to-have | официальный плагин Anthropic |
| **Slack MCP** | Поиск/отправка сообщений, действия в Slack | proprietary | stable | nice-to-have (если в Slack) | [mcp.slack.com/mcp](https://docs.slack.dev/ai/slack-mcp-server/connect-to-claude/) |
| **Gmail MCP** | Чтение/отправка писем, поиск тредов, метки | MIT | stable | must-have для продаж | [gongrzhe/server-gmail-autoauth-mcp](https://github.com/gongrzhe/server-gmail-autoauth-mcp) |

### Документы и задачи

| Имя | Use case | Лицензия | Статус | Рекомендация | Ссылка |
|-----|----------|----------|--------|--------------|--------|
| **Notion MCP (hosted)** | Полная интеграция: базы, страницы, поиск, апдейты | proprietary | stable | must-have (если на Notion) | [mcp.notion.com](https://developers.notion.com/guides/mcp/get-started-with-mcp) |
| **Linear MCP** | Issues, projects, comments | proprietary | stable | nice-to-have | [mcp.linear.app/mcp](https://linear.app/docs/mcp) |
| **Google Drive / Sheets** | Чтение документов, заполнение таблиц | MIT | stable | must-have для B2B | community gdrive MCP |
| **GitHub MCP** | Issues, PRs, поиск по репо, Actions | MIT | stable | must-have для dev-офиса | [github/github-mcp-server](https://github.com/github/github-mcp-server) |

### Документация и поиск

| Имя | Use case | Лицензия | Статус | Рекомендация | Ссылка |
|-----|----------|----------|--------|--------------|--------|
| **Context7** | Версия-специфичная документация библиотек, on-demand | MIT | stable | must-have для dev | [upstash/context7](https://github.com/upstash/context7) |
| **Brave Search MCP** | Веб-поиск без трекинга, альтернатива WebSearch | MIT | stable | nice-to-have | community / archived official |
| **Perplexity MCP** | Глубокий ресерч с источниками | community | stable | experimental | community |

### Браузер и автоматизация

| Имя | Use case | Лицензия | Статус | Рекомендация | Ссылка |
|-----|----------|----------|--------|--------------|--------|
| **Playwright MCP** | Клики, формы, E2E-тесты, кросс-браузер. Тяжёлый по токенам (50K+ на странице) | Apache-2.0 | stable | nice-to-have | [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp) |
| **Chrome DevTools MCP** | Дебаг живых сессий: console, network, performance | Apache-2.0 | stable (GA сент 2025) | must-have для frontend | [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) |

**Правило выбора:** Playwright = драйвить браузер (тесты), Chrome DevTools = наблюдать и дебажить (живая сессия). Оба одновременно — раздувают контекст.

### Опциональные (по проекту)

| Имя | Use case | Рекомендация |
|-----|----------|--------------|
| **Supabase MCP** | Если используешь Supabase как БД | nice-to-have |
| **Figma Dev Mode MCP** | Дизайн-в-код: парсит accessibility tree | nice-to-have |
| **Sentry MCP** | Чтение ошибок продакшна | experimental |
| **PostgreSQL MCP** | Прямой SQL-доступ. Опасно без read-only | experimental |
| **lightrag** | Графовая RAG над базой знаний | experimental |
| **shared-hub kanban** | Свой kanban-MCP без внешних SaaS | внутренний |

---

## Минимальный пакет «офис из коробки» (5 MCP)

1. **Filesystem** — структура файлов
2. **Memory** — долговременная память
3. **Notion** или **Linear** — задачи и знания
4. **Telegram Channels** — связь с офисом
5. **Context7** — актуальные доки библиотек

Расширения по профилю клиента: dev → +GitHub, +Chrome DevTools; продажник → +Gmail; маркетолог → +Brave Search, +Fetch.

---

## Hooks — все 13 lifecycle-событий

| Событие | Что делает | Когда нужно | Эталонный пример |
|---------|-----------|-------------|------------------|
| **Setup** | Repo init / периодическое обслуживание | Persistence env-переменных | `disler/claude-code-hooks-mastery/.claude/hooks/setup.py` |
| **SessionStart** | Старт/возобновление сессии (sources: startup/resume/clear/compact) | Инжект контекста: дата, план дня, последние записи памяти, активный клиент. Различать `startup` vs `resume` (на resume только дельта) | `disler/.claude/hooks/session_start.py` |
| **UserPromptSubmit** | После каждого ввода пользователя; **exit code 2 блокирует промпт** | Триаж задачи (Tier 1-4), подсказка скилла, валидация | `disler/.claude/hooks/user_prompt_submit.py` |
| **PreToolUse** | Перед вызовом любого тула; **exit code 2 блокирует tool** | Защита от `rm -rf`, `git push --force`, проверка путей, подтверждение для destructive | `disler/.claude/hooks/pre_tool_use.py` |
| **PermissionRequest** | Показ разрешения юзеру | Аудит, авто-allow read-only | `disler/.claude/hooks/permission_request.py` |
| **PostToolUse** | После tool успеха | Логирование в БД/Helicone, диффы git, форматирование, snapshot после Edit/Write | `disler/.claude/hooks/post_tool_use.py` |
| **PostToolUseFailure** | После tool провала | Структурированный error log | `disler/.claude/hooks/post_tool_use_failure.py` |
| **PreCompact** | Перед компакт-сессией | Бэкап транскрипта, сохранить state, handoff | `disler/.claude/hooks/pre_compact.py` |
| **Notification** | Когда Claude хочет уведомить | Push в Telegram через бот-планировщик, TTS-озвучка | `disler/.claude/hooks/notification.py` |
| **Stop** | Когда Claude закончил отвечать; **exit code 2 force-continuation** | Wrap-up, nudge от коуча, проверка прогресса | `disler/.claude/hooks/stop.py` |
| **SubagentStart** | Спавн субагента | Лог спавна | `disler/.claude/hooks/subagent_start.py` |
| **SubagentStop** | Субагент закончил; **exit code 2 блокирует завершение** | Верификация completion, логирование результата | `disler/.claude/hooks/subagent_stop.py` |
| **SessionEnd** | Завершение сессии | Финальный snapshot, итоги, запись в memory, Daily Reflection | `disler/.claude/hooks/session_end.py` |

Технические правила: 60-second timeout per hook, все matching хуки запускаются параллельно, JSON-input через stdin, output через stdout/stderr с exit-codes.

### Минимальный набор офиса (5 хуков)

1. **SessionStart → context-pack.sh** — инжект `agent-state.md`, активного клиента, даты, последних 3 событий из Notion
2. **PreToolUse → git-safety.sh** — запрет `rm -rf`, `git push --force`, проверка путей
3. **PostToolUse → auto-commit-snapshot.sh** — после Edit/Write делать snapshot-commit на отдельной ветке
4. **Stop → coach.sh** — каждые N сообщений nudge, фокус-чек, лимит 3/день
5. **UserPromptSubmit → tier-classifier.sh** — определить Revenue Tier и подсказать скилл

С релиза Claude Code 2.1.0 SessionStart hooks **не печатают** видимые сообщения — контекст инжектится через `hookSpecificOutput.additionalContext`.

---

## Сторонние сервисы

### Хранилище знаний

| Сервис | Сильное | Слабое | Когда выбирать |
|--------|---------|--------|----------------|
| **Notion** | Базы данных, шаринг, мощный MCP, Notion AI ($10/user) | Только облако, нет offline, цена при росте | B2B-офис, командная работа (default) |
| **Obsidian** | Local-first, plain markdown, плагины, графы | Нет встроенной коллаборации, AI через сторонние плагины | Личная база, приватность, исследователь |
| **Logseq** | Open-source, аутлайнер, ежедневные журналы | Меньше плагинов, медленный для больших баз | Daily-log, рефлексия |
| **Plain markdown в репо** | Версионирование git, переносимость | Нет UI для не-разработчика, нет поиска без grep | Dev-only офис |

**Эталон:** Notion для клиентов + plain markdown в `.claude/` и `knowledge/` для агентов.

### Задачи и проекты

| Сервис | Плюсы | Минусы | Рекомендация |
|--------|-------|--------|--------------|
| **Notion DB** | Единое место со знаниями, MCP официальный | Не оптимизирован под dev-таски | default для B2B-офиса |
| **Linear** | Лучший UX для разработки, MCP официальный | Цена ($8-14/seat), для не-dev избыточен | для dev-стартапов |
| **Todoist** | Простой, мобильный, GTD | Слабый MCP, нет связи со знаниями | пропустить |
| **GitHub Issues** | Бесплатно, рядом с кодом | Только для dev, плохо для смешанных задач | дополнение, не замена |

В клиентском шаблоне: **Notion = единый источник правды**, Linear выпилен.

### Деплой

| Сервис | Сильное | Слабое | Цена | Когда выбирать |
|--------|---------|--------|------|----------------|
| **Vercel** | Лучший DX для Next.js, edge, AI SDK, превью на каждый PR | Дорогой при росте, ограничения serverless (10s/15min) | Free → $20+/мес | Next.js, лендинги, фронт |
| **Railway** | Push → деплой за минуту, простой UX, БД из коробки | Не глобальный, не для serverless | $5+/мес | Полный фуллстек, прототипы |
| **Fly.io** | 35+ регионов, GPU, контейнеры, дёшево | Сложнее DX, нужен Dockerfile | $0-20+ | Глобальное распределение, AI-инференс |
| **VPS (свой)** | Полный контроль, фикс цена | Сами админите, нет автоскейла | $20-40/мес | Боты, MCP-хабы, постоянные процессы |

**Эталон:** Vercel (фронт) + VPS (боты, MCP) + Fly.io опционально для AI-инференса с GPU.

### Транскрипция (аудио → текст)

| Сервис | Цена/мин | Скорость | Языки | Слабое |
|--------|----------|----------|-------|--------|
| **Groq Whisper Large v3 Turbo** | ~$0.0006 | 164-299× реалтайм | 99 | Не стриминг, чанки |
| **Deepgram Nova-3** | ~$0.0036-0.0059 | 200-400ms финал | 36+, лучше на коде/жаргоне | Дороже |
| **OpenAI Whisper API** | ~$0.006 | средне | 99 | Дороже Groq в 10× |
| **Replicate Whisper** | $0.0028+ | средне | 99 | Холодный старт, оверкилл |

**Эталон:** Groq Whisper Turbo как default; Deepgram fallback когда нужна точность по терминологии или real-time.

### Генерация изображений

| Модель | Цена/img | Качество (Elo) | Сильное |
|--------|----------|----------------|---------|
| **Imagen 4 Fast (Google)** | $0.02 | хорошее | Самый дешёвый прод |
| **Imagen 4 Standard** | $0.04 | хорошее+ | Default баланс |
| **Imagen 4 Ultra** | $0.06 | топ | Премиум, для финалов |
| **Flux 2 Pro v1.1 (BFL/Replicate)** | $0.055 | 1265 Elo | Топ качество, фотореализм |
| **GPT Image 1.5 (OpenAI)** | $0.04-0.12 | 1264 Elo | Топ качество, текст в картинке |
| **Flux Schnell (Replicate)** | ~$0.003 | среднее | Очень дёшево, прототипы |
| **DALL-E 3** | устарел | — | пропустить |

**Эталон:** Imagen 4 Standard как default; Flux 2 Pro когда нужен фотореализм; GPT Image 1.5 когда нужен текст внутри картинки.

### Observability LLM-приложений

| Платформа | Сильное | Слабое | Цена |
|-----------|---------|--------|------|
| **Langfuse** | Open-source self-host, framework-agnostic OTel, dev-friendly | Self-host требует Postgres/ClickHouse/Redis/S3 | Free self-host / $50+ cloud |
| **Helicone** | One-line proxy-cache, analytics, мульти-провайдер | Слабее по eval/тестам | Free 50K req / $20+ |
| **LangSmith** | Глубочайшая интеграция с LangChain/LangGraph | Локап в LangChain, дорого | $39+/мес |
| **Arize Phoenix** | Drift detection, embedding analysis | Сложнее установки | self-host / cloud |

**Эталон:** Helicone для простого старта; Langfuse self-host когда офис вырастет; LangSmith пропустить (мы не на LangChain).

**Слепая зона 2026:** ни одна не интегрируется с MCP-tool-calls Claude Code из коробки. Решение — отдельный логирующий `PostToolUse` hook → своя БД или Helicone (паттерн `disler/claude-code-hooks-multi-agent-observability`).

---

## settings.json template — реальный пример с deny-rules

Иерархия конфигов: managed (enterprise) → `~/.claude/settings.json` (user) → `.claude/settings.json` (project, committed) → `.claude/settings.local.json` (project, gitignored). Правила: `deny → ask → allow`. Первый матч побеждает.

```json
{
  "permissions": {
    "deny": [
      "Read(.env)",
      "Read(.env.*)",
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Read(*.pem)",
      "Read(**/*.pem)",
      "Read(credentials*)",
      "Read(**/credentials*)",
      "Read(secrets*)",
      "Read(**/secrets*)",
      "Edit(.env)",
      "Edit(.env.*)",
      "Edit(**/.env)",
      "Edit(**/.env.*)",
      "Write(.env)",
      "Write(.env.*)",
      "Write(**/.env)",
      "Write(**/.env.*)",
      "Bash(rm:*)",
      "Bash(rm -rf:*)",
      "Bash(git push --force:*)",
      "Bash(git push --force-with-lease:*)",
      "Bash(git reset --hard:*)",
      "Bash(curl * | sh:*)",
      "Bash(wget * | bash:*)",
      "Bash(*--no-verify*)",
      "Bash(sudo:*)"
    ],
    "ask": [
      "Bash(npm install:*)",
      "Bash(pip install:*)",
      "Bash(git push:*)",
      "WebFetch(domain:*)"
    ],
    "allow": [
      "Read(*)",
      "Glob(*)",
      "Grep(*)",
      "Bash(ls:*)",
      "Bash(git status)",
      "Bash(git log:*)",
      "Bash(git diff:*)",
      "Bash(npm test:*)",
      "Bash(pytest:*)"
    ]
  },
  "env": {
    "ANTHROPIC_MODEL": "claude-opus-4-7",
    "BASH_DEFAULT_TIMEOUT_MS": "120000",
    "MCP_TIMEOUT": "30000",
    "ENABLE_TOOL_SEARCH": "auto:5"
  }
}
```

**Защитные практики:**
- Принцип минимума — Claude как «ненадёжный, но мощный стажёр». Только нужные права
- Sandbox (firejail/macOS Seatbelt) для defense-in-depth
- `--dangerously-skip-permissions` — никогда вне dev-среды (есть кейс удаления продакшн-БД)
- MCP trust — включать только серверы которым доверяешь на 100%, читать код перед `claude mcp add`
- Регулярно ревьюить settings.json — частая ошибка put allow выше deny → байпас

**Секреты только в `.env` (gitignored), читаются хуками/MCP через `process.env`.** Никогда не комитить `.env`.

---

## Эталонная структура `.claude/`

```
.claude/
├── CLAUDE.md                    # constitution, ≤300 строк
├── settings.json                # permissions, env, hooks (committed)
├── settings.local.json          # личные оверрайды (gitignored)
├── .mcp.json                    # MCP-серверы
├── agents/                      # subagent definitions
│   └── <agent-name>/
│       ├── core.md              # ≤200 строк
│       ├── soul.md              # личность
│       └── memory.md            # ≤500 токенов
├── skills/                      # реюзабельные навыки
│   └── <skill-name>/SKILL.md
├── commands/                    # slash-команды
│   └── <command>.md
├── hooks/                       # bash/python скрипты
│   ├── session-start.sh
│   ├── pre-tool-use.sh
│   ├── post-tool-use.sh
│   └── stop.sh
├── rules/                       # path-conditional правила (frontmatter-routed)
└── docs/                        # справка
```

CLAUDE.md в корне — самый важный файл, читается каждую сессию. Концентрированный, со ссылками на детали.
