#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

MARKER="# lab/dotfiles"
ZSHRC="${HOME}/.zshrc"
SECRETS_FILE="${HOME}/.config/dotfiles-secrets.env"
ENV_FILE="${HOME}/.config/jarvis-pi.env"

ensure_dotfiles_config_files

if grep -q "$MARKER" "$ZSHRC" 2>/dev/null; then
  log "Shell hook already present (jarvis-pi.env refreshed)"
  exit 0
fi

cat >>"$ZSHRC" <<EOF

$MARKER
export PATH="\${HOME}/.local/bin:/opt/homebrew/bin:\${PATH}"
[ -s "\${HOME}/.nvm/nvm.sh" ] && . "\${HOME}/.nvm/nvm.sh"
export JARVIS_PI_KIT="\${JARVIS_PI_KIT:-\$HOME/Documents/jarvis}"
[[ -f "\$HOME/.config/dotfiles-secrets.env" ]] && source "\$HOME/.config/dotfiles-secrets.env"
[[ -f "\$HOME/.config/jarvis-pi.env" ]] && source "\$HOME/.config/jarvis-pi.env"
EOF

log "Appended dotfiles env sources to $ZSHRC"
