# Демиург — install manifest

Машиночитаемые метаданные для установки пака через скилл `/install-agent demiurg`.

Этот пак — **переустановка** базового Демиурга в офисе. После установки `office/agents/demiurg/` полностью заменяется новой версией (ядро, knowledge, агенты-сабсборщики, скрипты, скиллы), а персональная память пользователя (`memory.md`, `failures.md`, `overrides.md`) — сохраняется через `preserve_if_exists`.

---

## Metadata

```yaml
agent_id: demiurg
agent_name_human: Архитектор команды
agent_name_in_chat: Архитектор
short_role: Архитектор AI-офиса и создатель персональных агентов. Строит агентов ВОКРУГ знаний (Knowledge Mining → Build → Validate → Iterate с автоматическим самоконтролем). Делает аудит существующего офиса (`/audit-project`).
trigger_keywords: [архитектор, демиург, demiurg, собери агента, создай агента, новый агент, добавь помощника, собери команду, AI-офис, wizard, build, пересобери, проверь офис, наведи порядок, аудит офиса, audit-project, реструктуризация, бардак в офисе, переделай структуру, scout, разведай домен]
version: 2.0.0
requires: []
provides_pipeline:
  - agent-build  # 8-фазный конвейер сборки одного агента (single mode)
  - team-build   # wizard сборки целого AI-офиса с нуля
  - office-audit # универсальный аудит офиса по 5 категориям с P0/P1/P2
```

---

## Files to copy

Источник — `_agent-packs/demiurg/`, цель — `office/agents/demiurg/` (для ядра/знаний/субагентов/скриптов) и `.claude/skills/` (для скиллов).

```yaml
files:
  - src: CLAUDE.md
    dest: office/agents/demiurg/CLAUDE.md
  - src: core.md
    dest: office/agents/demiurg/core.md
  - src: soul.md
    dest: office/agents/demiurg/soul.md
  - src: overrides.md
    dest: office/agents/demiurg/overrides.md
    preserve_if_exists: true
  - src: memory.md
    dest: office/agents/demiurg/memory.md
    preserve_if_exists: true
  - src: failures.md
    dest: office/agents/demiurg/failures.md
    preserve_if_exists: true

  # Knowledge base — методология, паттерны, примеры (полностью обновляется)
  - src: knowledge/
    dest: office/agents/demiurg/knowledge/
    recursive: true

  # Субагенты-сборщики (Knowledge Miner, Builder, Validator, Refiner, ...)
  - src: agents/
    dest: office/agents/demiurg/agents/
    recursive: true

  # Скрипты валидации (validate-agent.sh, validate-office.sh, wire-check.sh)
  - src: scripts/
    dest: office/agents/demiurg/scripts/
    recursive: true

  # Скиллы — копируются в .claude/skills/ для прямого вызова через слэш-команды
  - src: skills/build/
    dest: .claude/skills/build/
    recursive: true
  - src: skills/audit-project/
    dest: .claude/skills/audit-project/
    recursive: true
```

---

## Folders to ensure

```yaml
folders:
  - office/agents/demiurg/
  - office/agents/demiurg/knowledge/
  - office/agents/demiurg/agents/
  - office/agents/demiurg/scripts/
  - .claude/skills/build/
  - .claude/skills/audit-project/

# Папка для внешних research-досье, которые читает Knowledge Miner
  - knowledge/scout/
```

---

## Updates to existing files

