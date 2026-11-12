#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

if ! command -v pi >/dev/null; then
  warn "pi not on PATH"
  exit 1
fi

PACKAGES=(
  "npm:@tglobal/pi-mlplatform-models"
  "npm:pi-undo-tree"
  "npm:pi-agents-talk-to-each-other"
)

for pkg in "${PACKAGES[@]}"; do
  log "pi install $pkg"
  if ! pi install "$pkg"; then
    warn "Failed: $pkg (check VPN / npm registry for @tglobal)"
    exit 1
  fi
done

log "Refreshing model catalog..."
pi update --extensions 2>/dev/null || pi update pi 2>/dev/null || true

log "pi packages OK"
