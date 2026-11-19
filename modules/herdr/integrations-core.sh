#!/usr/bin/env bash
set -euo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../lib/lib.sh
source "${DOTFILES_ROOT}/lib/lib.sh"

if ! command -v herdr >/dev/null; then
  warn "herdr not on PATH — skip integrations"
  exit 0
fi

log "herdr integration install pi"
herdr integration install pi

log "Integration status:"
herdr integration status 2>&1 | rg '^(pi|cursor):' || herdr integration status
