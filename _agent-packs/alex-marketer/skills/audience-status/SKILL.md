---
name: audience-status
description: |
  Возвращает текущий статус Stage 1 (Audience) — где мы по плану vs реальности.
  Читает agent-state.md + реальные артефакты в <main>-audience/ + progress.md внутри.
  Если клиент чувствует «мы съехали / не понимаю где мы» — этот скилл сверяет
  и предлагает возврат.

  КОГДА ИСПОЛЬЗОВАТЬ:
  - Клиент спрашивает «где мы?» / «что осталось?» / «куда дальше?»
  - Алекс сам сомневается — Stage 1 закрыта или нет?
  - Перед запуском lite-режима `/marketer-revision` — обязательная проверка
  - Клиент сказал «ты сбился / каша / вернись к ЦА» (см. core.md Trigger words)

  НЕ ИСПОЛЬЗОВАТЬ:
  - Если работа НЕ про ЦА — это `/triage` или Director
  - Для глубокой ревизии содержимого артефактов — это `/marketer-checkin`

triggers:
  - где мы по ЦА
  - audience status
  - что осталось по сегментам
  - на каком шаге распаковки
  - проверь где мы
  - что сделано по ЦА
---

# `/audience-status` — Где мы по Stage 1

Быстрый чек статуса распаковки ЦА. Не правит файлы, только читает и сводит.

---

📍 **Где это в системе:**
- **Уровень:** Helper (читающий, не пишущий)
- **Запускается из:** триггеров клиента («где мы?», «что осталось?»), авто-вызова `/audience-check`, после Trigger words срыва
- **Передаёт в:** `/audience-resume` (если решено возвращаться) или `/audience-stage` (если Stage 1 не запускалась)
- **Восстановление:** этот скилл сам и есть точка восстановления — он не падает, только читает

---

## Шаг 0 — Migration check (старые имена файлов → новые)

**Перед чтением артефактов** проверь не на старых ли именах работает проект (с версии до v2.0). Если да — автоматически переименуй (содержимое не трогай) и сообщи клиенту в одну строку.

```bash
PROJECT_ROOT="projects/<main>-audience"
RENAMED=0

# audience/voc.md → audience/voice-of-customer.md
if [ -f "$PROJECT_ROOT/audience/voc.md" ] && [ ! -f "$PROJECT_ROOT/audience/voice-of-customer.md" ]; then
  mv "$PROJECT_ROOT/audience/voc.md" "$PROJECT_ROOT/audience/voice-of-customer.md"
  RENAMED=1
fi

# progress.md (в корне или в _state/) → _state/pipeline-progress.md
mkdir -p "$PROJECT_ROOT/_state"
for src in "$PROJECT_ROOT/progress.md" "$PROJECT_ROOT/_state/progress.md"; do
  if [ -f "$src" ] && [ ! -f "$PROJECT_ROOT/_state/pipeline-progress.md" ]; then
    mv "$src" "$PROJECT_ROOT/_state/pipeline-progress.md"
    RENAMED=1
  fi
done

# audience/segments/MAP.md → audience/segments/segments-map.md
if [ -f "$PROJECT_ROOT/audience/segments/MAP.md" ] && [ ! -f "$PROJECT_ROOT/audience/segments/segments-map.md" ]; then
  mv "$PROJECT_ROOT/audience/segments/MAP.md" "$PROJECT_ROOT/audience/segments/segments-map.md"
  RENAMED=1
fi

# Для каждого {slug}/ — dossier→segment-portrait, base→segment-core, stream→segment-observations
for slug_dir in "$PROJECT_ROOT/audience/segments"/*/; do
  [ -d "$slug_dir" ] || continue
  [ "$(basename "$slug_dir")" = "_archive" ] && continue
  if [ -f "${slug_dir}dossier.md" ] && [ ! -f "${slug_dir}segment-portrait.md" ]; then
    mv "${slug_dir}dossier.md" "${slug_dir}segment-portrait.md"; RENAMED=1
  fi
  if [ -f "${slug_dir}base.md" ] && [ ! -f "${slug_dir}segment-core.md" ]; then
    mv "${slug_dir}base.md" "${slug_dir}segment-core.md"; RENAMED=1
  fi
  if [ -f "${slug_dir}stream.md" ] && [ ! -f "${slug_dir}segment-observations.md" ]; then
    mv "${slug_dir}stream.md" "${slug_dir}segment-observations.md"; RENAMED=1
  fi
done

# office/agents/alex-marketer/state.md → agent-state.md
if [ -f "office/agents/alex-marketer/state.md" ] && [ ! -f "office/agents/alex-marketer/agent-state.md" ]; then
  mv "office/agents/alex-marketer/state.md" "office/agents/alex-marketer/agent-state.md"
  RENAMED=1
fi
```

