#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../scripts/lib.sh"

SRC="${DOTFILES_ROOT}/lab/jarvis-pi-lab/bin/jarvis"
DEST="${HOME}/.local/bin/jarvis"

mkdir -p "${HOME}/.local/bin"
if [[ ! -f "$SRC" ]]; then
  warn "Missing $SRC — run install-lab.sh first"
  exit 1
fi
chmod +x "$SRC"
ln -sfn "$SRC" "$DEST"
log "Linked $DEST -> $SRC"
