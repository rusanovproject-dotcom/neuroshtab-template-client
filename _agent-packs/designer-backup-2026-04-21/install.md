# Designer — install manifest

Машиночитаемые метаданные для установки пака через скилл `/install-agent designer`.
Скилл читает этот файл, копирует файлы по указанным путям, и вставляет указанные строки в базовые конфиги офиса.

---

## Metadata

```yaml
agent_id: designer
agent_name_human: Дизайнер
agent_name_in_chat: Дизайнер
short_role: Визуальный партнёр — Brand Book, промты для claude.ai/design и Claude Code артефактов
trigger_keywords: [дизайн, визуал, лендинг, презентация, обложка, брендбук, дашборд, инфографика, one-pager, КП, карточка]
version: 1.0.0
requires: []
```

---

## Files to copy

Источник — `_agent-packs/designer/`, цель — `office/agents/designer/`. Копируется рекурсивно со всеми подпапками.

```yaml
files:
  - src: core.md
    dest: office/agents/designer/core.md
  - src: CLAUDE.md
    dest: office/agents/designer/CLAUDE.md
  - src: overrides.md
    dest: office/agents/designer/overrides.md
    preserve_if_exists: true   # не затирать если клиент уже правил
  - src: memory.md
    dest: office/agents/designer/memory.md
    preserve_if_exists: true
  - src: failures.md
    dest: office/agents/designer/failures.md
    preserve_if_exists: true
  - src: knowledge/
    dest: office/agents/designer/knowledge/
  - src: skills/
    dest: office/agents/designer/skills/
  - src: templates/
    dest: office/agents/designer/templates/
```

---

## Folders to ensure

Создать если не существует (пустые / с README):

```yaml
folders:
  - path: knowledge/brand/
    keep_readme: true   # там уже есть README — не трогать
```

---

## Updates to `office/AGENTS.md`

Вставить строку в таблицу «Установленные агенты» (после последней существующей строки):

```markdown
| **Дизайнер** | Визуальный партнёр — Brand Book, промты для Claude Design и Claude Code артефактов | Любой запрос на визуал, лендинг, презентацию, обложку, инфографику |
```

Если в файле есть секция **Прямое обращение** — дописать `@designer` в список:

```markdown
**Прямое обращение** к агенту: `@director`, `@strategist`, `@demiurg`, `@designer`.
```

Если есть секция **Онбординг визуала (Дизайнер)** — она уже под этого агента, добавь её если отсутствует:

```markdown
**Онбординг визуала (Дизайнер):**
```
Собери мне Brand Book    # первый шаг — 10 минут диалога, артефакт в knowledge/brand/
Хочу лендинг / обложку / презентацию   # Дизайнер предложит тип, напишет промт
```
```

---

## Updates to root `CLAUDE.md`

**1. Layered include** — добавить строку в блок `@office/agents/.../core.md` (после последней):

```
@office/agents/designer/core.md
```

**2. Таблица «Типовые роли»** — вставить строку (после последней существующей):

```markdown
| **Дизайнер** | Brand Book + промты для Claude Design и Claude Code | Любой запрос на визуал — лендинг, обложка, презентация, дашборд, брендбук |
```

---

## Updates to `office/agents/director/core.md`

**1. В секцию «Команда офиса»** (список «Типовые роли») — добавить строку:

```markdown
- **Дизайнер** — Brand Book, визуал, промты для Claude Design и Claude Code артефактов
```

**2. В секцию «Роутинг»** — добавить строку в «Базовое правило маршрутизации»:

```markdown
- "хочу дизайн / визуал / лендинг / презентацию / обложку / дашборд / Brand Book" → **Дизайнер** (см. секцию "Дизайн-триггер" ниже)
```

**3. Добавить секцию «Дизайн-триггер»** (вставлять ПЕРЕД секцией «Output contract», если она отсутствует):

