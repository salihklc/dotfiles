#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_ROOT
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

log() { printf '==> %s\n' "$*"; }
warn() { printf '!! %s\n' "$*" >&2; }

DOTFILES_INSTALL_TOTAL=0
DOTFILES_INSTALL_IDX=0

progress_set_total() {
  DOTFILES_INSTALL_TOTAL=$1
  DOTFILES_INSTALL_IDX=0
  DOTFILES_INSTALL_LABEL=""
}

progress_step_begin() {
  DOTFILES_INSTALL_IDX=$((DOTFILES_INSTALL_IDX + 1))
  DOTFILES_INSTALL_LABEL=$1
  printf '==> [%d/%d] %s …\n' "$DOTFILES_INSTALL_IDX" "$DOTFILES_INSTALL_TOTAL" "$DOTFILES_INSTALL_LABEL"
}

progress_step_end() {
  local status=${1:-done}
  printf '==> [%d/%d] %s — %s\n' "$DOTFILES_INSTALL_IDX" "$DOTFILES_INSTALL_TOTAL" "$DOTFILES_INSTALL_LABEL" "$status"
}

load_dotfiles_secrets() {
  if [[ -f "${HOME}/.config/dotfiles-secrets.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "${HOME}/.config/dotfiles-secrets.env"
    set +a
  fi
}

merge_marked_block() {
  local target=$1 begin=$2 end=$3 block_file=$4
  mkdir -p "$(dirname "$target")"
  touch "$target"
  local tmp stripped
  tmp=$(mktemp)
  stripped=$(mktemp)
  if grep -Fq "$begin" "$target"; then
    awk -v b="$begin" -v e="$end" '
      index($0, b) { skip = 1; next }
      index($0, e) { skip = 0; next }
      !skip { print }
    ' "$target" >"$stripped"
    cat "$stripped" >"$tmp"
  else
    cp "$target" "$tmp"
  fi
  {
    cat "$tmp"
    [[ -s "$tmp" ]] && [[ "$(tail -c1 "$tmp" 2>/dev/null)" != "" ]] && echo
    cat "$block_file"
  } >"${target}.new"
  mv "${target}.new" "$target"
  rm -f "$tmp" "$stripped"
}

backup_if_file() {
  local dest=$1
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mv "$dest" "${dest}.bak.${TIMESTAMP}"
    warn "Backed up $dest"
  fi
}

# Install cask if missing; adopt existing .app if brew has no record (manual install).
brew_cask_install() {
  local cask=$1
  local adopt_app=${2:-}
  if brew list --cask "$cask" &>/dev/null; then
    log "Cask $cask already installed (brew)"
    return 0
  fi
  if [[ -n "$adopt_app" && -d "$adopt_app" ]]; then
    log "Cask $cask: adopting $adopt_app"
    if brew install --cask --adopt "$cask" 2>/dev/null; then
      return 0
    fi
    warn "Cask $cask: app present, brew adopt skipped — continuing"
    return 0
  fi
  log "brew install --cask $cask"
  brew install --cask "$cask"
}

ensure_dotfiles_config_files() {
  mkdir -p "${HOME}/.config"
  local secrets="${HOME}/.config/dotfiles-secrets.env"
  local secrets_ex="${DOTFILES_ROOT}/secrets/dotfiles-secrets.env.example"
  if [[ ! -f "$secrets" && -f "$secrets_ex" ]]; then
    cp "$secrets_ex" "$secrets"
    warn "Created $secrets — fill secrets (never commit)"
  fi
}