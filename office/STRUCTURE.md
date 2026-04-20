# Карта офиса — где что лежит

```
/                               — корень офиса
│
├── README.md                   — что это, три шага старта
├── QUICK-START.md              — первая задача за 5 минут
├── SETUP.md                    — полный чеклист установки
├── .env.example                — шаблон переменных окружения
├── .env                        — твои секреты (не в git)
│
├── inbox/                      — всё непонятное сюда, потом /intake
│
├── projects/                   — папка проектов
│   ├── README.md               — как создавать проекты (/new-project)
│   └── _example-project/       — пример заполненного проекта
│       └── CLAUDE.md           — контекст проекта для агентов
│
├── clients/                    — папка клиентов
│   ├── README.md               — как добавлять клиентов (/new-client)
│   ├── INDEX.md                — реестр всех клиентов
│   └── _template/              — шаблон карточки клиента
│
├── knowledge/                  — база знаний
│   ├── README.md               — как добавлять знания (/new-knowledge)
│   └── INDEX.md                — индекс всех карточек знаний
│
└── office/                     — движок офиса (обычно не трогаешь)
    ├── AGENTS.md               — карта команды
    ├── STRUCTURE.md            — этот файл
    ├── agents/                 — конфиги агентов
    │   ├── director/
    │   ├── producer/
    │   ├── copywriter/
    │   ├── tech-lead/
    │   ├── designer/
    │   ├── intelligence/
    │   ├── hermes/
    │   ├── demiurg/
    │   ├── brahma/
    │   └── para/
    ├── skills/                 — скиллы-генераторы
    │   ├── setup/              — /setup — онбординг нового пользователя
    │   ├── intake/             — /intake — разбор инбокса
    │   ├── new-project/        — /new-project — создание проекта
    │   ├── new-client/         — /new-client — добавление клиента
    │   └── new-knowledge/      — /new-knowledge — добавление знания
    ├── protocols/              — протоколы работы команды
    └── templates/              — шаблоны документов
```

---

**Правило:** всё что касается твоей работы — в `projects/`, `clients/`, `knowledge/`, `inbox/`. Папку `office/` редактировать не нужно — только если хочешь поменять поведение агентов.
