#!/usr/bin/env bash
set -euo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${DOTFILES_ROOT}/lib/lib.sh"

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ ! -s "${NVM_DIR}/nvm.sh" ]]; then
  warn "nvm missing — run vendor-nvm.sh first"
  exit 1
fi

# shellcheck source=/dev/null
set +u
source "${NVM_DIR}/nvm.sh"
set -u

NODE_MAJOR="${DOTFILES_NODE_MAJOR:-22}"
log "nvm install $NODE_MAJOR && default"
nvm install "$NODE_MAJOR"
nvm alias default "$NODE_MAJOR"
log "node $(node -v)"
