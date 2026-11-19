#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../scripts/lib.sh
source "$(dirname "$0")/../scripts/lib.sh"

if command -v brew >/dev/null; then
  log "Homebrew: $(brew --version | head -1)"
  exit 0
fi

warn "Homebrew not found — install from https://brew.sh then re-run this profile"
exit 1
