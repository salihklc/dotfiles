#!/usr/bin/env bash
set -euo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "${DOTFILES_ROOT}/lib/lib.sh"
brew_cask_install maccy "/Applications/Maccy.app"