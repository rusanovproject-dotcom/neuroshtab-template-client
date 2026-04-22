---
name: update-office
description: Безопасное обновление офиса до свежей версии из GitHub-шаблона. Бэкапит ВСЕ клиентские данные (стратегию, профиль, проекты, inbox, клиентов, знания, voiceprint, кейсы, overrides, память и failures помощников), подтягивает обновления, восстанавливает клиентские данные поверх. Ни один файл пользователя не пропадает. Триггеры — "обнови офис", "update office", "скачай свежую версию", "есть ли обновления офиса", "/update-office".
---

# /update-office — безопасное обновление офиса

Клиент хочет обновить офис до свежей версии из GitHub-шаблона. Твоя работа — **обновить без потери ни одного его файла**.

## Когда запускается
- Клиент пишет: "обнови офис", "есть обновления?", "скачай свежую версию", "update office", "/update-office"
- Или по явному указанию владельца офиса

---

## 🎯 Главный принцип

**Клиент ничего не должен потерять.** Всё что он делал в офисе — стратегия, онбординг, документы, голос бренда, кейсы, память помощников, его личные правки — сначала бэкапишь, потом обновляешь, потом возвращаешь его данные поверх.

Если что-то пойдёт не так — **атомарный откат**. Не оставляешь офис в промежуточном состоянии.

---

## 🗣 Тон клиенту

Живо, без технических терминов. **Не говорить**: "git", "reset", "stash", "merge", "conflict", "remote", "upstream", "commit", "pull". Всё это делаешь внутри через Bash, клиенту показываешь только результат по-человечески.

---

## Кросс-платформенность (macOS / Linux / Windows)

Скилл работает везде где есть bash. На Windows это **Git Bash** (идёт с Git for Windows) или **WSL**. Проверить и подсказать клиенту:

```bash
# Детект платформы (Claude делает первым шагом)
case "$OSTYPE" in
  darwin*)  PLATFORM="macOS" ;;
  linux*)   PLATFORM="Linux" ;;
  msys*|cygwin*|mingw*) PLATFORM="Windows (Git Bash)" ;;
  *)        PLATFORM="unknown" ;;
esac
```

**Если PLATFORM = unknown или Claude не может выполнить bash:**
Скажи клиенту: *"Для обновления нужен Git Bash (идёт в комплекте с Git for Windows — [git-scm.com/download/win](https://git-scm.com/download/win)) или WSL. Установи и запусти меня снова."*

**Пути backup:**
- macOS/Linux: `/tmp/office-backup-<ts>/`
- Windows Git Bash: тоже `/tmp/...` (Git Bash даёт эмуляцию)
- Если `/tmp` недоступен — fallback `$HOME/.office-backup/<ts>/`

**Команды которые могут отличаться:**
- `sha256sum` (Linux) vs `shasum -a 256` (macOS) vs `certutil -hashfile SHA256` (Windows PowerShell)
  → Детект: `command -v sha256sum || command -v shasum`
- `date +%Y%m%d-%H%M%S` — POSIX, работает везде в bash
- `cp -R`, `find`, `grep` — работает везде где bash

**Если хочешь максимальную кроссплатформенность** — вместо bash используй Python скрипт:
```python
import shutil, hashlib, subprocess, os
# backup, sha256, git operations — всё через Python stdlib
```
Python 3 обычно есть везде где Claude Code. Это более надёжный путь чем bash для Windows Native без Git Bash.

---

## Шаги

### Шаг 0. Pre-flight — проверяем что вообще можем обновлять

Через Bash проверь:
1. Текущая папка — git-репозиторий: `test -d .git && echo OK`
2. Есть remote на github: `git remote -v | grep github`
3. Remote указывает на `neuroshtab-template-client` ИЛИ есть `upstream`
4. Есть интернет: `git ls-remote origin HEAD` (если падает — нет сети)
5. Есть права на `/tmp/` для backup: `touch /tmp/.office-backup-test && rm /tmp/.office-backup-test`
6. Запуск из **корня офиса** (не подпапки): `test -f CLAUDE.md -a -d office -a -d .claude`

**Если что-то не так** — остановиться, объяснить клиенту по-человечески:
- Нет `.git/` → *"Офис не привязан к источнику обновлений — не могу обновить автоматически. Свяжись с организатором программы."*
- Нет интернета → *"Нет связи с GitHub — проверь интернет и попробуй снова."*
- Нет прав на `/tmp/` → *"Не хватает прав для резервной копии. Освободи место или свяжись с поддержкой."*
- Не в корне → *"Запусти меня из корневой папки офиса (где лежит CLAUDE.md)."*

