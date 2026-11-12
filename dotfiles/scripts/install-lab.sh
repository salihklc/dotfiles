#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

LAB_SRC="${DOTFILES_ROOT}/lab/jarvis-pi-lab"
LAB_DEST="${HOME}/lab/jarvis-pi-lab"

mkdir -p "${HOME}/lab"

if [[ -e "$LAB_DEST" && ! -L "$LAB_DEST" ]]; then
  if [[ -d "$LAB_DEST" ]]; then
    warn "$LAB_DEST exists as directory — leaving in place (copy updates manually or remove first)"
    rsync -a "$LAB_SRC/" "$LAB_DEST/" 2>/dev/null || cp -R "$LAB_SRC/." "$LAB_DEST/"
    log "Synced lab files into $LAB_DEST"
    exit 0
  fi
fi

ln -sfn "$LAB_SRC" "$LAB_DEST"
log "Linked $LAB_DEST -> $LAB_SRC"
