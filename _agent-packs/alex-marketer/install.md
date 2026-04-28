# Alex Marketer — install manifest

Машиночитаемые метаданные для установки пака через скилл `/install-agent alex-marketer`.

---

## Metadata

```yaml
agent_id: alex-marketer
agent_name_human: Алекс Маркетолог
agent_name_in_chat: Алекс
short_role: Маркетолог-навигатор. Распаковывает ЦА через JTBD-методологию (13 шагов на сегмент × 3-5 сегментов). На выходе — единый документ JTBD_анализ.md с сегментами, jobStory, картой работ, барьерами, ранжированием.
trigger_keywords: [алекс, маркетолог, маркетинг, ЦА, целевая аудитория, сегмент, сегменты, JTBD, jobs to be done, работа клиента, big job, core job, онбординг алекс, алекс онбординг, привет алекс, зашёл алекс, давай алекс, алекс представься, алекс начни, познакомимся, распакуй ЦА, распакуй проект, найди сегменты, новый сегмент, кто наш клиент, на кого работаем, провёл диагностику, был созвон, клиент оплатил, клиент отказался]
version: 3.0.0
requires: []
provides_pipeline:
  - jtbd-pipeline  # JTBD-распаковка ЦА (13 шагов на сегмент)
```

---

## Files to copy

Источник — `_agent-packs/alex-marketer/`, цель — `office/agents/alex-marketer/`. Копируется рекурсивно.

```yaml
files:
  - src: core.md
    dest: office/agents/alex-marketer/core.md
  - src: soul.md
    dest: office/agents/alex-marketer/soul.md
  - src: CLAUDE.md
    dest: office/agents/alex-marketer/CLAUDE.md
  - src: overrides.md
    dest: office/agents/alex-marketer/overrides.md
    preserve_if_exists: true
  - src: memory.md
    dest: office/agents/alex-marketer/memory.md
    preserve_if_exists: true
  - src: failures.md
    dest: office/agents/alex-marketer/failures.md
    preserve_if_exists: true
  - src: knowledge/
    dest: office/agents/alex-marketer/knowledge/
    recursive: true
  - src: skills/
    dest: .claude/skills/
    recursive: true

# Templates копируются в папку агента — используются Алексом
# при первом запуске для нового проекта.
templates:
  - src: templates/customers.template.md
    dest: office/agents/alex-marketer/templates/customers.template.md
  - src: templates/hypotheses.template.md
    dest: office/agents/alex-marketer/templates/hypotheses.template.md

# Шаблон папки распаковки ЦА — критичный, без него /jtbd Шаг 2
# падает на любом первом запуске у нового клиента.
project_templates:
  - src: ../../projects/_template-audience/
    dest: projects/_template-audience/
    recursive: true
    preserve_if_exists: true   # если у клиента уже есть свой _template-audience — не перезаписывать
    description: |
      Шаблон папки <main>-audience/ — копируется в проекты клиента.
      Используется в /jtbd Шаг 2 как источник структуры:
      audience/segments/, inbox/_new/, _state/, hypotheses.md и т.д.

# Опциональное расширение (модуль встреч) — не копируется автоматически,
# активируется отдельной командой /marketer-enable-meetings
extensions:
  - id: sales-meetings
    src: extensions/sales-meetings/
    dest: office/agents/alex-marketer/extensions/sales-meetings/
    auto_install: false
    activated_by: /marketer-enable-meetings
```

---

## Updates to existing files

```yaml
updates:
  - file: CLAUDE.md
    section: "## Обязательный layered include при старте"
    add_line: "@office/agents/alex-marketer/core.md"

  - file: office/AGENTS.md
    section: "## Активная команда"
    add_row: |
      | **Алекс Маркетолог** | Распаковка ЦА через JTBD-методологию. На выходе — `JTBD_анализ.md` с сегментами, jobStory, картой работ, барьерами. | *«онбординг алекс», «распакуй ЦА», «JTBD», «найди сегменты»* |

  - file: office/agents/director/core.md
    section: "## Роутинг"
    add_rows: |
      | онбординг алекс, привет алекс, зашёл алекс, давай алекс, познакомимся, алекс представься | **Алекс** → `/alex-onboarding` (точка входа — 6 тактов первого контакта) |
      | распакуй ЦА, найди сегменты, кто наша ЦА, JTBD, jobs to be done, работа клиента, поехали распаковывать | **Алекс** → `/jtbd` *(если онбординг не пройден — авто-route на `/alex-onboarding`)* |
      | проверь JTBD, свежий взгляд на анализ, аудит JTBD, критик JTBD | **Алекс** → `/jtbd-critic` *(новый чат, чистый контекст)* |
      | провёл диагностику, был созвон, клиент оплатил, клиент отказался, вот транскрипт | **Алекс** → `/marketer-log-deal` *(требует активации модуля встреч)* |
```

---

## Post-install message to client

```
✅ Алекс в команде.

Когда захочешь начать — напиши **«онбординг алекс»** или **«привет алекс»**.
Я открою твой офис, прочитаю что у тебя живое, и вернусь с диагнозом
и одним вопросом — про точку приложения усилий. Никаких анкет на старт.

После онбординга — простая база:

1. **JTBD-распаковка ЦА** (`/jtbd`)
   13 шагов на каждый из 3-5 сегментов: Big Job → jobStory → Точки А/Б →
   граф работ → Consideration Set → барьеры → Entry/Monetization → оценка
   → ранжирование → механики ценности → стратегические гипотезы.

   Работаем на ТВОЕЙ фактуре (кейсы, посты, переписки, отзывы клиентов),
   не на парсинге интернета. Результат — единый документ
   `JTBD_анализ_<main>.md` со всеми сегментами и блоками.

2. **Финальная проверка критиком** (`/jtbd-critic`)
   В НОВОМ чате — свежий взгляд, чистый контекст. Проверка 5 стратегических
   флагов + связей между сущностями + единообразия + абстракций + лёгкости
   коммуникации + сверка с фактурой. Правки в формате
   БЫЛО/ПРЕДЛАГАЮ/ПРИЧИНА — ты принимаешь по номерам.

3. **Опционально — модуль встреч** (`/marketer-enable-meetings`)
   Если есть диагностические/продающие созвоны — карточки клиентов,
   парсинг транскриптов, банк возражений.

Stage 2 (оффер) и Stage 3 (воронка) пока не подключены — добавим отдельно
когда базовая распаковка ЦА будет давать стабильный результат.

Дальше — пойдём.
```
