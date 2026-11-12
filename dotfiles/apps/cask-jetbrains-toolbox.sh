#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../scripts/lib.sh"
CASK=jetbrains-toolbox
if brew list --cask "$CASK" &>/dev/null; then log "$CASK already installed"; exit 0; fi
brew install --cask "$CASK"
log "Install IDEs from Toolbox: IntelliJ IDEA (Release), GoLand, DataGrip — ~/Applications/ for IDEA"
