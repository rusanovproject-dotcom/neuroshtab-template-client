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
│   └── INDEX.md                — индекс всех карточек
│
└── office/                     — движок офиса (обычно не трогаешь)
    ├── AGENTS.md               — карта команды (3 агента)
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

В папке каждого из 3 агентов лежит одинаковый набор файлов:
```
office/agents/<agent>/
├── core.md       — ядро агента (обновляется из template при будущих апдейтах)
├── overrides.md  — твои персональные правила (приоритет над core, не перезаписываются)
├── memory.md     — append-only, агент сам пишет decisions/patterns/context
├── failures.md   — append-only, агент пишет об ошибках чтобы не повторить
└── CLAUDE.md     — склейка `@core.md @overrides.md` (Claude Code читает это)
```

## Скиллы

`.claude/skills/` — 11 скиллов:
- **Базовые:** setup, intake, new-project, new-client, new-knowledge
- **Стратег:** strategist-intake, -unpack, -discovery, -prepare, -roadmap, -checkin

---

**Правило:** твоя работа — в `inbox/`, `projects/`, `clients/`, `knowledge/`. Папку `office/` редактировать не нужно — только если меняешь поведение агентов (через `overrides.md`).

**О других помощниках:** копирайтер, дизайнер, продажник и т.д. будут подключены позже отдельным шагом программы. Сейчас в офисе 3 основных: Director + Стратег + Архитектор команды.
