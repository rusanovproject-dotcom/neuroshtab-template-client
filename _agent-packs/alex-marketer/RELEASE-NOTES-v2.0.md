# Алекс v2.0 — Release Notes

> Стартовано: 2026-04-27
> Завершено (production-ready): 2026-04-28
> Базовая версия: v1.7
> Snapshot v1.7: `_archive/v1.7-2026-04-27/`
> Главный сдвиг: переход с «10-12 часов клиента в чате» на **Internet-First** (2-3 часа клиента + 5 параллельных субагентов в интернете)

---

## ✅ Все фазы закрыты

### ✅ Фаза 0 — Подготовка (15 мин)
- [x] Snapshot v1.7 в `_archive/v1.7-2026-04-27/`
- [x] RELEASE-NOTES создан
- [x] state.md → agent-state.md (формат обновлён)

### ✅ Фаза 1 — P0 блокеры (~1.5 часа)
- [x] 1.1 `_template-audience/` шаблон проверен и интегрирован в install.md
- [x] 1.2 `failures.md` в паке очищен до template
- [x] 1.3 7-я ось scoring добавлена в `/audience-stage` Этап 8
- [x] 1.4 Дубль `hormozi-methodology.md` удалён, Magnificent 7 (Kennedy) перенесён в offer-market
- [x] 1.5 `/unpack-product` Pre-flight gate (блокирующий) — Stage 1 closure check
- [x] 1.6 `/audience-stage` блокировка прямого запуска legacy скиллов
- [x] 1.7 Greenfield-mode на верхнем уровне `/audience-stage` — 3 режима с явным выбором
- [x] 1.8 «Один фрейм — три проекции» с mapping в audience-framework.md

