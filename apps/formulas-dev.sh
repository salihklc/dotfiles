#!/usr/bin/env bash
set -euo pipefail
_APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../scripts/lib.sh
source "${_APP_DIR}/../scripts/lib.sh"
# shellcheck source=../scripts/brew-batch.sh
source "${_APP_DIR}/../scripts/brew-batch.sh"
brew_formulas_batch "${DOTFILES_ROOT}/config/formulas-dev.txt"