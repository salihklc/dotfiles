#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../scripts/lib.sh"
CASK=iterm2
if brew list --cask "$CASK" &>/dev/null; then log "$CASK already installed"; exit 0; fi
log "brew install --cask $CASK"
brew install --cask "$CASK"
