# Team workflow — client-office-template

Команда: Никита (@rusanovproject-dotcom) + напарник (@skarbitra-debug).

## Быстрый старт для напарника

```bash
# 1. Клонировать
git clone https://github.com/rusanovproject-dotcom/client-office-template.git
cd client-office-template

# 2. Установить pre-commit (один раз, опционально)
pip install pre-commit
pre-commit install
```

## Рабочий flow

```bash
# Перед началом работы
git checkout main
git pull origin main

# Ветка под задачу
git checkout -b feat/описание-задачи

# Работаешь → коммитишь → пушишь
git add <files>
git commit -m "feat: что сделал"
git push -u origin feat/описание-задачи

# PR
gh pr create --base main

# Claude Code Review бот сам ревьюит PR (1-2 мин) →
# если бот зелёный, мержишь сам через gh pr merge --squash
```

## AI Code Review — кто смотрит PR

Ревью делает **автоматический Claude-бот** (`.github/workflows/claude-review.yml`).

- Открыл PR → бот в течение 1-2 минут пишет комментарий с анализом: что хорошо, что подозрительно, где баги.
- Зелёный комментарий → можно сразу `gh pr merge --squash`.
- Красный (нашёл проблему) → правим, пушим в ту же ветку, бот перепроверит.
- Второй человек нужен только для сложных PR — тогда в Telegram.

## Правила

1. **Никогда** не пушь в `main` напрямую. Только через PR.
2. Ветку держи коротко — **до 2 дней жизни**. Длиннее — разбей на мелкие PR.
3. Перед push: `git pull --rebase origin main` (накатить свежий main поверх).
4. `.env` — **никогда в git**. Секреты хранить отдельно (Bitwarden/1Password/etc).
5. Большие файлы (аудио, видео, базы >10MB) — НЕ в git, через `.gitignore`.
6. Коммит-сообщения — понятные: `feat: ...`, `fix: ...`, `docs: ...`, `chore: ...`.
7. PR-описание пиши по шаблону (`.github/PULL_REQUEST_TEMPLATE.md`).

## Полезные команды

```bash
gh pr list                   # все открытые PR
gh pr checkout 42            # залогиниться в PR #42
gh pr merge 42 --squash      # мерж (squash = один чистый коммит)
```

## Если конфликт при merge

```bash
git checkout feat/моя-ветка
git pull --rebase origin main
# разрешить конфликты в редакторе
git rebase --continue
git push --force-with-lease
```

## Вопросы — в Telegram
