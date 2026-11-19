#!/usr/bin/env bash
set -euo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${DOTFILES_ROOT}/lib/lib.sh"
for PKG in podman podman-compose; do
  if brew list "$PKG" &>/dev/null; then
    log "$PKG already installed"
    continue
  fi
  log "brew install $PKG"
  brew install "$PKG"
done
