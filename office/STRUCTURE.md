# Карта офиса — где что лежит

```
/                               — корень офиса
│
├── README.md                   — что это, как начать
├── CLAUDE.md                   — правила Claude (layered include всех core-агентов)
├── .env.example                — шаблон переменных окружения
├── .env                        — твои секреты (не в git)
│
├── inbox/                      — всё непонятное сюда, потом /intake
│   └── docs/                   — документы для онбординга со Стратегом
│
├── projects/                   — папка проектов
│   ├── README.md               — как создавать проекты (/new-project)
│   ├── _example-project/       — пример заполненного проекта
│   └── _template/              — шаблоны pre-work для организатора программы
│
├── clients/                    — папка клиентов (если у тебя B2B)
│   ├── README.md               — как добавлять клиентов (/new-client)
│   └── INDEX.md                — реестр всех клиентов
│
├── knowledge/                  — база знаний
│   ├── README.md               — как добавлять знания (/new-knowledge)
│   ├── INDEX.md                — индекс всех карточек
│   └── brand/                  — Brand Book проекта (заполняется после установки Дизайнера)
│
├── _agent-packs/               — готовые паки агентов, ставятся через /install-agent
│   └── designer/               — Дизайнер (Brand Book + промты для визуала)
│
└── office/                     — движок офиса (обычно не трогаешь)
    ├── AGENTS.md               — карта команды (единственный источник правды о составе)
    ├── STRUCTURE.md            — этот файл
    ├── client-profile.md       — центральная карточка клиента (читают все агенты)
    ├── strategy/               — живая стратегия программы (заполняется Стратегом)
    ├── agents/                 — конфиги 3 core-агентов
    │   ├── director/           — оркестратор, точка входа
    │   ├── strategist/         — партнёр 6-недельной программы
    │   └── demiurg/            — Архитектор команды (структура офиса)
    ├── protocols/              — протоколы работы
    └── templates/              — шаблоны документов (client, project, knowledge)
```

## Layered memory у каждого агента

В папке каждого агента лежит одинаковый набор файлов:
```
office/agents/<agent>/
├── core.md       — ядро агента (обновляется из template при будущих апдейтах)
├── overrides.md  — твои персональные правила (приоритет над core, не перезаписываются)
├── memory.md     — append-only, агент сам пишет decisions/patterns/context
├── failures.md   — append-only, агент пишет об ошибках чтобы не повторить
└── CLAUDE.md     — склейка `@core.md @overrides.md` (Claude Code читает это)
```

## Скиллы

`.claude/skills/`:
- **Базовые:** setup, intake, new-project, new-client, new-knowledge
- **Стратег:** strategist-intake, -unpack, -discovery, -prepare, -roadmap, -checkin
- **Расширение офиса:** install-agent (ставит пак из `_agent-packs/`)

---

**Правило:** твоя работа — в `inbox/`, `projects/`, `clients/`, `knowledge/`. Папку `office/` редактировать не нужно — только если меняешь поведение агентов (через `overrides.md`).

**О составе команды:** актуальный список установленных помощников — в `office/AGENTS.md`. Это единственный источник правды. Новые помощники ставятся командой `/install-agent <name>` из готовых паков в `_agent-packs/` (принципы интеграции — `office/AGENT-INTEGRATION-PRINCIPLES.md`).