### Шаг 1. Приветствие

Живо (не копируй — перефразируй):
> *"Сейчас обновлю офис до свежей версии. Минута работы. Все твои данные — стратегия, профиль, документы, память помощников, проекты — я сначала копирую в безопасное место, потом подтягиваю свежую версию, потом возвращаю твои данные поверх. Ничего не потеряется."*

### Шаг 2. Определить источник обновлений

Через Bash:
- `git remote -v` — смотрим remotes
- Если есть `origin https://github.com/rusanovproject-dotcom/neuroshtab-template-client...` — используем **origin**
- Иначе если есть `upstream https://github.com/rusanovproject-dotcom/neuroshtab-template-client...` — используем **upstream**
- Иначе — добавить: `git remote add upstream https://github.com/rusanovproject-dotcom/neuroshtab-template-client.git`, использовать **upstream**

Запомни переменную `$REMOTE` для следующих шагов.

### Шаг 3. BACKUP — сохраняем ВСЁ что может быть клиентским

Создай директорию `/tmp/office-backup-$(date +%Y%m%d-%H%M%S)/` и назови её `$BACKUP`.

**Бэкапим (через `cp -R`):**

```
$BACKUP/
├── strategy/                          ← вся office/strategy/ (strategy.md, progress-index.md, session-plan.md и т.д.)
├── client-profile.md                  ← office/client-profile.md (если есть)
├── AGENTS.md                          ← office/AGENTS.md (может клиент записал подключённых помощников)
├── agents/
│   ├── director/
│   │   ├── overrides.md
│   │   ├── memory.md
│   │   └── failures.md
│   ├── strategist/
│   │   ├── overrides.md
│   │   ├── memory.md
│   │   └── failures.md
│   └── demiurg/
│       ├── overrides.md
│       ├── memory.md
│       └── failures.md
│   (если установлены другие помощники через /install-agent — их папки целиком)
├── projects/                          ← ВСЯ папка, КРОМЕ _example-project/ и _template/
├── inbox/                             ← ВСЯ папка (prework.md, docs/*)
├── clients/                           ← ВСЯ, КРОМЕ _template/ и дефолтных README.md, INDEX.md
├── knowledge/                         ← ВСЯ, КРОМЕ дефолтных README.md, INDEX.md
├── env_file                           ← копия .env если есть (он в gitignore, но для надёжности)
├── commit_hash.txt                    ← git rev-parse HEAD (текущий коммит клиента)
└── manifest.txt                       ← список всех забэкапленных файлов + sha256 каждого
```

**Как делать backup папок `projects/`, `inbox/`, `clients/`, `knowledge/`:**
- Копируй целиком через `cp -R`
- После копирования удаляй из backup системные файлы (README.md / INDEX.md если они ровно такие же как в свежей версии — это позволит не восстанавливать старую версию README поверх новой)

**Пишем manifest.txt** в формате:
```
# Office backup manifest
# Created: 2026-04-21T17:45:00
# Client commit before update: abc1234
# Files backed up:
sha256  path
abc123  strategy/strategy.md
def456  client-profile.md
...
```

**Проверка:** после backup пройтись по ключевым файлам клиента и убедиться что они в backup. Если критичный файл (например `strategy/strategy.md`) не скопировался — **немедленно остановиться**, удалить backup, сказать клиенту: *"Не удалось сделать резервную копию — обновление отменено. Нулевой риск потерь. Свяжись с {{COACH_CONTACT}}."*

### Шаг 4. Stash локальных изменений

На случай если клиент что-то редактировал в git-tracked файлах:
```bash
git add -A
git stash push --include-untracked --message "office-update-$(date +%s)"
```

Это сохранит всё локальное в git stash — дополнительная защита поверх backup.

### Шаг 5. UPDATE — подтягиваем свежую версию

```bash
git fetch $REMOTE main
git reset --hard $REMOTE/main
```

После этого рабочая копия = **точная копия свежего шаблона** с github.

**Важно:** `reset --hard` удалил всё локальное, но backup в `$BACKUP` и stash — у нас есть. Безопасно.

### Шаг 6. RESTORE — восстанавливаем клиентские данные поверх

**Whitelist: всегда восстанавливаем из backup поверх свежей версии:**

