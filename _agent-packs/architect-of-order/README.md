# Architect of Order — agent pack

Готовый агент **Архитектор-Порядка** для AI-офиса. Ставится в офис командой `/install-agent architect-of-order` — без ручных правок конфигов.

## Что это

Единственный агент с правом ревизии **структуры**, **памяти** и **качества команды**. Не делает контентную работу. Следит чтобы офис не превращался в свалку через 3 месяца.

Реализует семейство ролей-«уборщиков» — подход, собранный из публичных источников 2025-2026 (Florian audit-prompt v5.0, AutoDream, MS Agent Governance Toolkit, Anthropic Memory Tool API, Arize/MindStudio failure-pattern recognition). Это не «индустриальный канон» (он ещё не устаканился), а **сводка лучших практик** на момент сборки пака.

**6 архетипов уборщиков** (каждый ловит свой класс проблем):

1. **Memory Cleaner** (AutoDream) — чистит дубли / противоречия / stale timestamps в memory
2. **Skill Auditor** — проверяет frontmatter / triggers / size / hardcoded secrets в SKILL.md
3. **Routing Validator** — каждый агент достижим, нет коллизий триггеров
4. **Structure Linter** — PARA, INDEX.md, symlinks, settings.json, плейсхолдеры
5. **Knowledge Dedup** — Jaccard на heading sets, INDEX-дрейф
6. **Failure Pattern Detector** — повторы в failures.md → правила в core.md

**Плюс 8-мерная Florian-rubric** (адаптированная) — отдельная финальная сборка в режиме **deep**: после прохода 6 архетипов считается итоговый score 0-100 с tier'ами Starter / Growing / Established / Optimized. Это не «седьмой архетип», а сводка результатов.

## Три режима

| Режим | Команда | Время | Что делает |
|-------|---------|-------|------------|
| **scan** | `/office-architect` (default) | ≤5 мин | Read-only inventory, surface scan 6 архетипов, отчёт без mutation |
| **tidy** | `/office-architect tidy` | ≤15 мин | scan + soft-fixes под approval (frontmatter, datestamps, `_archive/` move) |
| **deep** | `/office-architect deep` | ≤60 мин | Полный аудит 6 архетипов + 8-мерная Florian-rubric (финальная сборка) + предложения правил для core.md агентов |

## Защиты от over-cleaning

10 правил перед каждым действием:

1. **Append-only архивация** — старое в `_archive/<YYYY-MM-DD>/`, не stomp
2. **Citation rule** — каждое finding: `path/file.ext:LINE`
3. **«Looks bad but is actually fine»** — обязательная секция отчёта
4. **Approval gate** — Phase 4: `да / только важное / "1,3" / нет`
5. **Whitelist tools** — `Bash(rm:*)`, `Bash(mv:*)` запрещены полностью
6. **Time cap** — 5/15/60 мин hard cap
7. **Iteration cap** — не >3 проходов по одному файлу
8. **Privacy** — `.env*`, `.pem`, `credentials*`, `secrets*` не читает; токены в отчёте `[REDACTED]`
9. **Memory update** — после работы append в `memory.md` / `failures.md`
10. **Idempotency** — повторный запуск без изменений = тот же отчёт

## Структура пака

```
architect-of-order/
├── install.md          # манифест для /install-agent
├── core.md             # главный системный промпт (≤500 строк, frontmatter с allowed-tools)
├── soul.md             # душа: миссия, тон, чего не делает
├── memory.md           # начальный шаблон памяти (append-only)
├── failures.md         # начальный шаблон с одной затравочной записью (формат)
├── overrides.md        # пустой шаблон для кастомизаций пользователя
├── CLAUDE.md           # склейка @soul + @core + @overrides
├── README.md           # этот файл
└── skills/
    └── office-architect/
        └── SKILL.md    # главный скилл агента: 3 режима scan/tidy/deep
```

## Установка

```
/install-agent architect-of-order
```

После установки агент появляется в `office/agents/architect-of-order/`, прописывается в `office/AGENTS.md`, корневом `CLAUDE.md`, `office/agents/director/core.md` и `routing-patterns.md` автоматически.

## Использование

После установки — пиши Director'у в чат:

- **«проверь офис»** / **«наведи порядок»** — запускает scan (быстрый отчёт, ничего не трогает)
- **«почистим офис»** / **«лёгкая чистка»** — tidy (15 мин под approval)
- **«полный аудит»** / **«что не так»** — deep (60 мин, всё подробно)

Все отчёты сохраняются в `office/ops/audits/YYYY-MM-DD-<mode>.md` — потом можно сравнить прогресс через месяц.

## Что Архитектор НЕ делает

- Не пишет офферы / тексты / стратегию / дизайн
- Не правит тело `core.md` / `soul.md` агентов (только рекомендации в отчёте)
- Не редактирует `overrides.md` любого агента (это персональные данные пользователя)
- Не удаляет файлы (только перенос в `_archive/<date>/`)
- Не запускает себя сам (`disable-model-invocation: true`)
- Не отвлекает от Tier 1 задач — если пользователь работает над деньгами, аудит откладывается

## Источники

Пак собран по 6-документному исследованию архитектуры AI-офисов (`docs/research/office-architecture-2026-05-04/`):

- **Florian audit-prompt v5.0** — 4-фазная структура, 8-мерная rubric
- **ksimback tech-debt-skill** — citation rule, «Looks bad but is actually fine»
- **Compound document-review** — 3-классовая классификация findings
- **Anthropic Memory Tool API** — immutability, append-only, audit trail
- **AutoDream** — правила memory cleanup
- **Microsoft Agent Governance Toolkit** — 10 OWASP Agentic Risks
- **Arize / MindStudio** — failure-pattern recognition

## Версия

`1.0.0` — initial release. Если нашёл проблемы или хочешь дополнить — открой `failures.md` и добавь запись, или скажи владельцу шаблона.
