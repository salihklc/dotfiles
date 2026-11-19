#!/usr/bin/env bash
set -euo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../lib/lib.sh
source "${DOTFILES_ROOT}/lib/lib.sh"

MARK_BEGIN="# lab/dotfiles git — begin"
MARK_END="# lab/dotfiles git — end"
TPL="${DOTFILES_ROOT}/templates/home/.gitconfig.dotfiles.tpl"
INCLUDE_PATH="${HOME}/.config/dotfiles-gitconfig"
MAIN="${HOME}/.gitconfig"

load_dotfiles_secrets
export GIT_USER_NAME="${GIT_USER_NAME:-}"
export GIT_USER_EMAIL="${GIT_USER_EMAIL:-}"

if [[ -z "$GIT_USER_NAME" || -z "$GIT_USER_EMAIL" ]]; then
  warn "Skip git user — set GIT_USER_NAME and GIT_USER_EMAIL in ~/.config/dotfiles-secrets.env"
  exit 0
fi

if ! command -v envsubst >/dev/null; then
  warn "envsubst missing"
  exit 1
fi

mkdir -p "${HOME}/.config"
envsubst '${GIT_USER_NAME} ${GIT_USER_EMAIL}' <"$TPL" >"$INCLUDE_PATH"
chmod 600 "$INCLUDE_PATH"

include_block=$(mktemp)
cat >"$include_block" <<EOF
${MARK_BEGIN}
[include]
	path = ${INCLUDE_PATH}
${MARK_END}
EOF

merge_marked_block "$MAIN" "$MARK_BEGIN" "$MARK_END" "$include_block"
rm -f "$include_block"
log "Git config include → $INCLUDE_PATH"
