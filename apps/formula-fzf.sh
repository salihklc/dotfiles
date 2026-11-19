#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../scripts/lib.sh"
PKG=fzf
if brew list "$PKG" &>/dev/null; then log "$PKG already installed"; exit 0; fi
log "brew install $PKG"
brew install "$PKG"
