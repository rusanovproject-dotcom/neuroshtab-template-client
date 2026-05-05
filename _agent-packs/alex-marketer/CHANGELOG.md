# Changelog — Alex Marketer Pack

Все значимые изменения этого пака. Формат — [Keep a Changelog](https://keepachangelog.com/ru/1.1.0/), версионирование — [SemVer](https://semver.org/lang/ru/).

---

## [3.1.1] — 2026-05-01

### Fixed (SYSTEM-BUG)
- **Pre-flight evidence — internal-only.** Раньше `core.md` пункт 3 обязывал агента выводить клиенту служебную строку *«📚 Прочитал память: N записей failures, M decisions...»* как evidence что Pre-flight отработал. Это ломало первое впечатление клиента — звучало как робот, а не живой партнёр.
- Теперь Pre-flight выполняется **молча**, evidence пишется в `agent-state.md` поле `last_pre_flight: <ISO timestamp>`. Гейт скилла перезапускает Pre-flight если timestamp старше 60 минут.
- В `agent-state-template.md` добавлено поле `last_pre_flight: null`.

### Why
Найдено через `/adapt-employee` — новый скилл-фильтр Демиурга, проверяющий voice/UX агента перед переносом в клиентский офис. Это первый SYSTEM-BUG из категории «инструкция core.md велит выводить служебку клиенту». Фикс идёт в исходник пака — все ученики получат при следующем `/update-office`.

### Migration for installed clients
Если у клиента уже установлен Alex Marketer (`office/agents/alex-marketer/`):
1. Запустить `/update-office` — подтянет свежий core.md
2. В существующем `agent-state.md` добавить строку `last_pre_flight: null` в YAML-фронтматтер (или удалить файл — агент пересоздаст из template)
3. Никаких других действий не требуется. `overrides.md` пользователя не трогается.

---

## [3.1.0] — 2026-04-28

### Changed
- JTBD-методология (Jobs To Be Done) как основа распаковки ЦА вместо БПСВ. Полный пайплайн в `skills/jtbd/SKILL.md` (13 шагов на сегмент × 3-5 сегментов).
- Добавлен опциональный модуль `/jtbd-aicustdev` для синтетических касдевов когда у клиента мало живой фактуры.
- Добавлен `/jtbd-critic` — критик в новом чате с чистым контекстом.

### Added
- `knowledge/jtbd/` — methodology-core.md, jtbd-handbook.md, etalon-jobstories.md, value-mechanics.md, jtbd-interview-guide.md.

---

## [2.0.0] — ранее

Первая публичная версия пака для учеников. Распаковка через БПСВ-классификацию.