```yaml
updates:
  - file: CLAUDE.md
    section: "## Обязательный layered include при старте"
    add_line: "@office/agents/demiurg/core.md"
    skip_if_present: true

  - file: office/AGENTS.md
    section: "## Установленные агенты"
    add_row: |
      | **Архитектор команды** | Архитектор AI-офиса и создатель персональных агентов. Строит агентов вокруг знаний, делает аудит офиса (`/audit-project`) | *«собери агента», «новый помощник», «проверь офис», «наведи порядок», «реструктуризация»* |
    replace_if_present: true   # обновляем строку чтобы отразить новую роль (не просто "помогает со структурой")

  - file: office/agents/director/core.md
    section: "## Команда офиса"
    add_line: |
      - **Архитектор команды (`@demiurg`)** — собирает новых помощников под задачи пользователя (если в `_agent-packs/` нет готового пака), реорганизует офис, делает аудит. Конвейер `Knowledge Mining → Build → Validate → Iterate`.
    skip_if_present: true

  - file: office/agents/director/core.md
    section: "## Роутинг"
    add_rows: |
      | собери / создай агента, нужен новый помощник (которого нет в _agent-packs/), пересобери | **Архитектор** → `/build` |
      | собери команду, AI-офис с нуля, wizard | **Архитектор** → `/build` (TEAM mode) |
      | проверь офис, наведи порядок, есть ли дыры в архитектуре, аудит офиса | **Архитектор** → `/audit-project` |
      | бардак в папках, реорганизуй, перенастрой структуру | **Архитектор** (диалог про архитектуру) |

  - file: office/agents/director/knowledge/routing-patterns.md
    section: "## Core-роутинг"
    add_rows: |
      | «собери агента» / «создай помощника» / «нужен новый агент» | Архитектор → `/build` SINGLE | если такого пака нет в `_agent-packs/` — иначе сначала `/install-agent` |
      | «собери команду» / «AI-офис с нуля» / «wizard» | Архитектор → `/build` TEAM | долгая сборка 45–90 мин, предупредить пользователя |
      | «проверь офис» / «наведи порядок» / «аудит» | Архитектор → `/audit-project` | универсальный, без интерпретации «по наитию» |
```

---

## First task

```yaml
first_task:
  suggestion: "лёгкий аудит офиса — посмотрю что уже есть, где пустые папки, где не хватает документации"
  why: "перед сборкой новых агентов полезно знать карту того что уже стоит — иначе можно дублировать или не закрыть реальную дыру"
  example_phrase: "проверь офис"
  command: "/audit-project"
```

---

## Post-install message to client

```
✅ Архитектор обновлён.

Я Архитектор команды. Моя работа — строить новых помощников
под твои задачи и держать офис в чистоте.

Что я умею:

1. **Собрать нового помощника под задачу.** Скажи «собери агента»
   или опиши что нужно — задам 5–6 уточняющих вопросов одним
   сообщением, потом разведаю мировой топ по теме, соберу знания
   из твоего офиса и построю помощника по 8-фазному конвейеру.
   Score < 60 = переделка с нуля. ≥ 80 = в команду.

   Перед сборкой проверю: нет ли уже готового пака в `_agent-packs/`.
   Если есть — сразу подключим через `/install-agent`, не буду
   тратить твоё время на пересборку с нуля.

2. **Собрать команду с нуля.** Если нужен целый AI-офис — скажи
   «собери команду». Запустится wizard на 45–90 минут: интервью,
   blueprint, сборка каждого помощника, wiring, soul, онбординг.

3. **Проверить офис.** «Проверь офис» / «наведи порядок» —
   запущу `/audit-project`. Универсальный аудит по 5 категориям
   с приоритетами P0/P1/P2. Не интерпретирую «по наитию».

4. **Реорганизовать структуру.** Если в папках бардак или
   процессы не сходятся — обсудим что нравится / что мешает,
   предложу 2–3 варианта, без молчаливых правок.

Закон: я не строю помощников «на надежде». Если знаний для
сборки в офисе мало (Knowledge Miner score < 5) — остановлюсь
и спрошу что добавить. Это не упрямство, это защита от агента,
который будет галлюцинировать.

Память сохранена — твои прошлые решения и правила на месте.
Обновились ядро, методология, субагенты-сборщики и скрипты
валидации.

Дальше — давай начнём с лёгкого аудита? Скажи «проверь офис»
и я покажу карту.
```
