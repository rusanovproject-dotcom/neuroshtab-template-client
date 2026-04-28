---
name: unpack-product
description: Оркестратор фазы 2 — распаковка продукта/оффера по методу Хормози. Ведёт владельца через 6 диалоговых протоколов (foundation → questionnaire-1 → questionnaire-2 → mechanism → package → finalize), собирает Grand Slam Offer с Value Equation, Named Mechanism, Risk Reversal. Stop+wait чек-поинты между протоколами. TRIGGERS — "распакуй продукт", "распакуй оффер", "value equation", "grand slam", "распакуй фазу 2", "/unpack-product"
parent_orchestrator: /unpack-project (фаза 2)
mode: interactive (stop+wait checkpoints)
---

# /unpack-product — Оркестратор фазы 2 «Продукт/Оффер»

📍 **Где это в системе:**
- **Уровень:** Stage 2 entry point (после Stage 1 закрытия на `/accept` NORTH-STAR)
- **Запускается из:** триггеров клиента («распакуй продукт», «распакуй оффер»), авто-перехода из `/unpack-project` после Phase 1
- **Pre-flight БЛОКИРУЕТ если:** Stage 1 не закрыта — нет `/accept` на NORTH-STAR, нет `segment-portrait.md` для ТОП-сегмента, нет `voice-of-customer.md` ≥5 цитат
- **Передаёт в:** `/product-build` (6 протоколов Хормози) → `/unpack-funnel` (Stage 3)

> Это **вторая фаза** пайплайна `/unpack-project`. На входе — распакованная ЦА (минимум 1 сегмент с `segment-portrait.md` и `segment-core.md`). На выходе — Grand Slam Offer по Хормози: Value Equation вытащена, Named Mechanism придуман, Risk Reversal зафиксирован, лестница LM → TW → Core → PM нарисована.
>
> Ты не пишешь оффер за владельца. Ты ведёшь его через **6 диалоговых протоколов** (или lite-режим), собираешь структурированные предложения, кладёшь diff в `hypotheses.md → Log`. Финальное слово — за владельцем через `/accept H{N}`.

---

## 1. Зачем

- Фаза 2 пайплайна `/unpack-project` — после `/segments-*` фазы 1
- Output: обновлённый `product/core-offer.md` (через diff), `product/ladder.md`, `product/proof.md` (опционально)
- Главный артефакт — **Grand Slam Offer**: Value Equation × 10, Named Mechanism, Risk Reversal, бонусы с рыночной альтернативой
- На выходе — материал для копирайтера и воронки фазы 3

---

## 2. Когда запускать

**Явно через триггер:**
- *«распакуй продукт»* / *«распакуй оффер»* / *«нужен value equation»* / *«собери grand slam»* / *«распакуй фазу 2»*
- `/unpack-product` напрямую

**Из мета-скилла `/unpack-project`:**
- Автоматически после завершения фазы 1 (после stop+wait `«продолжаем дальше?»`)

**НЕ запускать:**
- Если нет ни одного распакованного сегмента в `audience/segments/` — отправляй на `/segments-discover` сначала
- Для мелкой правки оффера (поменять цену, переписать гарантию) — это `/marketer-revision` lite

---

## 3. Pre-flight checks (БЛОКИРУЮЩИЕ — Stage 1 → Stage 2 gate)

⚠️ **Stage Lock — техническая стена.** `/unpack-product` = переход из Stage 1 (Audience) в Stage 2 (Product). Этот переход **необратим без явного `/accept`** на NORTH-STAR от владельца. Если переход начат до закрытия Stage 1 — продукт строится на недораспакованной ЦА, оффер слабый, починка дороже.

### 3.1 Stage 1 closure gate (блокирующий, до любого ответа клиенту)

```bash
# 1. Существует NORTH-STAR.md?
[ -f "projects/<main>-audience/audience/segments/NORTH-STAR.md" ]

# 2. NORTH-STAR не пустой?
[ -s "projects/<main>-audience/audience/segments/NORTH-STAR.md" ]

# 3. Есть /accept маркер в NORTH-STAR.md?
grep -E "/accept|✅ accepted|status: accepted" projects/<main>-audience/audience/segments/NORTH-STAR.md

# 4. Минимум 1 сегмент с заполненным dossier?
ls projects/<main>-audience/audience/segments/*/segment-portrait.md 2>/dev/null

# 5. voice-of-customer.md (или voice-of-customer.md если ещё не переименован) с ≥ 5 цитатами?
wc -l projects/<main>-audience/audience/voice-of-customer.md
```

**Решение по результату:**

