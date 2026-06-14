#!/usr/bin/env bash
# pre-push — ПД-гейт клиентского AI-офиса.
#
# Этот офис собран из ПУБЛИЧНОГО шаблона, но в работе накапливает ПД:
# карточки людей (clients/), транскрипты разборов, лиды/кейсы (inbox/docs/),
# а также секреты. Задача хука — не дать ПД / секретам / медиа уехать в git
# ни при каком push (defense in depth поверх .gitignore).
#
# Установка (копия, НЕ симлинк — .git/hooks вне версионирования):
#   cp .claude/hooks/pre-push-pd-gate.sh .git/hooks/pre-push && chmod +x .git/hooks/pre-push
# Это делает скилл /setup автоматически.
# Осознанный обход: git push --no-verify (на свой страх).

set -uo pipefail

REMOTE_NAME="${1:-}"
REMOTE_URL="${2:-}"

# --- (опционально) ограничить push одним приватным репо ---
# По умолчанию пусто = push разрешён в любой remote, но запрещённый КОНТЕНТ
# всё равно блокируется ниже. Чтобы жёстко привязать офис к своему приватному
# репо — впиши регэксп owner/repo, например:
#   ALLOWED_REMOTE_RE='[:/]myname/my-private-office(\.git)?/?$'
ALLOWED_REMOTE_RE=''

if [[ -n "$ALLOWED_REMOTE_RE" ]] && ! [[ "$REMOTE_URL" =~ $ALLOWED_REMOTE_RE ]]; then
  echo "⛔ ПД-ГЕЙТ: push в remote '$REMOTE_NAME' ($REMOTE_URL) ЗАПРЕЩЁН." >&2
  echo "   Офис привязан к приватному репо. Легитимный remote — поправь ALLOWED_REMOTE_RE в .git/hooks/pre-push." >&2
  exit 1
fi

# Контент, которому не место в git НИКОГДА (секреты, транскрипты, медиа):
FORBIDDEN_RE='(^|/)\.env($|\.)|\.pem$|(^|/)credentials|(^|/)secrets|(^|/)config\.env$|transcript|\.(mp4|mp3|m4a|wav)$'

blocked=0
while read -r local_ref local_sha remote_ref remote_sha; do
  [[ -z "${local_sha:-}" ]] && continue
  [[ "$local_sha" =~ ^0+$ ]] && continue
  if [[ "$remote_sha" =~ ^0+$ ]]; then
    range_args=("$local_sha" --not --remotes="$REMOTE_NAME")
  else
    range_args=("$remote_sha..$local_sha")
  fi
  # --diff-filter=d исключает чистые удаления: push, который УБИРАЕТ ПД/медиа из git, не блокируется.
  files="$(git log --diff-filter=d --name-only --format= "${range_args[@]}" 2>/dev/null | sort -u)"

  # 1) Секреты / транскрипты / медиа
  if grep -qiE "$FORBIDDEN_RE" <<<"$files"; then
    blocked=1
    echo "⛔ ПД-ГЕЙТ: в коммитах '$local_ref' — секреты / транскрипты / медиа:" >&2
    grep -iE "$FORBIDDEN_RE" <<<"$files" | head -5 | sed 's/^/     • /' >&2
  fi

  # 2) Карточки людей / входящие документы (ПД) — кроме шаблона карточки и индексов
  pd="$(grep -E '^(clients|inbox/docs)/' <<<"$files" \
        | grep -vE '^clients/(README\.md|INDEX\.md|_template/)' \
        | grep -vE '^inbox/docs/README\.md$' || true)"
  if [[ -n "$pd" ]]; then
    blocked=1
    echo "⛔ ПД-ГЕЙТ: в коммитах '$local_ref' — ПД (карточки людей / лиды):" >&2
    head -5 <<<"$pd" | sed 's/^/     • /' >&2
    echo "   ПД едут только в приватный контур, не в этот репо." >&2
  fi
done

[[ "$blocked" == 1 ]] && echo "   Осознанный обход (на свой страх): git push --no-verify" >&2
exit "$blocked"
