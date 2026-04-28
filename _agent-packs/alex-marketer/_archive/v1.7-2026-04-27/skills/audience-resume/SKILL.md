---
name: audience-resume
description: |
  Восстанавливает контекст Stage 1 после `/clear` или новой сессии.
  Читает state.md + progress.md + артефакты, продолжает с того места
  где остановились — без переспрашивания того что уже отвечено.

  КОГДА ИСПОЛЬЗОВАТЬ:
  - Новая сессия после `/clear` — клиент пишет «продолжим»
  - state.md показывает `interrupted: true` — нужно поднять контекст
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

# `/audience-resume` — Восстановление контекста Stage 1

Поднять прерванную работу без потери прогресса.

---

## Шаг 1 — Прочитать state.md

`office/agents/alex-marketer/state.md`:

- `active_client`, `active_project` — куда возвращаемся
- `active_skill` — какой скилл был активен (`/audience-stage` / `/segments-unpack` / `/segments-awareness`)
- `active_stage`, `active_step` — где конкретно остановились
- `active_segment` — если был активный сегмент углубления
- `last_checkpoint` — когда был последний апдейт
- `interrupted`, `interrupted_reason`, `resume_hint` — что произошло, как продолжить

**Если `state.md` пустой или `active_skill: null`:**
→ Stage 1 не была запущена в этой сессии. Запусти `/audience-status` чтобы понять реальное состояние артефактов, потом — `/audience-stage` если нужно начинать с нуля или `/audience-stage --resume` если папка уже есть.

---

## Шаг 2 — Прочитать детальный progress

Если `active_project` указан:

1. `projects/<main>-audience/_state/progress.md` — детальный лог Stage 1 (какая сессия 1A / 1B-1 / итд)
2. `projects/<main>-audience/audience/segments/NORTH-STAR.md` — есть ли ТОП-3
3. `projects/<main>-audience/audience/segments/{active_segment}/dossier.md` — какие секции заполнены
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

## Шаг 5 — Update state.md

После запуска нужного скилла:

```
interrupted: false
interrupted_reason: null
resume_hint: null
last_checkpoint: <now>
```

---

## Acceptance criteria

- [ ] Прочитан state.md и progress.md
- [ ] Сводка клиенту краткая, конкретная, без переспрашивания
- [ ] Запущен правильный скилл с правильным шагом
- [ ] state.md обновлён (interrupted сброшен)

---

## Связки

- ← Новая сессия после `/clear`
- ← Auto-call из `/audience-check` при detected drift
- ← Триггер вручную: «продолжим с ЦА»
- → `/audience-stage` / `/segments-unpack` / `/segments-awareness` (с флагом --resume)