| Условие | Действие |
|---------|----------|
| NORTH-STAR не существует | **STOP.** *«ЦА ещё не распакована. Без неё оффер строить наугад. Запускаю `/audience-stage` сначала?»* → `/audience-stage` |
| NORTH-STAR существует, но пустой / нет dossier | **STOP.** *«ЦА в процессе. Stage 1 не закрыта. Возвращаюсь в `/audience-resume` где остановились.»* → `/audience-resume` |
| dossier есть, но нет `/accept` маркера | **STOP.** *«ТОП-3 сегментов собраны, но не подтверждены тобой. Без `/accept` Stage 1 открыта. Покажу ТОП-3 — скажешь `/accept` или поправки.»* Покажи NORTH-STAR. Жди явного `/accept`. |
| voice-of-customer пуст / < 5 цитат | **WARN, не STOP.** *«VoC слабоват — Likelihood и Dream придётся вытаскивать диалогом, не из голоса ЦА. Качество оффера будет ниже. Идём так или сначала добираем VoC?»* |
| Все условия ✅ | Continue к Шагу 3.2 |

**Update agent-state.md:** при любом срабатывании gate — `last_preflight_check: <date> blocked|warned|passed`.

### 3.2 Контекст для распаковки (после прохождения gate)

| Что | Где смотрим | Если нет |
|---|---|---|
| Активный сегмент (один из ТОП-3) | `audience/segments/NORTH-STAR.md` | Если несколько — спроси какой первым (обычно hot) |
| `audience/voice-of-customer.md` | VoC цитаты | См. WARN выше |
| `brand/expert-bank.md` | Голос владельца | Если пусто — ок, будем собирать через диалог |
| `brand/positioning.md` | Unique Mechanism | Если есть — учитывай, не переизобретай |
| `product/_protocols/` | 6 файлов от project-template | Если нет — lite-режим (см. ниже) |

**Если несколько сегментов:** спроси владельца:

> *«У тебя в NORTH-STAR три сегмента: 🔥 hot, 🔸 warm, ❄️ cold. По какому распаковываем продукт? Обычно начинают с hot — там быстрее деньги. Но если у тебя core-продукт под warm — давай с него.»*

**Если `_protocols/` нет:**

> *«У тебя есть `product/_protocols/` от project-template? Без них продуктовая распаковка идёт в lite-режиме на ответах от тебя — это упрощённый диалог из 7-10 вопросов вместо 6 полных протоколов. Если есть project-template — давай склонируем `product/_protocols/` сюда и сделаем как надо. Если нет — поехали в lite.»*

---

## 4. Алгоритм

### Шаг 1 — Прочитать контекст

Без вопросов клиенту, тихо:

1. `audience/segments/NORTH-STAR.md` — определи активный сегмент (если несколько — спроси, см. выше)
2. `audience/segments/{slug}/segment-portrait.md` — БПСВ + 7 блоков интервью + awareness
3. `audience/segments/{slug}/segment-core.md` — сжатая база сегмента
4. `audience/voice-of-customer.md` — голос ЦА с цитатами
5. `brand/expert-bank.md` — голос владельца
6. `brand/positioning.md` — Unique Mechanism (если есть)
7. `customers/INDEX.md` — если активен модуль встреч, средняя actuality оффера
8. `hypotheses.md` — что валидировано/инвалидировано по тегам [PRODUCT] / [OFFER] / [PRICE]

### Шаг 2 — Проверить наличие протоколов

```
ls product/_protocols/
```

Должны быть: `01-foundation.md`, `02-questionnaire-1.md`, `03-questionnaire-2.md`, `04-mechanism.md`, `05-package.md`, `06-finalize.md`.

- Все 6 → запускаем `/product-build` в полном режиме
- Чего-то нет → спрашиваем владельца про project-template (см. Pre-flight)
- Lite — переход к шагу 4

### Шаг 3 — Запустить `/product-build`

Передай ему контекст:

```
to: /product-build
context:
  - active_segment: {slug}
  - dossier_path: audience/segments/{slug}/segment-portrait.md
  - voc_path: audience/voice-of-customer.md
  - expert_bank: brand/expert-bank.md
  - positioning: brand/positioning.md (если есть)
  - customers_actuality: {среднее значение из customers/} (если модуль активен)
mode: full (6 протоколов)
```

`/product-build` поведёт через 6 протоколов с stop+wait после каждого. Не вмешивайся внутрь — он сам.

### Шаг 4 — Lite-режим (если протоколов нет)

Если `_protocols/` нет и владелец не хочет их подключать — `/product-build` запустится в lite-режиме (упрощённый диалог из 7-10 вопросов). Тоже с stop+wait, но короче.

### Шаг 5 — После завершения `/product-build`

Когда `/product-build` вернулся с финалом:

1. Покажи владельцу сводку: что в `core-offer.md` обновится (через diff в Log), что в `ladder.md`
2. Спроси: *«нужен второй Core? Если да — запускаю `/product-add`»*. Если да — передай ему контекст.
3. Если второй Core не нужен — переход к шагу 6.

