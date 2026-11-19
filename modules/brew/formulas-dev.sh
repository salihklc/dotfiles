#!/usr/bin/env bash
set -euo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${DOTFILES_ROOT}/lib/lib.sh"
source "${DOTFILES_ROOT}/lib/brew-batch.sh"
brew_formulas_batch "${DOTFILES_ROOT}/config/formulas-dev.txt"
