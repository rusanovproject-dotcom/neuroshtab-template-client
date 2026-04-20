# Demiurg — Реестр субагентов (v2.0)

## Ядро (каждый агент проходит этот конвейер)

```
Knowledge Miner → Builder → validate-agent.sh → Validator → [Refiner]
```

| Субагент | Роль | Модель | Файл |
|----------|------|--------|------|
| **Knowledge Miner** | Сбор знаний из workspace ДО сборки | sonnet | `agents/knowledge-miner.md` |
| **Builder** | Создание CLAUDE.md + skills/ (few-shot из examples/) | opus | `agents/builder.md` |
| **Validator** | Проверка по 5 блокам, score 0-100 | sonnet | `agents/validator.md` |
| **Refiner** | Фиксы по issues Validator'а | sonnet | `agents/refiner.md` |

## Дополнительно (TEAM mode)

| Субагент | Роль | Модель | Файл |
|----------|------|--------|------|
| **Researcher** | Best practices и паттерны | sonnet | `agents/researcher.md` |
| **Auditor** | Аудит существующего workspace | sonnet | `agents/auditor.md` |
| **Judge** | Оценка системы целиком (5 осей) | opus | `agents/judge.md` |

## Специалисты (вызов по задаче)

| Субагент | Роль | Модель | Файл |
|----------|------|--------|------|
| **Offer Architect** | Проектирование офферов по Хормози (Value Equation, Grand Slam) | sonnet | `~/.claude/agents/offer-specialist.md` |

## Параллелизм

| Этап | Параллельно | Последовательно |
|------|------------|----------------|
| Разведка (TEAM) | Researcher + Auditor | — |
| Сборка агента | — | Miner → Builder → validate.sh → Validator |
| Review (TEAM) | — | Judge → Refiner → re-Judge |

## Скрипты

- `scripts/validate-agent.sh` — проверка без LLM (80% проблем бесплатно)
- `scripts/validate.sh` — проверка всей системы
- `scripts/validate-office.sh` — проверка офиса

## Конвейер качества

```
Demiurg (создаёт) → validate-agent.sh → Validator → Brahma (аудит) → Cherry (полировка)
```

- Brahma: `../brahma/ (будет добавлен через /add-agent)` — 8 измерений, 0-100
- AI Cherry: `` — 7 осей, 0-10

## Запуск субагентов

```
Agent("Прочитай agents/knowledge-miner.md. Brief: {role}, {tasks}. Workspace: {path}")
Agent("Прочитай agents/builder.md. Brief + knowledge/{agent}/ готовы. Target: {path}")
Agent("Прочитай agents/validator.md. Проверь агента: {path}")
```
