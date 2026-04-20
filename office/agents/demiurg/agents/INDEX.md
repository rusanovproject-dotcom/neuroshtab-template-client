# Субагенты Demiurg — Индекс

Спавнить через Agent tool. Модель указана для каждого.

## Ядро (каждый агент проходит)

| Файл | Роль | Модель | Этап |
|------|------|--------|------|
| `knowledge-miner.md` | Сбор знаний из workspace ДО сборки | sonnet | 2 (Knowledge) |
| `builder.md` | Создание CLAUDE.md + skills/ (с few-shot) | opus | 3 (Build) |
| `validator.md` | Проверка агента по 5 блокам (100 баллов) | sonnet | 4 (Validate) |
| `refiner.md` | Фиксы по issues Validator'а | sonnet | 5 (Iterate) |

## TEAM mode (дополнительно)

| Файл | Роль | Модель | Фаза |
|------|------|--------|------|
| `researcher.md` | Best practices и паттерны | sonnet | 1 (Разведка) |
| `auditor.md` | Аудит существующего workspace | sonnet | 1 (Разведка) |
| `judge.md` | Оценка системы целиком (5 осей) | opus | Review |

## CustDev pipeline

| Файл | Роль | Модель | Фаза |
|------|------|--------|------|
| `persona-builder.md` | Создание синтетических персон из реальных данных | sonnet | 2 (Персоны) |
| `interviewer.md` | Симуляция глубинных CustDev-интервью | opus | 4 (Интервью) |

## Конвейер

```
Knowledge Miner → Builder → validate-agent.sh → Validator → [Refiner → Validator]
```

## Скрипт

`scripts/validate-agent.sh` — бесплатная проверка без LLM (запускать перед Validator).
