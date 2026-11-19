#!/usr/bin/env bash
# First-run: copy examples → ~/.config (never overwrite existing).
set -euo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${DOTFILES_ROOT}/lib/lib.sh"

mkdir -p "${HOME}/.config"
chmod 700 "${HOME}/.config" 2>/dev/null || true

_seed_if_missing() {
  local example=$1 target=$2
  [[ -f "$example" ]] || return 0
  if [[ ! -f "$target" ]]; then
    cp "$example" "$target"
    chmod 600 "$target" 2>/dev/null || true
    log "Created $target (edit before use)"
  fi
}

_seed_if_missing \
  "${DOTFILES_ROOT}/secrets/dotfiles-secrets.env.example" \
  "${HOME}/.config/dotfiles-secrets.env"

_seed_if_missing \
  "${DOTFILES_ROOT}/config/dotfiles-zsh-local.example.zsh" \
  "${HOME}/.config/dotfiles-zsh-local.zsh"

_seed_if_missing \
  "${DOTFILES_ROOT}/config/dotfiles-zsh-sdk-aliases.example.zsh" \
  "${HOME}/.config/dotfiles-zsh-sdk-aliases.zsh"

log "Local config bootstrap done — fill ~/.config/dotfiles-secrets.env"
log "Jarvis: ~/.config/jarvis-pi.env + company env via ~/lab/jarvis ./setup.sh"