| Путь | Правило восстановления |
|------|------------------------|
| `office/client-profile.md` | Копируем из backup если существует в backup |
| `office/agents/*/overrides.md` | Копируем поверх (клиент писал свои правила) |
| `office/agents/*/memory.md` | Копируем поверх (агент писал сам) |
| `office/agents/*/failures.md` | Копируем поверх |
| `office/strategy/strategy.md` | **Dummy-check**: если в backup файл содержит маркер "заполняется в /strategist-roadmap" или "Этот файл будет заполнен" — это был dummy, НЕ восстанавливать. Иначе — копируем поверх |
| `office/strategy/progress-index.md` | Dummy-check аналогично |
| `office/strategy/session-plan.md` | Копируем поверх если в backup есть |
| `office/strategy/weekly-logs/*` | Копируем поверх |
| `projects/` (целиком) | Merge: оставить в офисе всё что пришло с upstream, поверх — всё из backup КРОМЕ `_example-project` и `_template` (эти не восстанавливаем, их свежая версия актуальнее) |
| `inbox/` (целиком) | Merge: upstream базовые README, поверх — все клиентские файлы из backup (prework.md, docs/*) |
| `clients/` | Merge: upstream + восстановление клиентских подпапок (всех кроме `_template`, `README.md`, `INDEX.md`) |
| `knowledge/` | Merge: upstream + восстановление клиентских файлов (всех кроме дефолтных README.md, INDEX.md) |
| `.env` | Восстановить из backup если backup/env_file существует |
| `office/AGENTS.md` | **Особый случай** (см. ниже) |

**Особый случай — `office/AGENTS.md`:**
Клиент мог подключить нового помощника через `/install-agent`. Тогда в его версии AGENTS.md есть строка которой нет в свежей.

Логика:
- Если backup-версия по размеру больше свежей — клиент что-то добавил → восстановить backup поверх
- Иначе — взять свежую версию (возможно она обновилась)
- В сомнительных случаях — показать клиенту обе версии и спросить

**Особый случай — установленные через `/install-agent` помощники:**
Если клиент подключил например `designer` — его папка `office/agents/designer/` с core/overrides/memory/failures есть у него, но НЕТ в свежем template. Реакция:
- Детектим: сравниваем список папок в `office/agents/` между backup и свежей версией
- Если в backup есть папка которой нет в upstream — восстанавливаем целиком из backup (клиент её поставил через install-agent, апдейт не должен её сносить)

### Шаг 7. VERIFY — автоматические проверки

**Пройдись по чеклисту:**

- [ ] `$BACKUP/manifest.txt` — для каждой записи проверь sha256 соответствующего файла после restore. Если backup показывает sha256 = X, а текущий файл sha256 = Y, И при этом файл в whitelist "всегда из backup" — **это баг restore**, откатываемся.
- [ ] Ключевые файлы клиента — существуют:
  - `office/strategy/strategy.md` — если в backup была не-dummy версия, сейчас тоже не-dummy
  - `office/client-profile.md` — если была, есть
  - `projects/<slug>/` — все клиентские проекты на месте
  - `inbox/prework.md` — если был, есть
  - `office/agents/*/memory.md` и `failures.md` — размер как в backup (или больше)
- [ ] Размеры клиентских файлов НЕ меньше чем в backup (если меньше — что-то обрезалось, откат)
- [ ] Запретные слова в новых файлах: `grep -rniE "никит|русан|life-os|openclaw"` по всему офису — должно быть 0

**Если любой чек провалился:**
- Atomic rollback: восстанови всё из backup поверх, перейди на commit который был ДО update (из `commit_hash.txt`)
- Сообщи клиенту: *"Обновление не прошло чисто, вернул как было. Все твои данные на месте. Свяжись с {{COACH_CONTACT}} — разберёмся вместе."*

### Шаг 8. SUMMARY клиенту

Сформируй живой отчёт. Получи список изменений:
```bash
git log <old_commit>..HEAD --oneline --no-merges | head -10
```

Переведи commit messages на человеческий язык (не выдавай как есть). Пример формата:

> ✅ **Офис обновлён**
>
> **Твои данные — целы:**
> - Стратегия программы сохранена
> - Профиль на месте
> - Проект "{{PROJECT_NAME}}" — все файлы на месте
> - Память всех помощников сохранена
> - Личные правила в overrides — сохранены
>
> **Что нового** (топ-3 из апдейта):
> - [коротко, человеческим языком — что добавилось/поменялось]
> - ...
>
> **Резервная копия** лежит в `/tmp/office-backup-<timestamp>/` — автоудалится через 7 дней. Если что-то нужно откатить — скажи.

**Если в апдейте ничего не изменилось** (клиент уже на свежей версии):
> *"Ты уже на самой свежей версии. Обновления не потребовались."*

### Шаг 9. Запись в память Демиурга

В `office/agents/demiurg/memory.md` добавь запись (append-only):
```
### <YYYY-MM-DD HH:MM> — Update office
- Было: commit <old>
- Стало: commit <new>
- Что изменилось: <summary топ-3>
- Backup: /tmp/office-backup-<ts>
- Status: OK (все verify-чеки прошли)
```

---

## 🛡 Безопасность

- **НИКОГДА** `rm -rf` клиентских папок без успешного backup
- **НИКОГДА** не делай `git push` — обновление читает, но не пишет в удалённый репо клиента
- **НИКОГДА** не трогай `.git/hooks/`, `.claude/settings.local.json`
- **НИКОГДА** не удаляй backup в той же сессии — минимум 7 дней
- **НИКОГДА** не показывай клиенту "git stash", "merge conflict" и прочее — только человеческие формулировки
- **Атомарность:** если любой шаг провалился — полный откат из backup

---

## ⚠️ Edge cases

| Кейс | Действие |
|------|----------|
| Скилл запущен не из корня офиса | Остановка, "запусти из папки офиса где лежит CLAUDE.md" |
| Нет интернета | "Нет связи с GitHub, попробуй позже" |
| Нет прав на `/tmp/` | "Нет места/прав для бэкапа, освободи или свяжись с поддержкой" |
| Клиент прошёл онбординг, живая strategy.md у него, dummy у меня | Dummy-detection по маркерам, клиентская версия восстанавливается поверх |
| Клиент подключил помощника через /install-agent (например `designer`) | Папка helper-а детектится в backup, восстанавливается после reset |
| Клиент редактировал `CLAUDE.md` root | reset заменит его свежей версией. Если клиент хотел свои правила — они должны быть в `overrides.md`, НЕ в root CLAUDE.md. Это его забота. |
| Клиент закоммитил свои изменения в git | `git stash` сохранит только unstaged. `reset --hard` сбросит коммиты. Backup их всё равно сохранит файлово. При любом откате — restore из backup. |
| Клиент на Windows | Команды `cp -R`, `find`, `grep` работают через Git Bash/WSL. Если Windows без них — скилл должен проверить `which cp` → fallback на `robocopy` или явно остановиться. В v1 — bash only. |
| Запуск скилла второй раз подряд | Идемпотентно: новый timestamp backup, ничего не ломается |
| Клиент остановил скилл посередине | Backup уже создан, stash тоже. Скажи клиенту "остановился на шаге X, бэкап в /tmp/office-backup-<ts>, можно восстановить вручную или запустить ещё раз" |

---

## 🧪 Тесты перед раздачей (внутренние, Клод проверяет сам в dev)

Прогнать локально 5 сценариев:

1. **Чистый офис (только что клонирован)** — update должен быть no-op или подтянуть обновление, backup пустой (только READMEs)
2. **После `/setup` только** — `.env` заполнен, плейсхолдеры заменены → пережили
3. **После `/strategist-intake` + `-unpack` + `-discovery`** — есть `inbox/prework.md`, `inbox/docs/*`, черновики в `projects/<main>/` → всё пережило
4. **После `/strategist-prepare` + `-roadmap`** — `office/client-profile.md`, `office/strategy/strategy.md` (живая), `progress-index.md` (живой), `projects/<main>/strategy/roadmap.html` → **dummy-detection работает**, живые файлы побеждают dummy из upstream
5. **После работы нескольких сессий** — `memory.md` и `failures.md` всех 3 агентов с реальными записями → все 6 файлов побайтово сохранены

Каждый тест — проверить что после update:
- Количество клиентских файлов такое же или больше
- sha256 клиентских файлов совпадает с pre-update
- Никакие новые "Никита/Русанов/life-os" не появились
- Офис запустится заново (Claude читает CLAUDE.md — не падает)

---

## 🧠 Память (обязательно)

**Перед запуском:** `grep` по `office/agents/demiurg/failures.md` на "update-office" — нет ли старых ошибок с апдейтами.

**После запуска:** запись в `office/agents/demiurg/memory.md` (см. Шаг 9).

Если обновление провалилось — в `failures.md`: `YYYY-MM-DD → update-office failed at step X → причина → правило на будущее`.

---

## Выход

- Офис на свежей версии
- Все клиентские данные на своих местах (sha256 совпадает с pre-update)
- Backup в `/tmp/office-backup-<timestamp>/`
- Запись в `demiurg/memory.md`
- Живой summary клиенту без IT-слов

## Если провал

- Atomic rollback из backup
- Офис остаётся в **том же состоянии что до запуска** (точно, побайтово)
- Клиенту честное сообщение: *"Не смог обновить чисто, всё вернул как было. Ничего не потеряно."*
- Backup сохраняется для ручного разбора
