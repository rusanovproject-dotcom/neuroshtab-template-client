#!/bin/bash
# Git Safety — автоматический snapshot перед/после задач
# Используется через Claude Code hooks (SessionStart / SessionEnd)

MODE="${1:-snapshot}"  # snapshot | finish
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
MARKER_FILE="/tmp/.claude-git-safety-$(echo "$PROJECT_DIR" | md5 -q 2>/dev/null || echo "$PROJECT_DIR" | md5sum | cut -d' ' -f1)"

cd "$PROJECT_DIR" || exit 0

# Проверяем что это git-репо
git rev-parse --is-inside-work-tree &>/dev/null || exit 0

if [ "$MODE" = "snapshot" ]; then
    # === SNAPSHOT (перед началом работы) ===

    # Сохраняем текущий коммит как "before"
    BEFORE_SHA=$(git rev-parse --short HEAD)
    echo "$BEFORE_SHA" > "$MARKER_FILE"

    # Если есть незакоммиченные изменения — коммитим snapshot
    if ! git diff-index --quiet HEAD -- 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        git add -A
        git commit -m "🔒 snapshot before AI task: $(date +%Y-%m-%d\ %H:%M:%S)" --no-verify
        echo "Git Safety: snapshot created (was $BEFORE_SHA, now $(git rev-parse --short HEAD))"
    else
        echo "Git Safety: clean state, no snapshot needed ($BEFORE_SHA)"
    fi

elif [ "$MODE" = "finish" ]; then
    # === FINISH (после завершения работы) ===

    AFTER_SHA=$(git rev-parse --short HEAD)
    BEFORE_SHA=""
    [ -f "$MARKER_FILE" ] && BEFORE_SHA=$(cat "$MARKER_FILE")

    if [ -n "$BEFORE_SHA" ] && [ "$BEFORE_SHA" != "$AFTER_SHA" ]; then
        REPO_NAME=$(basename "$(git remote get-url origin 2>/dev/null)" .git 2>/dev/null || basename "$PROJECT_DIR")
        echo "Git Safety: Before=$BEFORE_SHA After=$AFTER_SHA (repo: $REPO_NAME)"
        echo "Diff: git log --oneline $BEFORE_SHA..$AFTER_SHA"
    fi

    # Чистим маркер
    rm -f "$MARKER_FILE"
fi

exit 0