**Если хоть одно переименование произошло (`RENAMED=1`)** — сообщи клиенту в одну строку живым языком:

> *«Заметил у тебя старые имена файлов с прошлой версии. Перевёл на читаемый английский — содержимое не тронул, только название.»*

**Если ничего не переименовалось** — продолжай молча.

---

## Шаг 1 — Прочитать source of truth

В порядке:

1. `office/agents/alex-marketer/agent-state.md` — глобальный agent-state (active_project, active_skill, active_stage, active_step, interrupted)
2. Если `agent-state.md` указывает на проект → читай `projects/<main>-audience/_state/pipeline-progress.md` (детальный лог Stage 1)
3. Реальные артефакты в `projects/<main>-audience/audience/segments/`:
   - `NORTH-STAR.md` — пустой / частичный / закрыт на /accept?
   - `segments-map.md` — есть scoring? сколько гипотез?
   - `{slug}/segment-portrait.md` × 3 — заполнены секции 0-6?
   - `{slug}/segment-core.md` × 3 — есть lingvo?
   - `voice-of-customer.md` — сколько цитат?
4. `intel/competitors-{slug}/INDEX.md` — был ли конкурентный анализ?
5. `inbox/_product-hints.md` — есть ли неразобранные продуктовые откровения для Stage 2?

---

## Шаг 2 — Свести в матрицу состояния

| Артефакт | Должно быть | Фактически | Статус |
|----------|-------------|------------|--------|
| competitors.md (срез БПСВ) | заполнен по топ-3 конкурентам | ... | ✅ / ⏳ / ❌ |
| NORTH-STAR.md (ТОП-3) | 3 сегмента, /accept | ... | ✅ / ⏳ / ❌ |
| dossier × 3 | БПСВ + 7 блоков | ... | ✅ / ⏳ / ❌ |
| base × 3 + lingvo | 4 правила lingvo | ... | ✅ / ⏳ / ❌ |
| voice-of-customer.md | ≥ 5 дословных цитат | ... | ✅ / ⏳ / ❌ |

**Stage 1 закрыта = все строки ✅ + явный `/accept` владельца на NORTH-STAR.**

---

## Шаг 3 — Ответить клиенту

**Формат ответа (живым языком, без жаргона):**

> *«Мы на [текущий Шаг] из [скилл]. Сделано: [что есть]. Осталось: [что нет]. До закрытия Stage 1: [количество артефактов].»*

**Если Алекс съехал в Stage 2-4 (по agent-state.md или по диалогу):**

> *«Я заметил что мы ушли в [продукт / цены / timelines] — это Stage 2. Stage 1 ещё открыта: нет [артефакт A, B]. Возвращаюсь в `/audience-stage --resume` где остановились. Согласен?»*

**Если Stage 1 закрыта на /accept:**

> *«Stage 1 закрыта. Можем переходить к Stage 2 (продукт) — там `/unpack-product`. Готов?»*

**Если артефактов нет (Stage 1 не запускалась):**

> *«Stage 1 ещё не начата. Нужно запустить полный путь `/audience-stage` — он создаст папку и проведёт через 8 этапов. Запускаю?»*

---

## Acceptance criteria

- [ ] Шаг 0 — Migration check выполнен (если были старые имена — переименованы и клиенту сообщено одной строкой)
- [ ] Прочитаны все 5 источников (agent-state.md + pipeline-progress.md + артефакты + competitors + product-hints)
- [ ] Матрица состояния заполнена с правильными статусами
- [ ] Ответ клиенту — без жаргона, с конкретным следующим шагом
- [ ] Если был срыв — предложение возврата явно сформулировано

---

## Связки

- ← Триггер вручную: «где мы», «что осталось», «проверь где мы»
- ← Авто-вызов из `/audience-check` каждые 5 ходов
- ← Авто-вызов из core.md Trigger words (после «ты сбился / каша»)
- → Если решено возвращаться → `/audience-resume`
