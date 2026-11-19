#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

PI_PKG="@earendil-works/pi-coding-agent"

if command -v pi >/dev/null; then
  log "pi already on PATH: $(pi --version 2>/dev/null || true)"
  exit 0
fi

if ! command -v npm >/dev/null; then
  warn "npm not found — install Node first"
  exit 1
fi

log "Installing $PI_PKG globally..."
npm install -g "$PI_PKG"

log "pi installed: $(pi --version 2>/dev/null || true)"