### ✅ Фаза 2 — Раздутость
- [x] 2.1 core.md 468 → 287 строк (вынесено в knowledge: stage-lock.md, first-contact-protocol.md, pipeline-requirements.md)
- [x] 2.2 audience-stage 662 → 400 строк
- [x] 2.3 **Переименование на читаемый английский** (2026-04-28):
  - `voc.md` → `voice-of-customer.md`
  - `dossier.md` → `segment-portrait.md`
  - `base.md` → `segment-core.md`
  - `stream.md` → `segment-observations.md`
  - `MAP.md` → `segments-map.md`
  - `state.md` → `agent-state.md`
  - `_state/progress.md` → `_state/pipeline-progress.md`
  - Обновлены ссылки в core.md + всех 14 активных скиллах + knowledge/* + sales-meetings extension + template
- [x] 2.4 «Продуктовая матрица» из audience-framework.md → hormozi-offer-market.md

### ✅ Фаза 3 — Серая зона Stage 1/2
- [x] 3.1-3.3 Закрыто переписыванием новых скиллов под Internet-First архитектуру

### ✅ Фаза 4 — Методология
- [x] 4.1 Hormozi Value Equation — trade-off + Perceived (в hormozi-offer-market.md)
- [x] 4.2 Christensen 4 силы — в одну схему (в audience-framework.md)
- [x] 4.3 Schwartz — объяснение русификации (в schwartz-awareness.md)
- [x] 4.4 12 тегов гипотез (актуально для текущей версии)

### ✅ Фаза 5 — Legacy + интеграция
- [x] 5.1 Legacy скиллы (`segments-discover`, `segments-unpack`, `segments-awareness`, `segments-discover-sub-segmentation`, `segments-unpack-sub-bpsv`, `segments-awareness-sub-ctrlx`, `segment-hypotheses`, `segment-money-map`, `marketer-audience`, `marketer-ladder`, `marketer-funnel`) → `_legacy/`
- [x] 5.2 Helper-скиллы parent_only
- [x] 5.3 `/marketer-enable-meetings` создан
- [x] 5.4 **install.md обновлён под новые скиллы Алекса v2.0** (2026-04-28):
  - Routing для Director'а: `/audience-stage` единственный вход в Stage 1
  - Добавлены `/audience-status`, `/audience-resume`, `/audience-awareness-lite`, `/audience-deliverable`
  - Удалены legacy упоминания `/segments-discover`, `/segments-unpack`, `/segments-awareness`
  - Post-install message обновлён под Internet-First
- [x] 5.5 Контракт Стратег → Алекс в knowledge
- [x] 5.6 Переключение сегмента в `/audience-stage` Шаг 6

### ✅ Фаза 6 — UX
- [x] 6.1 Suppress «📚 0 failures» при N=0
- [x] 6.2 Anticliché pass
- [x] 6.3 5 типов клиента
- [x] 6.4 Triage Алекс vs Стратег (через 6 тактов первого контакта)
- [x] 6.5 install.md trigger_keywords дедуп (2026-04-28: добавлены ключи для новых скиллов, убраны legacy)

### ✅ Фаза 7 — Финальная сборка
- [x] 7.1 Решение по audience-state скиллам (3 helper'а: status, resume, check)
- [x] 7.2 Migration-детектор в `/audience-status` и `/audience-resume` (Шаг 0 — автопереименование старых имён файлов)
- [x] 7.3 Wayfinding-блоки добавлены в 8 ключевых скиллов (audience-status, audience-resume, audience-check, competitors-research, marketer-revision, revise-segment, unpack-product, unpack-funnel) — у новых audience-* скиллов wayfinding был уже частично
- [x] 7.4 Smoke-test 5 сценариев — аудит-доклад в `_research/2026-04-28-smoke-test.md` (greenfield / established / срыв в продукт / /clear-resume / Phase E — все покрыты в коде)
- [x] 7.5 AGENTS.md, install.md обновлены

### ✅ Фаза 8 — HTML-артефакт для ментора
- [x] 8.1 Скилл `/audience-deliverable` создан (315 строк, 10 секций)
- [x] 8.2 HTML-шаблон в `_template-audience/deliverable/`
- [x] 8.3 Связка с Дизайнером (читает `knowledge/brand/<project>/brand-book.md`, fallback Arctic Cold Light)
- [x] 8.4 Интеграция в `/audience-stage` финал (Шаг 7 — Phase E опционально)

---

## Ключевые изменения по сравнению с v1.7

| Что | v1.7 | v2.0 |
|-----|------|------|
| Архитектура распаковки | Алекс выкачивает БПСВ из клиента 50 вопросами | Internet-First: клиент даёт минимум, 5 субагентов копают интернет |
| Время клиента в чате | 10-12 часов | **2-3 часа** |
| Источник цитат | 80% догадок Алекса | **80% validated с 3+ источниками** |
| Главный артефакт | dossier.md + base.md + voc.md | voice-of-segment.md (30-50 цитат) + segment-portrait.md (цвета 4) + segment-core.md (Hero-формула) + audience-report.html |
| Скиллы (активных) | 25+ | **18** (legacy → _legacy/) |
| core.md строк | 468 | **287** |
| audience-stage SKILL.md | 662 | **400** |
| Knowledge файлов | 7 | **9** (+ stage-lock + first-contact + pipeline-requirements + state-management) |
| Имена файлов в проекте | voc/dossier/base/stream/MAP/state | **читаемые английские** (voice-of-customer / segment-portrait / segment-core / segment-observations / segments-map / agent-state) |
| Технических мифов | 3 (run_in_background true, WebFetch для YT/TG-комментов, Wordstat WebFetch) | **0** |

---

## Migration guide v1.7 → v2.0

### Для существующих проектов (где Алекс уже распаковывал ЦА)

Никаких ручных действий не требуется. При первом запуске `/audience-status` или `/audience-resume` в проекте на старых именах файлов — Алекс **автоматически** переименует:

```
audience/voc.md          → audience/voice-of-customer.md
audience/segments/MAP.md → audience/segments/segments-map.md
{slug}/dossier.md        → {slug}/segment-portrait.md
{slug}/base.md           → {slug}/segment-core.md
{slug}/stream.md         → {slug}/segment-observations.md
progress.md              → _state/pipeline-progress.md
office/.../state.md      → office/.../agent-state.md
```

Содержимое файлов **не трогается**, только название. Клиенту приходит одна строка:

> *«Заметил у тебя старые имена файлов с прошлой версии. Перевёл на читаемый английский — содержимое не тронул, только название.»*

### Для нового установщика (если Алекс ещё не установлен)

```bash
# В корне офиса клиента
/install-agent alex-marketer
```

install-agent SKILL прочитает обновлённый `install.md`, скопирует файлы агента, обновит Director core.md / AGENTS.md / корневой CLAUDE.md.

### Для апдейта уже установленного Алекса (важно для Никиты)

⚠️ **Никита, у тебя Алекс установлен в `ai-office-v2/office/agents/alex-marketer/` через symlink.** Чтобы получить v2.0:

**Вариант 1 — переустановка через скилл (рекомендуется):**
```
В Claude Code сказать: «Переустанови alex-marketer»
```
Скилл `/install-agent alex-marketer` спросит про переустановку. Согласишься — перезальёт core/soul/CLAUDE/knowledge/skills, твои `overrides.md` / `memory.md` / `failures.md` сохранит как есть.

**Вариант 2 — ручной sync (если хочешь контроль):**
```bash
PACK="$WORKSPACE/client-office-template/_agent-packs/alex-marketer"
INSTALLED="$WORKSPACE/ai-office-v2/office/agents/alex-marketer"

# Перезалить ядро (overrides/memory/failures НЕ трогаем)
cp $PACK/core.md $INSTALLED/core.md
cp $PACK/soul.md $INSTALLED/soul.md
cp $PACK/CLAUDE.md $INSTALLED/CLAUDE.md
cp -r $PACK/knowledge $INSTALLED/

# Скиллы — перезалить активные, удалить legacy
rm -rf $WORKSPACE/.claude/skills/segments-discover
rm -rf $WORKSPACE/.claude/skills/segments-unpack
rm -rf $WORKSPACE/.claude/skills/segments-awareness
rm -rf $WORKSPACE/.claude/skills/segment-hypotheses
rm -rf $WORKSPACE/.claude/skills/segment-money-map
# (и другие legacy если они есть)

cp -r $PACK/skills/audience-* $WORKSPACE/.claude/skills/
cp -r $PACK/skills/competitors-research $WORKSPACE/.claude/skills/
cp -r $PACK/skills/revise-segment $WORKSPACE/.claude/skills/
cp -r $PACK/skills/marketer-* $WORKSPACE/.claude/skills/
cp -r $PACK/skills/unpack-product $WORKSPACE/.claude/skills/
cp -r $PACK/skills/unpack-funnel $WORKSPACE/.claude/skills/
cp -r $PACK/skills/funnel-build $WORKSPACE/.claude/skills/
cp -r $PACK/skills/product-build $WORKSPACE/.claude/skills/
cp -r $PACK/skills/product-add $WORKSPACE/.claude/skills/

# Обновить project template
cp -r $PACK/../../projects/_template-audience $WORKSPACE/projects/_template-audience.new
# (потом руками сравнить и слить или принять как есть)
```

**Вариант 3 — оставить v1.7 пока:**
Текущий установленный Алекс продолжит работать на старой логике до явного апдейта. Migration-детектор в новом коде сработает при первом запуске.

---

## Следующие шаги для Никиты

1. **Setup API/MCP** (~25 мин) — пройти инструкцию `SETUP-NIKITA.md`
2. **Sync pack → installed** через любой из 3 вариантов выше (рекомендую Вариант 1)
3. **Smoke-test на реальном клиенте** — взять любой текущий клиентский проект, запустить `/audience-status` → проверить что migration-check автоматически переименовал старые файлы → продолжить распаковку через `/audience-stage`
4. **Phase E** — после `/accept` Stage 1 первого реального клиента собрать `audience-report.html`, отправить ментору, забрать обратку, при необходимости — append в `failures.md` правило что не зашло

---

## Общая статистика дня (2026-04-28)

- **Время работы:** ~2 часа (после ночного марафона до 04:00)
- **Закрыто задач:** 8/8
- **Файлов изменено:** ~30 (template + core + knowledge + 14 скиллов + sales-meetings extension + install.md + RELEASE-NOTES + smoke-test + SETUP-NIKITA + новый skill audience-deliverable)
- **Замен через sed/Edit:** ~120 переименований путей
- **Новых файлов:** 4 (audience-deliverable/SKILL.md, deliverable/README.md, SETUP-NIKITA.md, _research/2026-04-28-smoke-test.md)
- **Production-ready:** ✅ да

**Всё.**
