#!/usr/bin/env bash
# Кнопка обновления коуча для ученика: подтягивает движок, НЕ трогая личные данные.
# Рабочие файлы (профиль, цели, состояние, дневники, метрики) — в .gitignore, git pull их не касается.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Обновляю движок коуча…"
STASHED=0
if ! git diff --quiet || ! git diff --cached --quiet; then
  git stash push -u -m "neuro-coach auto-update $(date +%F-%T)" && STASHED=1
fi
# Тянем upstream ТЕКУЩЕЙ ветки (репо может быть на master или main — не хардкодим)
git pull --rebase --autostash
[ "$STASHED" = 1 ] && git stash pop || true

bash scripts/bootstrap.sh   # доинициализировать новые шаблоны, если появились
echo "Движок обновлён. Твои данные (профиль, цели, дневники, метрики) нетронуты."
