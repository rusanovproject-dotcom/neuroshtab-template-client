---
name: team-architect
description: >
  Архитектура и диагностика команды AI-офиса. Span of control, bottleneck-анализ,
  интеграция новых агентов, реструктуризация, масштабирование, Team Health Score.
  MANDATORY TRIGGERS: структура команды, добавить агента, team health, реструктуризация,
  кого добавить, bottleneck, span of control, team architect, организация команды,
  перегруз, недогруз, дублирование, новый отдел, кластер, масштабирование команды.
  DO NOT use when: создание агента (-> Demiurg build), аудит качества (-> Brahma).
---

# Team Architect — Архитектура команды

Director использует этот скилл для оценки, диагностики и перестройки команды.
Принцип: данные -> решение -> действие. Без догадок.

## Режимы

```
ASSESS      — оценка текущей команды (health, span, bottlenecks)
INTEGRATE   — добавление нового агента (куда, связи, handoffs)
RESTRUCTURE — реорганизация (отделы, кластеры, уровни)
DIAGNOSE    — поиск проблем (перегруз, дублирование, waste)
SCALE       — план масштабирования (когда, как, до какого размера)
```

## ASSESS

**Input:** запрос на оценку команды
**Process:**
1. Прочитай `../../../../AGENTS.md` — текущий состав
2. Посчитай span of control: кол-во прямых подчинённых Director
3. Формула Брукса: C = n*(n-1)/2 — каналы коммуникации
4. Team Health Score по 5 факторам (references/frameworks.md → Project Aristotle)
5. Сравни с нормами (references/frameworks.md → Span of Control)

**Output:**
```
Span: {N} агентов. {Норма/Внимание/Критично}.
Каналы: {C}. Overhead: {низкий/средний/высокий}.
Health Score: {X}/25. [{расшифровка по факторам}]
Bottleneck: {агент} ({причина}) или "Не выявлен".
Рекомендация: {конкретное действие или "Без изменений"}.
```

## INTEGRATE

**Input:** "добавить агента {роль}" или "куда поставить {агента}"
**Process:**
1. Проверь Decision Tree: нужен ли новый агент? (references/decision-trees.md)
2. Определи кластер по типу задач (references/team-patterns.md)
3. Определи связи: от кого получает, кому передаёт
4. Проверь чеклист интеграции (references/checklists.md)
5. Оцени impact на span of control

**Output:**
```
Агент: {имя}
Кластер: {Production/Intelligence/Engineering/Operations}
Получает от: {список агентов}
Передаёт: {список агентов}
Span после: {N+1}. {Норма/Нужен кластер-лид}.
Handoffs: {описание 2-3 ключевых handoff}
Чеклист: {статус по пунктам}
```

## RESTRUCTURE

**Input:** "реорганизовать команду" или "ввести отделы"
**Process:**
1. Текущая структура из AGENTS.md
2. Определи паттерн (references/team-patterns.md): supervisor, hierarchical, sequential
3. Decision Tree: нужна ли иерархия? (references/decision-trees.md)
4. Предложи 2 варианта структуры с trade-offs
5. Чеклист реструктуризации (references/checklists.md)

**Output:** 2 варианта со схемой, плюсы/минусы, рекомендация.
## DIAGNOSE

**Input:** "что не так с командой" или конкретный симптом
**Process:**
1. Чеклист диагностики (references/checklists.md)
2. Lean waste анализ — 7 типов (references/frameworks.md)
3. Theory of Constraints — найди 1 главный bottleneck (references/frameworks.md)
4. Проверь: перегруз, недогруз, дублирование, unclear ownership

**Output:**
```
Bottleneck: {агент/процесс} — {описание}.
Waste: {тип} — {где именно}.
Перегруз: {агент} ({причина}) или "Нет".
Недогруз: {агент} ({причина}) или "Нет".
Дублирование: {зоны пересечения} или "Нет".
Рекомендация: {1-3 конкретных действия}.
```
## SCALE

**Input:** "когда расширять" или "план масштабирования"
**Process:**
1. Текущая стадия роста (references/frameworks.md → стадии)
2. Decision Trees: новый агент? новый отдел? (references/decision-trees.md)
3. Пороги: span > 9 -> кластеры, > 12 -> обязательная иерархия
4. Предложи план на +3, +5, +10 агентов

**Output:** план с порогами, паттернами организации, рисками.
## Примеры

**Пример 1: ASSESS**
```
Input: "Оцени команду"
Output:
  Span: 7. Норма (оптимум 5-9).
  Каналы: 21. Overhead средний.
  Health Score: 19/25.
    Безопасность эскалации: 4/5
    Надёжность output: 4/5
    Ясность ролей: 4/5
    Связь с продуктом: 4/5
    Видимость impact: 3/5 (ops/log.md обновляется нерегулярно)
  Bottleneck: Copywriter (очередь 5 задач, единственный на контент).
  Рекомендация: усилить логирование результатов, мониторить нагрузку Copywriter.
```

**Пример 2: INTEGRATE**
```
Input: "Добавить агента для email-маркетинга"
Output:
  Decision Tree: регулярные задачи? ДА. Есть агент? Copywriter, но перегружен.
  Рекомендация: НЕ новый агент. Добавить скилл email-marketing к Copywriter.
  Если нагрузка > 70% → тогда отдельный Email Marketer.
  Кластер: Production (рядом с Copywriter, Designer).
  Span после: 8. Норма.
```

**Пример 3: DIAGNOSE**
```
Input: "Задачи теряются"
Output:
  Bottleneck: Director (роутинг перегружен при 3+ параллельных задачах).
  Waste: Waiting — агенты ждут handoff от Director.
  Рекомендация: 1) WIP limit = 3 задачи одновременно.
  2) При span > 9 — ввести Production Lead для автономного роутинга контент-задач.
```

## Ресурсы

- `references/frameworks.md` — Span of Control, Брукс, RACI, Aristotle, Lean, ToC
- `references/decision-trees.md` — Деревья решений для типовых ситуаций
- `references/checklists.md` — Чеклисты: новый агент, интеграция, реструктуризация, диагностика
- `references/team-patterns.md` — Паттерны организации команды
