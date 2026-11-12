#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

if ! command -v herdr >/dev/null; then
  warn "herdr not on PATH — skip integrations"
  exit 0
fi

log "herdr integration install pi"
herdr integration install pi

log "Integration status:"
herdr integration status 2>&1 | rg '^(pi|cursor):' || herdr integration status
