#!/usr/bin/env bash
set -euo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../lib/lib.sh
source "${DOTFILES_ROOT}/lib/lib.sh"

MARKER="# lab/dotfiles"
ZSHRC="${HOME}/.zshrc"

"${DOTFILES_ROOT}/modules/shell/bootstrap.sh"
"${DOTFILES_ROOT}/modules/shell/tools.sh" 2>/dev/null || true

if [[ ! -f "$ZSHRC" ]]; then
  touch "$ZSHRC"
  log "Created empty $ZSHRC"
elif grep -q "$MARKER" "$ZSHRC" 2>/dev/null; then
  log "Shell hook already present in $ZSHRC"
  exit 0
fi

cat >>"$ZSHRC" <<'EOF'

# lab/dotfiles
[[ -f "${HOME}/.config/dotfiles-zsh-local.zsh" ]] && source "${HOME}/.config/dotfiles-zsh-local.zsh"
[[ -f "${HOME}/.config/dotfiles-secrets.env" ]] && source "${HOME}/.config/dotfiles-secrets.env"
[[ -f "${HOME}/.config/jarvis-pi.env" ]] && source "${HOME}/.config/jarvis-pi.env"
[[ -f "${HOME}/.config/dotfiles-zsh-company.zsh" ]] && source "${HOME}/.config/dotfiles-zsh-company.zsh"

export SDKMAN_DIR="${HOME}/.sdkman"
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
[[ -f "${HOME}/.config/dotfiles-zsh-sdk-aliases.zsh" ]] && source "${HOME}/.config/dotfiles-zsh-sdk-aliases.zsh"

[[ -f "${HOME}/.config/dotfiles-shell-tools.zsh" ]] && source "${HOME}/.config/dotfiles-shell-tools.zsh"
EOF

log "Appended dotfiles hook block to $ZSHRC"