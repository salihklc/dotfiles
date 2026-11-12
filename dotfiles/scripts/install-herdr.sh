#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

if command -v herdr >/dev/null; then
  log "herdr already installed: $(herdr --version 2>/dev/null || herdr --help 2>&1 | head -1)"
  exit 0
fi

log "Installing herdr..."
curl -fsSL https://herdr.dev/install.sh | sh

if ! command -v herdr >/dev/null; then
  warn "herdr not on PATH — add ~/.local/bin to PATH"
  exit 1
fi

log "herdr installed"
