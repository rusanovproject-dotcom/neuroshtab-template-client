#!/bin/bash
OFFICE_ROOT="${OFFICE_ROOT:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
# knowledge-autoingest.sh — ДЕТЕКЦИЯ нового сырья для wiki (не ingest!).
# Кладёт новые файлы в _ingest-queue.md. Дёшево, без вызова claude → без рекурсии.
# Запуск: hook Stop/SessionStart. Сам ingest делает /wiki-auto-ingest или auto-ingest.sh.

# Защита от рекурсии: если запущены внутри headless-ingest — молчим.
[ -n "$KNOWLEDGE_AUTOINGEST" ] && exit 0

KB="$OFFICE_ROOT/knowledge"
QUEUE="$KB/_ingest-queue.md"
LOG="$KB/log.md"
TODAY=$(date +%Y-%m-%d)
[ -f "$QUEUE" ] || exit 0

new=0
# Сканируем места, куда падает сырьё
while IFS= read -r f; do
  base=$(basename "$f")
  rel="${f#$KB/}"
  # уже в логе ingest? уже в очереди? — пропускаем
  grep -qF "$base" "$LOG" 2>/dev/null && continue
  grep -qF "$rel" "$QUEUE" 2>/dev/null && continue
  # вставляем сразу после строки "## Pending" (а не в конец файла)
  entry="- [ ] $rel | added:$TODAY | status:pending"
  awk -v e="$entry" '{print} /^## Pending$/ && !done {print e; done=1}' "$QUEUE" > "$QUEUE.tmp" && mv "$QUEUE.tmp" "$QUEUE"
  new=$((new+1))
done < <(find "$KB/inbox" "$KB/ai-learning" -type f \( -name '*.md' -o -name '*.txt' -o -name 'SUMMARY*' \) 2>/dev/null | grep -v -E '/(INDEX|README|_)' )

if [ "$new" -gt 0 ]; then
  echo "[autoingest] Новое сырьё в очереди: $new файл(ов). Обработать: /wiki-auto-ingest"
fi
exit 0
