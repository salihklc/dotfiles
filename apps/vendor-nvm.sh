#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../scripts/lib.sh"

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [[ -s "${NVM_DIR}/nvm.sh" ]]; then
  log "nvm already installed"
  exit 0
fi

log "Installing nvm..."
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
log "nvm installed"
