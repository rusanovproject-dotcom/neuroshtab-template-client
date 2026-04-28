---
name: audience-resume
description: |
  Восстанавливает контекст Stage 1 после `/clear` или новой сессии.
  Читает agent-state.md + progress.md + артефакты, продолжает с того места
  где остановились — без переспрашивания того что уже отвечено.

  КОГДА ИСПОЛЬЗОВАТЬ:
  - Новая сессия после `/clear` — клиент пишет «продолжим»
  - agent-state.md показывает `interrupted: true` — нужно поднять контекст
  - После срыва (auto-detected via `/audience-check`) — возврат в правильный Шаг
  - Клиент сказал «давай вернёмся к ЦА» в новой сессии

  НЕ ИСПОЛЬЗОВАТЬ:
  - Если Stage 1 ещё не запускалась — это `/audience-stage` (полный путь)
  - Если Stage 1 закрыта на /accept — переход к Stage 2 через `/unpack-product`

triggers:
  - audience resume
  - продолжаем с ЦА
  - вернёмся к сегментам
  - подними контекст по ЦА
  - откуда мы остановились
---
---

🎙 **ГОЛОС:** прочитай `knowledge/voice.md` ПЕРЕД любой репликой клиенту. Слова «Шаг», «Pre-flight», «AskUserQuestion», «Phase», «Stage Lock», «гейт», «trigger», «mode» — **внутренняя структура для тебя**, в речи клиенту **НЕ произносить**. Стиль = живой партнёр-маркетолог с насмотренностью, не методолог из учебника. Если хоть в одной реплике появилось «Шаг 1 / Phase A / Pre-flight / 4 вопроса по одному» — это робот. Перепиши.


# `/audience-resume` — Восстановление контекста Stage 1

Поднять прерванную работу без потери прогресса.

---

📍 **Где это в системе:**
- **Уровень:** Helper (поднятие контекста, не сама работа)
- **Запускается из:** новой сессии после `/clear`, авто-вызова из `/audience-check` при detected drift, фразы клиента «продолжим с ЦА»
- **Передаёт в:** `/audience-stage` / `/audience-quick-capture` / `/audience-validation` / `/audience-awareness-lite` — с флагом `--resume` и нужным шагом
- **Если agent-state.md пустой:** запусти `/audience-status` → он покажет реальное состояние артефактов

---

## Шаг 0 — Migration check (старые имена файлов → новые)

**Перед чтением agent-state.md** проверь не на старых ли именах работает проект (с версии до v2.0). Если да — автоматически переименуй (содержимое не трогай) и сообщи клиенту в одну строку.

```bash
PROJECT_ROOT="projects/<main>-audience"
RENAMED=0

# audience/voc.md → audience/voice-of-customer.md
if [ -f "$PROJECT_ROOT/audience/voc.md" ] && [ ! -f "$PROJECT_ROOT/audience/voice-of-customer.md" ]; then
  mv "$PROJECT_ROOT/audience/voc.md" "$PROJECT_ROOT/audience/voice-of-customer.md"; RENAMED=1
fi

# progress.md (в корне или в _state/) → _state/pipeline-progress.md
mkdir -p "$PROJECT_ROOT/_state"
for src in "$PROJECT_ROOT/progress.md" "$PROJECT_ROOT/_state/progress.md"; do
  if [ -f "$src" ] && [ ! -f "$PROJECT_ROOT/_state/pipeline-progress.md" ]; then
    mv "$src" "$PROJECT_ROOT/_state/pipeline-progress.md"; RENAMED=1
  fi
done

# audience/segments/MAP.md → audience/segments/segments-map.md
if [ -f "$PROJECT_ROOT/audience/segments/MAP.md" ] && [ ! -f "$PROJECT_ROOT/audience/segments/segments-map.md" ]; then
  mv "$PROJECT_ROOT/audience/segments/MAP.md" "$PROJECT_ROOT/audience/segments/segments-map.md"; RENAMED=1
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
  mv "office/agents/alex-marketer/state.md" "office/agents/alex-marketer/agent-state.md"; RENAMED=1
fi
```

