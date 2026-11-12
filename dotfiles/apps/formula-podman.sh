#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../scripts/lib.sh"
for PKG in podman podman-compose; do
  if brew list "$PKG" &>/dev/null; then
    log "$PKG already installed"
    continue
  fi
  log "brew install $PKG"
  brew install "$PKG"
done
