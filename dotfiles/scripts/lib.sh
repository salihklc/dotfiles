#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_ROOT
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

log() { printf '==> %s\n' "$*"; }
warn() { printf '!! %s\n' "$*" >&2; }

backup_if_file() {
  local dest=$1
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mv "$dest" "${dest}.bak.${TIMESTAMP}"
    warn "Backed up $dest"
  fi
}

symlink_config() {
  local rel=$1
  local src_root="${2:-${DOTFILES_ROOT}/home}"
  local src="${src_root}/${rel}"
  local dest="${HOME}/${rel}"
  if [[ ! -f "$src" ]]; then
    warn "Missing source $src — skip"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  backup_if_file "$dest"
  ln -sfn "$src" "$dest"
  log "Linked $dest -> $src"
}
