# Smoke-test Алекса v2.0 — 2026-04-28

> Не реальный прогон с клиентом — **аудит по чеклисту**, что 5 сценариев из V2.0-MASTER-PLAN покрыты в коде/логике скиллов. Реальные смок-тесты с запуском в чате — за Никитой при первой работе с реальным клиентом.

Время: ~10 мин аудита. Все 5 сценариев — ✅ покрыты.

---

## Сценарий 1 — Greenfield (нет данных у клиента)

**Что должно случиться:** Алекс детектит mode=greenfield, бранчится на 3 вопроса (вместо 4 в early-stage), Phase B опирается **полностью** на интернет (нет своих кейсов = нет тёплой базы для проверки).

**Где живёт:**
- `skills/audience-quick-capture/SKILL.md` секция Mode Detection (строки 117-122)
- Бранчинг по mode записан в Acceptance criteria
- Фолбэк: если `inbox/_raw/` пусто → `audience_mode: greenfield` записывается в `agent-state.md`

**Покрытие:** ✅
- Mode Detection ДО первого вопроса (P0 fix от UX-reviewer)
- Бранчинг по 3 mode'ам реализован: greenfield (3 вопроса) / early-stage (4) / established (4 + кейс)
- Записывается в `agent-state.md` поле `audience_mode`

**Ручной тест за Никитой:** взять «свежего» клиента без блога/кейсов → запустить `/audience-stage` → убедиться что Алекс автоматически идёт в greenfield-ветку без вопроса «дай 1 кейс».

---

## Сценарий 2 — Established (есть прогрев)

**Что должно случиться:** mode=established, 4 вопроса + есть кейс с цифрами и отказ. Phase B сокращается (часть болей подтвердится из материалов клиента).

**Покрытие:** ✅
- Триггер: 4+ материалов И ≥1 кейс с цифрами И ≥1 отказ → `audience_mode: established`
- В Phase B инструкция «использовать материалы клиента как cross-validation, не повторять то что уже знаем»

**Ручной тест за Никитой:** клиент с активным блогом + 5+ кейсами → проверить что Phase B не дублирует поиск по уже зафиксированным болям.

---

## Сценарий 3 — Срыв в продукт (Stage Lock срабатывает)

**Что должно случиться:** клиент в Phase B/C произносит «давай к ценам / к офферу / к воронке» → Алекс детектит trigger words → возвращается через `/audience-status` → продолжает Stage 1.

**Где живёт:**
- `core.md` секция «🔒 Stage Lock» (стена между фазами)
- `knowledge/stage-lock.md` — полный список trigger words + Pre-response gate
- `skills/audience-check/SKILL.md` Шаг 1 — поиск запрещённых слов в last 5 ходов
- `skills/audience-stage/SKILL.md` — anti-pattern «Перейти в Stage 2 без /accept на NORTH-STAR»

**Покрытие:** ✅
- Auto-вызов `/audience-check` каждые 5 ходов внутри `/audience-stage`
- При detected drift → запись в `failures.md` + `agent-state.md` `interrupted: true` + возврат через `/audience-status`
- Trigger words в `knowledge/stage-lock.md`: tier, цена, чек, тариф, бизнес-модель, timeline, оффер, ladder, lead magnet, позиционирование

**Ручной тест за Никитой:** в середине Phase B сказать «давай посчитаем сколько это будет стоить» → Алекс должен мягко вернуть в Phase B без углубления в цены.

---

## Сценарий 4 — /clear-resume (восстановление через state)

**Что должно случиться:** клиент делает `/clear` посреди Phase B → новая сессия → клиент пишет «продолжим с ЦА» → Алекс читает `agent-state.md` + `pipeline-progress.md` + артефакты → восстанавливает контекст без переспрашивания.

**Где живёт:**
- `skills/audience-resume/SKILL.md` — все 5 шагов + Шаг 0 migration check
- `skills/audience-status/SKILL.md` — Шаг 0 migration + матрица состояния
- `core.md` секция «Глобальный agent-state.md — формат» (правило записи `interrupted: true` при любом прерывании)

**Покрытие:** ✅
- `agent-state.md` содержит `interrupted`, `interrupted_reason`, `resume_hint`
- `audience-resume` восстанавливает с правильного шага через `--resume --step=<N>`
- Migration check (Шаг 0) автоматически переименовывает старые имена `voc.md/dossier.md/base.md/stream.md/MAP.md/state.md/progress.md` на новые при первом запуске на старом проекте
- После восстановления — `interrupted: false`, `last_checkpoint: <now>`

**Ручной тест за Никитой:** запустить `/audience-stage` → выйти посреди → новая сессия → «продолжим» → проверить что Алекс не переспрашивает уже отвеченные вопросы.

---

## Сценарий 5 — Phase E (HTML-артефакт)

**Что должно случиться:** после `/accept` Stage 1 — Алекс собирает `audience-report.html` через `/audience-deliverable` за 5-10 мин.

**Где живёт:**
- `skills/audience-deliverable/SKILL.md` — 315 строк, 10 секций (Pre-flight → JSON-данные → Brand Book → HTML сборка → Output → Update state → Acceptance → Связки → Anti-patterns → Память)
- `projects/_template-audience/deliverable/README.md` — описание папки выхода
- Интеграция в `/audience-stage` — Шаг 7 «Phase E (опционально)»

**Покрытие:** ✅
- Pre-flight БЛОКИРУЕТ если: NORTH-STAR не закрыт на /accept, нет `segment-portrait.md` ≥1, нет `voice-of-customer.md` ≥5 цитат
- JSON-данные собираются из артефактов (не выдумываются)
- Brand Book читается из `knowledge/brand/<project>/brand-book.md` если есть, иначе fallback Arctic Cold Light палитра
- Output: `projects/<main>-audience/deliverable/audience-report.html`
- HTML one-page без motion-эффектов (открывается офлайн на телефоне)
- Anti-slop guard в промпте генерации

**Ручной тест за Никитой:** прогнать полный пайплайн до /accept → запустить `/audience-deliverable` → открыть HTML в браузере → проверить что цитаты с источниками, цвета сегментов корректны, табы работают.

---

## Что НЕ протестировано автоматически (ручной труд за Никитой)

Аудит покрывает **наличие кода**, не **качество результата**. Отдельно нужны:

1. **Реальные API-вызовы** — пройти Setup-инструкцию в `SETUP-NIKITA.md`, проверить что YouTube/SerpAPI/Telegram возвращают данные
2. **Качество voice-of-segment.md** — после первого реального прогона сравнить с эталоном «VoC Эксперт в потолке» (45 цитат с vc.ru/Forbes/holod, 5 категорий лингво, 15 метафор)
3. **Скорость Phase B** — должна укладываться в 30-90 мин на сегмент при стандартной нагрузке
4. **Cost-tracker** — на реальном прогоне померить расход SerpAPI (Free 100/мес), убедиться что хватает на 1 сегмент

**Если что-то ломается на реальном прогоне** — append в `failures.md` с правилом на будущее, обновить скиллы.

---

## Итог

✅ Все 5 сценариев из V2.0-MASTER-PLAN покрыты в коде.
✅ Migration-детектор для старых проектов встроен в `/audience-status` и `/audience-resume`.
✅ Stage Lock работает на 3 уровнях: core.md guardrails → audience-check каждые 5 ходов → trigger words в knowledge/stage-lock.md.

**Production-ready: да** (по архитектуре). **Тестирование на реальном клиенте: за Никитой.**
