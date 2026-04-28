# Alex Marketer — install manifest

Машиночитаемые метаданные для установки пака через скилл `/install-agent alex-marketer`.

---

## Metadata

```yaml
agent_id: alex-marketer
agent_name_human: Алекс Маркетолог
agent_name_in_chat: Алекс
short_role: Маркетолог-Хормози. Рынок > Оффер > Копия. Распаковывает ЦА (пайплайн разбора аудитории), собирает Grand Slam Offer (Value Equation), строит воронку. Двигает проект гипотезами (max 5 + Key). Режет хуйню, защищает сильные идеи.
trigger_keywords: [алекс, маркетолог, хормози, hormozi, маркетинг, ЦА, целевая аудитория, сегмент, сегменты, оффер, value equation, grand slam, позиционирование, воронка, лид-магнит, трипваер, лестница, продуктовая линейка, онбординг алекс, алекс онбординг, привет алекс, зашёл алекс, давай алекс, алекс представься, алекс начни, познакомимся, распакуй ЦА, распакуй проект, найди сегменты, новый сегмент, кто наш клиент, на кого работаем, распакуй продукт, распакуй оффер, распакуй воронку, ревизия, где деньги, avatar, ICP, провёл диагностику, был созвон, клиент оплатил, клиент отказался, БПСВ, БПКСВ, awareness, точка входа воронки, разведай конкурентов, анализ рынка, голубой океан, конкурентный анализ, пятничная ревизия, обнови сегмент, ревизия сегмента, продолжим с ЦА, вернёмся к сегментам, где мы по ЦА, что осталось по сегментам, собери отчёт по ЦА, HTML по сегментам, артефакт ментору, упакуй ЦА визуально]
version: 2.0.0
requires: []
provides_pipeline:
  - audience-unpack-pipeline  # глубокий пайплайн распаковки ЦА для шаблона project-template/audience/segments/
  - product-unpack-hormozi   # пайплайн распаковки оффера через 6 диалоговых протоколов (project-template/product/_protocols/)
  - funnel-unpack-channel-first  # пайплайн распаковки воронки per-segment
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

# Templates копируются в папку агента — мета-скилл /unpack-project и
# /marketer-revision используют их при первом запуске.
templates:
  - src: templates/customers.template.md
    dest: office/agents/alex-marketer/templates/customers.template.md
  - src: templates/hypotheses.template.md
    dest: office/agents/alex-marketer/templates/hypotheses.template.md

# Шаблон папки распаковки ЦА — критичный, без него /audience-stage Шаг 2
# падает на любом первом запуске у нового клиента.
project_templates:
  - src: ../../projects/_template-audience/
    dest: projects/_template-audience/
    recursive: true
    preserve_if_exists: true   # если у клиента уже есть свой _template-audience — не перезаписывать
    description: |
      Шаблон папки <main>-audience/ — копируется в проекты клиента.
      Используется в /audience-stage Шаг 2 как источник структуры:
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
      | **Алекс Маркетолог** | JTBD-методология Замесина для распаковки ЦА → Hormozi для оффера → воронка. Клиентская база (через `/marketer-enable-meetings`) | *«онбординг алекс», «распакуй ЦА», «JTBD», «распакуй оффер», «распакуй воронку»* |

  - file: office/agents/director/core.md
    section: "## Роутинг"
    add_rows: |
      | онбординг алекс, привет алекс, зашёл алекс, давай алекс, познакомимся, алекс представься | **Алекс** → `/alex-onboarding` (точка входа — 6 тактов первого контакта) |
      | распакуй ЦА, найди сегменты, кто наша ЦА, JTBD, jobs to be done, работа клиента, поехали распаковывать | **Алекс** → `/jtbd-kdigital` *(если онбординг не пройден — авто-route на `/alex-onboarding`)* |
      | проверь JTBD, свежий взгляд на анализ, аудит JTBD, критик JTBD | **Алекс** → `/jtbd-critic-kdigital` *(новый чат, чистый контекст)* |
      | распакуй продукт, распакуй оффер, value equation, grand slam | **Алекс** → `/unpack-product` *(только после закрытия JTBD)* |
      | добавить продукт, второй core, новый продукт в ladder | **Алекс** → `/product-add` |
      | распакуй воронку, по сегменту воронка, journey | **Алекс** → `/unpack-funnel` |
      | провёл диагностику, был созвон, клиент оплатил, клиент отказался, вот транскрипт | **Алекс** → `/marketer-log-deal` *(требует активации модуля встреч)* |
```

---

## Post-install message to client

```
✅ Алекс в команде.

Когда захочешь начать — напиши **«онбординг алекс»** или **«привет алекс»**.
Я открою твой офис, прочитаю что у тебя живое, и вернусь с диагнозом
и одним вопросом — про точку приложения усилий. Никаких анкет на старт.

После онбординга — единая линия:

1. **JTBD-распаковка ЦА по методологии Замесина** (`/jtbd-kdigital`)
   13 шагов на каждый из 3-5 сегментов: Big Job → jobStory → Точки А/Б →
   граф работ → Consideration Set → барьеры → Entry/Monetization → оценка.
   Работаем на ТВОЕЙ фактуре (кейсы, посты, переписки), не на парсинге
   интернета. Результат — `JTBD_анализ.md` единый документ.

2. **Финальная проверка критиком** (`/jtbd-critic-kdigital`)
   В НОВОМ чате — свежий взгляд, чистый контекст. Проверка 5 стратегических
   флагов + связей + единообразия + лёгкости коммуникации. Правки в формате
   БЫЛО/ПРЕДЛАГАЮ/ПРИЧИНА — ты принимаешь по номерам.

3. **Stage 2 — Оффер по Hormozi** (`/unpack-product` → `/product-build`)
   Grand Slam Offer на основе закрытой JTBD-распаковки.

4. **Stage 3 — Воронка** (`/unpack-funnel` → `/funnel-build`)
   Per-segment маршрут, каналы, касания.

5. **Опционально — модуль встреч** (`/marketer-enable-meetings`)
   Если есть диагностические/продающие созвоны — карточки клиентов,
   парсинг транскриптов, банк возражений.

Закон: я не перезаписываю твои файлы вывода (core-offer, positioning).
Только diff в hypotheses.md → Log. Ты принимаешь командой /accept или
отвергаешь. Голос остаётся за тобой.

Дальше — пойдём.
```
