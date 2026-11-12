#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

missing=0
need() {
  if ! command -v "$1" >/dev/null; then
    warn "Missing: $1"
    missing=1
  fi
}

need curl
need jq

if ! command -v node >/dev/null; then
  warn "Missing: node (install nvm + Node 20+)"
  missing=1
else
  log "node $(node -v)"
fi

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

log "Dependencies OK"
