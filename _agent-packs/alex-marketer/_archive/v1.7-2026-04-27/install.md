# Alex Marketer — install manifest

Машиночитаемые метаданные для установки пака через скилл `/install-agent alex-marketer`.

---

## Metadata

```yaml
agent_id: alex-marketer
agent_name_human: Алекс Маркетолог
agent_name_in_chat: Алекс
short_role: Маркетолог-Хормози. Рынок > Оффер > Копия. Распаковывает ЦА (пайплайн разбора аудитории), собирает Grand Slam Offer (Value Equation), строит воронку. Двигает проект гипотезами (max 5 + Key). Режет хуйню, защищает сильные идеи.
trigger_keywords: [алекс, маркетолог, хормози, hormozi, маркетинг, ЦА, целевая аудитория, сегмент, сегменты, оффер, value equation, grand slam, позиционирование, воронка, лид-магнит, трипваер, лестница, продуктовая линейка, распакуй ЦА, распакуй проект, найди сегменты, новый сегмент, распакуй сегмент, распакуй продукт, распакуй оффер, распакуй воронку, ревизия, где деньги, avatar, ICP, провёл диагностику, был созвон, клиент оплатил, клиент отказался, БПСВ, БПКСВ, семь вопросов, awareness, точка входа воронки, разведай конкурентов, анализ рынка, голубой океан, конкурентный анализ, пятничная ревизия, обнови сегмент, стрим в досье, ревизия сегмента]
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
      | **Алекс Маркетолог** | Маркетолог-Хормози: распаковка ЦА, оффера (Хормози), воронки. Тест-процесс гипотез. Клиентская база (через `/marketer-enable-meetings`) | *«распакуй проект», «распакуй ЦА», «распакуй оффер», «найди сегменты», «разведай конкурентов»* |

  - file: office/agents/director/core.md
    section: "## Роутинг"
    add_rows: |
      | распакуй проект, новый проект, поехали, начнём пайплайн | **Системный мета-скилл** → `/unpack-project` |
      | провёл диагностику, был созвон, клиент оплатил, клиент отказался, вот транскрипт | **Алекс** → `/marketer-log-deal` *(требует активации модуля встреч)* |
      | маркетинг, ЦА, сегменты (общее, lite-режим) | **Алекс** → `/marketer-revision` |
      | распакуй ЦА, найди сегменты, новый сегмент | **Алекс** → `/segments-discover` |
      | распакуй сегмент {slug}, БПСВ, семь вопросов | **Алекс** → `/segments-unpack` |
      | awareness, точка входа воронки, 4 уровня | **Алекс** → `/segments-awareness` |
      | разведай конкурентов, анализ рынка, голубой океан | **Алекс** → `/competitors-research` |
      | пятничная ревизия, обнови сегмент, стрим в досье | **Алекс** → `/revise-segment` |
      | распакуй продукт, распакуй оффер, value equation, grand slam | **Алекс** → `/unpack-product` |
      | добавить продукт, второй core, новый продукт в ladder | **Алекс** → `/product-add` |
      | распакуй воронку, по сегменту воронка, journey | **Алекс** → `/unpack-funnel` |
```

---

## Post-install message to client

```
✅ Алекс в команде.

Я Алекс. Маркетолог-Хормози. Моё кредо: Рынок > Оффер > Копия.
Без рынка нет оффера. Без оффера нет копии. В таком порядке.

Что я делаю:

1. **Полная распаковка проекта** — скажи «распакуй проект» или «поехали».
   Запустится мета-скилл, проведу через 4 фазы:
   • Фаза 1 — ЦА (40-60 мин): найду ТОП-3 сегмента, разведаю конкурентов,
     соберу досье на каждый сегмент с БПСВ + awareness
   • Фаза 2 — Оффер (60-90 мин): через 6 диалоговых протоколов соберу
     Grand Slam Offer — Value Equation, Named Mechanism, цена + risk reversal
   • Фаза 3 — Воронка (40-60 мин): per-segment маршрут, каналы, касания
   • Фаза 4 — Бренд: пока пропускаем (агент-Брендмейкер ещё не подключён)

   Между фазами — стоп, спрашиваю «продолжаем?». Без согласия не иду.

2. **Точечная работа** (если не нужна полная распаковка):
   • «распакуй ЦА» / «найди сегменты» — только фаза 1
   • «распакуй оффер» / «распакуй продукт» — только фаза 2
   • «распакуй воронку» — только фаза 3
   • «провёл диагностику с {имя}» — карточка клиента (если активирован модуль встреч)

3. **Модуль встреч** (опционально) — если есть продающие/диагностические
   созвоны: скажи «активируй встречи» — добавлю customers/, парсинг
   транскриптов в 7 артефактов параллельно, банк возражений.

Каждую пятницу 16:00 — пятничная ревизия: «обнови сегменты»,
переношу находки за неделю из stream → dossier → base.

Закон: я не перезаписываю твои файлы вывода (core-offer, positioning,
NORTH-STAR). Я предлагаю diff в hypotheses.md → Log. Ты принимаешь
командой /accept H{N} или отвергаешь. Голос остаётся за тобой.

Дальше — пойдём.
```
