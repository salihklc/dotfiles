#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../scripts/lib.sh"

if command -v claude >/dev/null; then
  log "claude-code: $(claude --version 2>/dev/null || echo ok)"
  exit 0
fi

if ! command -v npm >/dev/null; then
  warn "npm not found — install Node (vendor-nvm-node) first"
  exit 1
fi

log "Installing Claude Code CLI (@anthropic-ai/claude-code)..."
if npm install -g @anthropic-ai/claude-code; then
  if command -v claude >/dev/null; then
    log "claude-code installed"
    exit 0
  fi
fi

warn "claude not on PATH — see https://docs.anthropic.com/en/docs/claude-code"
exit 1