**Если хоть одно переименование произошло (`RENAMED=1`)** — сообщи клиенту в одну строку:

> *«Заметил у тебя старые имена файлов с прошлой версии. Перевёл на читаемый английский — содержимое не тронул, только название.»*

**Если ничего не переименовалось** — продолжай молча.

---

## Шаг 1 — Прочитать agent-state.md

`office/agents/alex-marketer/agent-state.md`:

- `active_client`, `active_project` — куда возвращаемся
- `active_skill` — какой скилл был активен (`/audience-stage` / `/segments-unpack` / `/segments-awareness`)
- `active_stage`, `active_step` — где конкретно остановились
- `active_segment` — если был активный сегмент углубления
- `last_checkpoint` — когда был последний апдейт
- `interrupted`, `interrupted_reason`, `resume_hint` — что произошло, как продолжить

**Если `agent-state.md` пустой или `active_skill: null`:**
→ Stage 1 не была запущена в этой сессии. Запусти `/audience-status` чтобы понять реальное состояние артефактов, потом — `/audience-stage` если нужно начинать с нуля или `/audience-stage --resume` если папка уже есть.

---

## Шаг 2 — Прочитать детальный progress

Если `active_project` указан:

1. `projects/<main>-audience/_state/pipeline-progress.md` — детальный лог Stage 1 (какая сессия 1A / 1B-1 / итд)
2. `projects/<main>-audience/audience/segments/NORTH-STAR.md` — есть ли ТОП-3
3. `projects/<main>-audience/audience/segments/{active_segment}/segment-portrait.md` — какие секции заполнены
4. `intel/competitors-{slug}/INDEX.md` — был ли конкурентный анализ

---

## Шаг 3 — Сообщить клиенту короткую сводку

**Формат (живым языком, без жаргона):**

> *«Поднял контекст. В прошлый раз мы остановились на [текущий Шаг] для проекта [название]. Сделано: [что есть — 1-2 строки]. Следующий шаг: [конкретное действие]. Продолжаем?»*

**Если был interrupted с причиной:**

> *«В прошлый раз я съехал в [продукт / цены], ты остановил. Возвращаюсь в правильную точку — [текущий Шаг]. Делаем [конкретное действие]. Поехали?»*

**Если active_segment был активен:**

> *«Мы углубляли сегмент [имя]. Дошли до [Шаг], секция [N]. Продолжаем оттуда?»*

---

## Шаг 4 — Запустить нужный скилл

После «да» от клиента (или если очевидно — без переспрашивания):

| Состояние | Запускать |
|-----------|-----------|
| `active_skill: /audience-stage`, в середине Шага N | `/audience-stage --resume --step=<N>` |
| `active_skill: /segments-unpack`, активный сегмент | `/segments-unpack {slug} --resume` |
| `active_skill: /segments-awareness` | `/segments-awareness {slug} --resume` |
| `interrupted: true, reason: scope-drift` | возврат в `active_step` без нового вопроса — продолжай прямо со следующего ответа |

---

## Шаг 5 — Update agent-state.md

После запуска нужного скилла:

```
interrupted: false
interrupted_reason: null
resume_hint: null
last_checkpoint: <now>
```

---

## Acceptance criteria

- [ ] Шаг 0 — Migration check выполнен (если были старые имена — переименованы и клиенту сообщено одной строкой)
- [ ] Прочитан agent-state.md и pipeline-progress.md
- [ ] Сводка клиенту краткая, конкретная, без переспрашивания
- [ ] Запущен правильный скилл с правильным шагом
- [ ] agent-state.md обновлён (interrupted сброшен)

---

## Связки

- ← Новая сессия после `/clear`
- ← Auto-call из `/audience-check` при detected drift
- ← Триггер вручную: «продолжим с ЦА»
- → `/audience-stage` / `/segments-unpack` / `/segments-awareness` (с флагом --resume)
