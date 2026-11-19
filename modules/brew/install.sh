#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../scripts/lib.sh
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${DOTFILES_ROOT}/lib/lib.sh"

ensure_brew_in_path && {
  log "Homebrew: $(brew --version | head -1)"
  homebrew_opt_out_analytics
  exit 0
}

if [[ "${DOTFILES_INSTALL_BREW:-}" != "1" ]]; then
  warn "Homebrew not found — set DOTFILES_INSTALL_BREW=1 to install, or https://brew.sh"
  exit 1
fi

if [[ ! -t 0 ]]; then
  warn "Homebrew install needs a TTY — run interactively or install brew manually"
  exit 1
fi

log "Installing Homebrew (NONINTERACTIVE)"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ensure_brew_in_path || exit 1
homebrew_opt_out_analytics
log "Homebrew: $(brew --version | head -1)"