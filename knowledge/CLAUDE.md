# Knowledge Base — CLAUDE.md

## Язык
Всегда на русском (или языке пользователя).

## Read INDEX.md first — главное правило
Любой агент при запросе к `knowledge/` ОБЯЗАН первым делом прочитать `INDEX.md`
(реестр всех файлов с однострочными summary). Не грепать всё дерево.

Pipeline retrieval:
1. Прочитать `knowledge/INDEX.md` (помещается в один проход).
2. Найти релевантные узлы по summary в нужной категории.
3. Идти по `[[ссылкам]]` в конкретные файлы (≤7 на типовой запрос).
4. Файлы с маркером `[LARGE NNNNL]` — открывать только при прямой релевантности.

При добавлении нового файла:
- Положить в нужную категорию (`domains/<домен>/` для атомарных заметок).
- Добавить строку в `INDEX.md` (`- [Title](path.md) — summary ≤100 chars`).
- Добавить запись в `log.md` (`## YYYY-MM-DD — add — <slug>`), append-only.

## Архитектура памяти
Karpathy LLM Wiki. Канон: `ai-offices/distilled/memory-architecture.md`.
Сырьё (`inbox/`, `ai-learning/`) — читаем, не меняем. Атомарный слой — `domains/<домен>/`.

Три слоя:
| Слой | Где | Правило |
|------|-----|---------|
| raw (сырьё) | `inbox/`, `ai-learning/` | только читаю, никогда не меняю |
| wiki (заметки) | `domains/<домен>/` (concepts / tools / people / themes) | создаю и линкую через `/wiki-ingest` |
| schema (правила) | этот файл + скиллы `wiki-*` | читаю перед действием |

## Авто-ingest
Новое сырьё в `inbox/` или `ai-learning/` → хук `.claude/hooks/knowledge-autoingest.sh` →
строка в `_ingest-queue.md` (секция `## Pending`).
Разобрать: `/wiki-auto-ingest` (тихо, пачкой) или `/wiki-ingest <файл>` (с гейтом). Чистка графа: `/wiki-lint`.

## Маршрутизация входящих
| Тип | Куда |
|-----|------|
| Концепт / метод / инструмент | `domains/<домен>/` через `/wiki-ingest` |
| Быстрая заметка (статья, шаблон, кейс) | `/new-knowledge` (flat-card в `knowledge/<slug>.md`) |
| Аудитория / ЦА / аватары | `domains/audience/` |
| Продукт / офферы | `domains/product/` |
| Бренд / голос / визуал | `domains/brand/` |
| Конкурент / разведка рынка | `domains/competition/` |
| Непонятно куда | `inbox/` + спросить пользователя |
