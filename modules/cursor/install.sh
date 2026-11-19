#!/usr/bin/env bash
set -euo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${DOTFILES_ROOT}/lib/lib.sh"

if command -v cursor-agent >/dev/null; then
  log "cursor-agent: $(cursor-agent --version 2>/dev/null || echo ok)"
  exit 0
fi

log "Installing cursor-agent CLI..."
if curl -fsSL https://cursor.com/install | bash; then
  if command -v cursor-agent >/dev/null; then
    log "cursor-agent installed"
    exit 0
  fi
fi

warn "cursor-agent not on PATH — install Cursor (cask-cursor) and CLI from Cursor docs, then re-run"
