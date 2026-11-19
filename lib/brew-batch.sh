#!/usr/bin/env bash
# Batch brew installs to reduce macOS admin password prompts.
set -euo pipefail
_BB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${_BB_DIR}/lib.sh"

sudo_cache_once() {
  [[ -t 0 ]] || return 0
  command -v sudo >/dev/null || return 0
  log "Admin izni (tek sefer — sonraki cask/formula batch için)"
  sudo -v
}

brew_formulas_batch() {
  local list_file=$1
  local -a to_install=()
  local pkg
  while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    [[ "$pkg" =~ ^[[:space:]]*# ]] && continue
    pkg="${pkg%%#*}"
    pkg="${pkg//[[:space:]]/}"
    [[ -z "$pkg" ]] && continue
    if brew list "$pkg" &>/dev/null; then
      log "formula $pkg already installed"
    else
      to_install+=("$pkg")
    fi
  done <"$list_file"
  if [[ ${#to_install[@]} -eq 0 ]]; then
    return 0
  fi
  sudo_cache_once
  log "brew install ${to_install[*]}"
  brew install "${to_install[@]}"
}

brew_casks_batch() {
  local list_file=$1
  local -a to_install=()
  local line cask adopt_path
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    [[ -z "$line" ]] && continue
    cask="${line%%|*}"
    adopt_path=""
    if [[ "$line" == *"|"* ]]; then
      adopt_path="${line#*|}"
    fi
    if brew list --cask "$cask" &>/dev/null; then
      log "cask $cask already installed"
      continue
    fi
    if [[ -n "$adopt_path" && -d "$adopt_path" ]]; then
      log "cask $cask: adopt $(basename "$adopt_path")"
      if brew install --cask --adopt "$cask" 2>/dev/null; then
        continue
      fi
      warn "cask $cask: adopt failed"
      warn "cask $cask: $(basename "$adopt_path") present — OK without brew cask record"
      continue
    fi
    to_install+=("$cask")
  done <"$list_file"
  if [[ ${#to_install[@]} -eq 0 ]]; then
    return 0
  fi
  sudo_cache_once
  log "brew install --cask ${to_install[*]}"
  brew install --cask "${to_install[@]}"
}