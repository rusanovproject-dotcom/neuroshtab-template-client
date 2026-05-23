#!/usr/bin/env bash
# Инициализация рабочих файлов инстанса из шаблонов.
# Идемпотентный: копирует каждый *.template.* → рабочий файл ТОЛЬКО если рабочего ещё нет.
# Существующие данные ученика не трогает. Вызывается онбордингом (first-session) и вручную.
set -euo pipefail
cd "$(dirname "$0")/.."

copy_if_absent() { [ -f "$2" ] || { cp "$1" "$2"; echo "создан: $2"; }; }

copy_if_absent core/profile.template.md        core/profile.md
copy_if_absent core/drives.template.md         core/drives.md
copy_if_absent core/history.template.md        core/history.md
copy_if_absent core/people.template.md         core/people.md
copy_if_absent core/what-works.template.md     core/what-works.md
copy_if_absent goals.template.md               goals.md
copy_if_absent state.template.md               state.md
copy_if_absent tracking/metrics.template.jsonl tracking/metrics-2026.jsonl

echo "Готово. Рабочие файлы на месте, существующие не тронуты."