```markdown
## Дизайн-триггер

Когда клиент говорит что-то вроде: *"хочу сделать дизайн / визуал / презентацию / лендинг / обложку / карточку / инфографику / дашборд / one-pager / КП / брендбук"* — **не бросайся сам**.

Действия:

1. **Проверь контекст.** Прочитай `office/client-profile.md` (что за проект) и если есть — `office/strategy/strategy.md` (в какой фазе программы клиент). Дизайн должен ложиться в стратегию, не быть tier-4 отвлечением.
2. **Открой каталог.** Читай `agents/designer/knowledge/design-catalog.md`. Там 10 типов с описанием, стеком (Claude Design / Claude Code) и промт-стабом.
3. **Предложи 3-5 релевантных вариантов** из каталога — не все 10. Фильтруй по задаче клиента. Формат ответа:
   > *"Под твой запрос подходит:
   > — [тип 1]: [1 строка когда использовать]
   > — [тип 2]: ...
   > — [тип 3]: ...
   > Что ближе? Или опиши конкретнее."*
4. **После выбора — handoff Дизайнеру** с контекстом:
   ```
   to: Designer
   task: [выбранный тип дизайна]
   context: [проект / стратегия / специфика запроса]
   brand_book: knowledge/brand/{project}/brand-book.md (есть / нет)
   output: промт для [Claude Design / Claude Code] + объяснение куда копировать
   ```
5. **Если Brand Book отсутствует** — предупреди Дизайнера чтобы он сначала запустил `brand-onboarding`. Это займёт 10 минут и экономит десятки часов на последующих дизайнах в едином стиле.

**Не делай сам.** Твоя задача — классифицировать и передать. Промты пишет Дизайнер.
```

---

## Updates to `office/agents/director/knowledge/routing-patterns.md`

**1. В таблицу «Core-роутинг»** — добавить строки:

```markdown
| "хочу дизайн / визуал / лендинг / обложку / презентацию / карточку / дашборд / инфографику / Brand Book" | **Дизайнер** | см. секцию "Дизайн-триггер" в `core.md` — сначала предложить 3-5 типов из каталога |
| "собери стиль / брендбук / визуальный язык" | **Дизайнер** → `brand-onboarding` | первый шаг для любого проекта, создаёт `knowledge/brand/{project}/brand-book.md` |
```

**2. В «Правила»** — добавить пункт:

```markdown
- **Brand Book — первый шаг дизайн-работы.** Если клиент просит дизайн, а `knowledge/brand/{project}/brand-book.md` отсутствует — Дизайнер сначала запускает `brand-onboarding`, потом делает первый промт.
```

**3. В «Параллельный / последовательный режим»** — добавить связки:

```markdown
- **Стратег → Дизайнер** — после распаковки стратегии можно сразу собрать Brand Book под проект
- **Дизайнер → Архитектор** — если для нового проекта нужна свежая папка `knowledge/brand/{project}/`
```

---

## First-task suggestion

Типичная первая задача для клиента после установки — сборка Brand Book:

```yaml
first_task:
  suggestion: "Brand Book"
  why: "Первый шаг любой визуальной работы. 10 минут разговора — дальше каждый дизайн в одном стиле, а не зоопарк."
  skill: brand-onboarding
```

---

## Message to client (after install)

Живым языком, без IT-терминов. Это сообщение скилл показывает клиенту после успешной установки. Используй как шаблон — допиши имя клиента если есть.

```
Готово. В команде появился Дизайнер — твой визуальный партнёр.

Что он умеет:
— собрать Brand Book проекта (палитра, шрифты, настроение) — 10 минут разговора
— написать инструкцию для claude.ai/design чтобы получить картинку за 30 секунд (обложки, постеры, карточки)
— написать инструкцию для Claude Code чтобы получить живую страницу (лендинг, дашборд, презентацию)

Он сам не рисует — пишет такие шаблоны, что ты копируешь, вставляешь, получаешь результат.

Давай начнём с Brand Book? Без него каждый дизайн будет в своём стиле — с ним всё в одной эстетике. Скажи "собери мне Brand Book" и я запущу.
```

---

## Uninstall (future)

Для будущей поддержки `/uninstall-agent designer`. Реверс установки:

```yaml
uninstall:
  remove_folders:
    - office/agents/designer/
  remove_lines_from:
    - path: office/AGENTS.md
      match: "**Дизайнер**"
    - path: CLAUDE.md
      match: "@office/agents/designer/core.md"
    - path: CLAUDE.md
      match: "| **Дизайнер** |"
    - path: office/agents/director/core.md
      match: "**Дизайнер** — Brand Book"
    - path: office/agents/director/core.md
      section: "## Дизайн-триггер"   # удалить секцию целиком
    - path: office/agents/director/knowledge/routing-patterns.md
      match: "Дизайнер"
  preserve:
    - knowledge/brand/   # клиентский контент, не трогать
```
