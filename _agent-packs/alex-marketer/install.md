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
      | **Алекс Маркетолог** | Маркетолог-Хормози: распаковка ЦА, оффера (Хормози), воронки. Тест-процесс гипотез. Клиентская база (через `/marketer-enable-meetings`) | *«распакуй проект», «распакуй ЦА», «распакуй оффер», «найди сегменты», «разведай конкурентов»* |

  - file: office/agents/director/core.md
    section: "## Роутинг"
    add_rows: |
      | онбординг алекс, привет алекс, зашёл алекс, давай алекс, познакомимся, алекс представься | **Алекс** → `/alex-onboarding` (точка входа в работу — 6 тактов первого контакта) |
      | распакуй проект, новый проект, поехали, начнём пайплайн | **Системный мета-скилл** → `/unpack-project` |
      | провёл диагностику, был созвон, клиент оплатил, клиент отказался, вот транскрипт | **Алекс** → `/marketer-log-deal` *(требует активации модуля встреч)* |
      | распакуй ЦА, найди сегменты, кто наша ЦА, на кого работаем, новый сегмент | **Алекс** → `/audience-stage` *(если онбординг не пройден — авто-route на `/alex-onboarding`)* |
      | где мы по ЦА, что осталось по сегментам, проверь где мы, на каком шаге распаковки | **Алекс** → `/audience-status` |
      | продолжим с ЦА, вернёмся к сегментам, подними контекст по ЦА, откуда мы остановились | **Алекс** → `/audience-resume` |
      | awareness для {slug}, углубление сегмента, 4 уровня осознанности | **Алекс** → `/audience-awareness-lite` |
      | собери отчёт по ЦА, HTML по сегментам, артефакт ментору, упакуй ЦА визуально | **Алекс** → `/audience-deliverable` *(только после /accept Stage 1)* |
      | разведай конкурентов, анализ рынка, голубой океан, конкурентный анализ | **Алекс** → `/competitors-research` |
      | пятничная ревизия, обнови сегмент, перенеси stream в портрет, ревизия сегмента | **Алекс** → `/revise-segment` |
      | ЦА в общем (lite-режим, доводка после закрытия Stage 1) | **Алекс** → `/marketer-revision` *(только если Stage 1 закрыта на /accept)* |
      | распакуй продукт, распакуй оффер, value equation, grand slam | **Алекс** → `/unpack-product` |
      | добавить продукт, второй core, новый продукт в ladder | **Алекс** → `/product-add` |
      | распакуй воронку, по сегменту воронка, journey | **Алекс** → `/unpack-funnel` |
```

---

## Post-install message to client

```
✅ Алекс в команде.

Когда захочешь начать — напиши **«онбординг алекс»** или **«привет алекс»**.
Я открою твой офис, прочитаю что у тебя живое, и вернусь с диагнозом
и одним вопросом — про точку приложения усилий.
Никаких анкет на старт. Только живой разговор.

После онбординга мы вместе выбираем направление, и я веду тебя по
Internet-First пайплайну распаковки ЦА — 2-3 часа активного времени,
30-60 минут моей работы в интернете в фоне на каждый сегмент.

—

Что я делаю (если интересно прочитать на ходу):

1. **Полная распаковка проекта** — скажи «распакуй проект» или «поехали».
   Запустится мета-скилл, проведу через 4 фазы:
   • Фаза 1 — ЦА (Internet-First, 2-3 часа активного диалога):
     - Phase A — quick-capture: 10-15 мин минимальный контекст
     - Phase B — internet-research: 30-90 мин — ухожу в интернет с 5
       параллельными субагентами (YouTube Data API, Telegram через Pyrogram,
       SerpAPI, Bukvarix, реальные форумы) — собираю voice-of-segment
       уровня 30-50 цитат с источниками
     - Phase C — validation: 15-25 мин клиент валидирует через мультиселекты
     - Phase D — awareness-lite: углубление hot-сегмента до Hero-формулы
   • Фаза 2 — Оффер (60-90 мин): через 6 диалоговых протоколов соберу
     Grand Slam Offer — Value Equation, Named Mechanism, цена + risk reversal
   • Фаза 3 — Воронка (40-60 мин): per-segment маршрут, каналы, касания
   • Фаза 4 — Бренд: пока пропускаем (агент-Брендмейкер ещё не подключён)

   Между фазами — стоп, спрашиваю «продолжаем?». Без согласия не иду.

2. **Точечная работа** (если не нужна полная распаковка):
   • «распакуй ЦА» / «найди сегменты» / «кто наш клиент» — только Stage 1 через `/audience-stage`
   • «где мы по ЦА» / «что осталось» — статус через `/audience-status`
   • «продолжим с ЦА» / «вернёмся к сегментам» — после `/clear` через `/audience-resume`
   • «awareness для {slug}» — углубление одного сегмента через `/audience-awareness-lite`
   • «распакуй оффер» / «распакуй продукт» — только фаза 2
   • «распакуй воронку» — только фаза 3
   • «провёл диагностику с {имя}» — карточка клиента (если активирован модуль встреч)

3. **Модуль встреч** (опционально) — если есть продающие/диагностические
   созвоны: скажи «активируй встречи» — добавлю customers/, парсинг
   транскриптов в 7 артефактов параллельно, банк возражений.

Каждую пятницу 16:00 — пятничная ревизия: «обнови сегменты»,
переношу находки за неделю из segment-observations → segment-portrait → segment-core.

Закон: я не перезаписываю твои файлы вывода (core-offer, positioning,
NORTH-STAR). Я предлагаю diff в hypotheses.md → Log. Ты принимаешь
командой /accept H{N} или отвергаешь. Голос остаётся за тобой.

Дальше — пойдём.
```
