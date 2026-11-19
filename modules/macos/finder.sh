#!/usr/bin/env bash
# Optional Finder defaults (emre/dotfiles preferences/finder).
set -euo pipefail
# shellcheck source=../scripts/lib.sh
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${DOTFILES_ROOT}/lib/lib.sh"

[[ "$(uname -s)" == "Darwin" ]] || exit 0

defaults write com.apple.finder NewWindowTarget -string PfHm
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"
killall Finder 2>/dev/null || true
log "Finder: new windows open at home"