### Шаг 6 — Финал фазы 2

Покажи владельцу:
- Что обновилось (diff в `hypotheses.md → Log`)
- Что владельцу принять через `/accept H{N}`
- Сводку: Dream / Likelihood / Time / Effort + Named Mechanism + Risk Reversal + цена

Предложи переход к фазе 3:

> *«Оффер собран. Дальше логично — воронка под него. Погнали `/unpack-funnel`? Это фаза 3 — каналы, lead-magnet, welcome-цепочка под этот оффер. 40-60 минут.»*

Если владелец отвечает «да» — передай эстафету `/unpack-funnel`. Если «не сейчас» — фиксируй `progress: phase-2-done` и выходи.

---

## 5. Stop+wait — обязательно

| Точка | Что показываешь | Что ждёшь |
|---|---|---|
| После Pre-flight (если несколько сегментов) | NORTH-STAR + предложение работать с {slug} | Подтверждение или выбор другого |
| После `/product-build` | Сводка финала (Value Equation + Named Mechanism + цена) | «Нужен второй Core?» |
| Перед фазой 3 | Что готово в product/, что переходим к funnel | «Погнали /unpack-funnel?» |

Внутри `/product-build` свои 6 stop+wait — их не пропускать.

---

## 6. Output

| Файл | Что туда | Кто пишет |
|---|---|---|
| `product/core-offer.md` | Value Equation, Grand Slam Stack, Named Mechanism, цена, RR, бонусы | **Владелец** через `/accept H{N}`. Алекс предлагает diff. |
| `product/ladder.md` | LM → TW → Core → PM | Владелец через `/accept` |
| `product/proof.md` | Соцпруф, кейсы (опционально) | Владелец |
| `hypotheses.md → Log` | Все предложения diff с датой | Алекс пишет |
| `hypotheses.md → Active` | Гипотезы [PRODUCT] / [OFFER] / [PRICE] | Алекс пишет |
| `memory.md` | Decisions / Patterns / Context фазы 2 | Алекс пишет append |

**Закон голоса:** Алекс **НЕ перезаписывает** `core-offer.md`. Только diff в Log → `/accept` от владельца.

---

## 7. Связи

- ← **Фаза 1** (`/segments-*`) — даёт распакованные сегменты как материал
- ← **Мета-скилл** `/unpack-project` — оркестрирует фазу 2 как часть полного пайплайна
- → **`/product-build`** — внутренний скилл, ведёт через 6 протоколов
- → **`/product-add`** — если нужен второй Core
- → **Фаза 3** (`/unpack-funnel`) — следующий шаг пайплайна
- → **Copywriter / Designer** — получают материал из `core-offer.md` для текстов и визуала

---

## 8. Триггеры

Запускайся когда владелец говорит:

- *«распакуй продукт»* / *«распакуй оффер»*
- *«поехали по фазе 2»* / *«распакуй фазу 2»*
- *«собери Value Equation»* / *«собери Grand Slam»*
- *«нужен Named Mechanism»*
- *«хочу пересобрать оффер»*
- `/unpack-product` напрямую

**Из мета-скилла:** автоматически после фазы 1 stop+wait.

---

## 9. Anti-patterns (что НЕ делаешь)

- **Не пишешь оффер за владельца.** Только предлагаешь diff. Голос — его.
- **Не пропускаешь протоколы.** Если есть `_protocols/` — идёшь полным циклом, не «давай быстро без 02-questionnaire».
- **Не копируешь боли 1-к-1 из dossier в core-offer.** Это профиль ЦА, не RTW. Боли становятся РЕЗУЛЬТАТАМИ через переформулировку.
- **Не ставишь Likelihood 9/10 без 10+ кейсов.** Если кейсов мало — Likelihood ниже, и это нормально, на этом строим Risk Reversal.
- **Не выдумываешь бонусы из головы.** Каждый бонус — с рыночной альтернативой («обычно за это просят 50К»).
- **Не запускаешь фазу 3 без stop+wait.** Спрашиваешь владельца явно.

---

## 10. Память

**Перед задачей:**
- `grep` по `failures.md` на «оффер», «value equation», «grand slam», «named mechanism» — не повторяй ошибок
- `memory.md` секция Context — что знаешь об этом владельце (тон, ниша, цены)

**После задачи:** append в `memory.md`:
- **Decisions** — какой Named Mechanism придумали, какая цена выставлена, почему
- **Client Patterns** — на чём владелец срывается (например «не верит в Likelihood»)
- **Context** — что помнить для фазы 3 и для следующих сессий

Если что-то не сошлось / `/accept` не дали / владелец отверг — в `failures.md`: `YYYY-MM-DD → что предложил → почему отверг → правило`.

**Append-only.**
