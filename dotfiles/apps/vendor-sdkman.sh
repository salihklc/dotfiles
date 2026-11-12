#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../scripts/lib.sh"

if [[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]]; then
  log "sdkman already installed"
  exit 0
fi

log "Installing sdkman..."
curl -fsSL "https://get.sdkman.io" | bash
log "sdkman installed — open a new shell or source ~/.sdkman/bin/sdkman-init.sh"
