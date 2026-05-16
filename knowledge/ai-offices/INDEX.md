---
title: AI-офисы — методология
updated: 2026-05-05
status: live
---

# AI-офисы — INDEX

> База знаний по методологии AI-офисов: как строить агентов, управлять памятью, проектировать скиллы, наводить порядок, выбирать инструменты.

## Точка входа для агентов

| Когда задача | Что читать ПЕРЕД работой |
|--------------|--------------------------|
| Сборка/правка агента | `distilled/agent-design.md` + `distilled/memory-architecture.md` |
| Создание скилла | `distilled/skill-design.md` |
| Аудит офиса / уборка / governance | `distilled/governance-cleanup.md` + `distilled/failures-to-avoid.md` |
| Проектирование офиса с нуля | `distilled/10-principles.md` |
| Настройка роутинга / триггеров | `distilled/routing-triggers.md` |
| Подбор инструментов / MCP / hooks | `distilled/tools-mcp-stack.md` |
| Ревью артефакта (Writer/Reviewer) | `distilled/builder-validator.md` |

## Структура

```
ai-offices/
├── INDEX.md           ← ты здесь
├── distilled/         ← дистилляты — главные практические выжимки
│   ├── 10-principles.md
│   ├── memory-architecture.md
│   ├── skill-design.md
│   ├── agent-design.md
│   ├── builder-validator.md
│   ├── governance-cleanup.md
│   ├── tools-mcp-stack.md
│   ├── routing-triggers.md
│   └── failures-to-avoid.md
└── references/        ← эталоны вовне
    ├── repos.md          ← публичные репо для подражания
    ├── people.md         ← топ-практики (за кем следить)
    ├── tools.md          ← каталог MCP, hooks, сервисов
    └── methodologies.md  ← Compound Engineering, Florian rubric, AGENTS.md и др.
```

## Как пополнять

Эта папка — методология. Здесь живут универсальные знания, не привязанные к конкретному проекту партнёра.

- **Новое исследование** по архитектуре офисов → дополняй `distilled/<topic>.md` (или создай новый дистиллят)
- **Найден эталонный репо/человек/инструмент** → дополняй `references/<file>.md`
- **Своё решение по архитектуре офиса** → не сюда, в `office/decisions/` или ADR проекта

## Кто использует эту папку

- **Демиург** (Архитектор команды) — перед сборкой нового агента читает `distilled/agent-design.md` и `memory-architecture.md`
- **Architect-of-Order** (Архитектор офиса) — перед аудитом читает `distilled/governance-cleanup.md`, `failures-to-avoid.md`, `routing-triggers.md`
- **Director** — при стратегических решениях по офису обращается к `distilled/10-principles.md`
