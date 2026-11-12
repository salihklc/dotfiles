#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

MARKER="# lab/dotfiles"
ZSHRC="${HOME}/.zshrc"
SECRETS_FILE="${HOME}/.config/dotfiles-secrets.env"
ENV_FILE="${HOME}/.config/jarvis-pi.env"

if grep -q "$MARKER" "$ZSHRC" 2>/dev/null; then
  log "Shell hook already present"
  exit 0
fi

if [[ ! -f "$SECRETS_FILE" ]]; then
  mkdir -p "${HOME}/.config"
  cp "${DOTFILES_ROOT}/secrets/dotfiles-secrets.env.example" "$SECRETS_FILE"
  warn "Created $SECRETS_FILE — fill secrets (never commit)"
fi

if [[ ! -f "$ENV_FILE" ]]; then
  cp "${DOTFILES_ROOT}/env/jarvis-pi.env.example" "$ENV_FILE"
  warn "Created $ENV_FILE"
fi

cat >>"$ZSHRC" <<EOF

$MARKER
export JARVIS_PI_KIT="\${JARVIS_PI_KIT:-\$HOME/lab/jarvis-pi-lab}"
[[ -f "\$HOME/.config/dotfiles-secrets.env" ]] && source "\$HOME/.config/dotfiles-secrets.env"
[[ -f "\$HOME/.config/jarvis-pi.env" ]] && source "\$HOME/.config/jarvis-pi.env"
EOF

log "Appended dotfiles env sources to $ZSHRC"
