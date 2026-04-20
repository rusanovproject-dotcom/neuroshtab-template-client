# Learnings
> Пополняется после каждой сборки

---

## 2026-03-22: Сборка AI Cherry (agent-polisher → ai-cherry)

**Что выучил:**
- Progressive disclosure работает: 3 файла knowledge загружаются по запросу, CLAUDE.md остаётся лёгким (88 строк)
- Pushy description критичен для триггеринга — без MANDATORY TRIGGERS скиллы недотриггерятся
- Дубли контента опасны: build-team/references/checklist-state.md был идентичной копией knowledge/architecture/checklist-state.md — при обновлении одного второй устареет
- Sub-INDEX в подпапках knowledge (architecture/, skill-mastery/, tactics/) ускоряет навигацию: агент видит "когда загружать" без чтения всех файлов
- Секция "НЕ отвечает за" с hand-off — обязательна. Без неё агент пытается делать всё

**Паттерн:** 7 осей шлифовки от AI Cherry (identity, economy, trigger, navigation, examples, freshness, boundaries) — хороший чеклист для самопроверки после каждой сборки

## 2026-03-22: Self-upgrade v2.0 (тройной аудит)

**What:** Полная реструктуризация после аудита Cherry (6.9/10), Brahma (62/100), Vibe Coder (8.2/10).
**Why:** Три эксперта единогласно указали на 5 критических проблем: дублирование, конфликт триггеров, отсутствие валидации, изоляция от системы, нет примеров.

**Learned:**
- Near-miss в description скиллов критичен -- без "DO NOT use when" Claude не различает build-team от heavy-build
- validate.sh ловит проблемы автоматически за 2 секунды -- обязательно запускать после каждой сборки
- Перенаправления (references/ → knowledge/) добавляют лишний шаг. Прямые пути экономят 1 чтение на фазу
- Субагенты в отдельных .md файлах с конкретными промтами дают лучший результат чем inline описания
- Конвейер Demiurg → Brahma → Cherry устраняет self-grading bias
- MEMORY.md между сессиями сохраняет решения и ошибки -- не нужно переучиваться
- Quality gates между фазами предотвращают "проскакивание" -- каждая фаза имеет условие прохождения
