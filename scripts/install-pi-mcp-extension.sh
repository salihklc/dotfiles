#!/usr/bin/env bash
# pi MCP client extension (reads ~/.pi/mcp.json)
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

PKG="npm:pi-mcp-extension"

if ! command -v pi >/dev/null; then
  warn "pi not on PATH — skip $PKG (run vendor-pi-cli first)"
  exit 0
fi

log "pi install $PKG"
if pi install "$PKG"; then
  log "pi MCP extension installed"
else
  warn "Failed: $PKG"
  exit 1
fi

pi update --extensions 2>/dev/null || pi update pi 2>/dev/null || true
