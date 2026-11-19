#!/usr/bin/env bash
set -euo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${DOTFILES_ROOT}/lib/lib.sh"

if [[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]]; then
  log "sdkman already installed"
  exit 0
fi

log "Installing sdkman..."
curl -fsSL "https://get.sdkman.io" | bash
log "sdkman installed — open a new shell or source ~/.sdkman/bin/sdkman-init.sh"
