#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../scripts/lib.sh"
brew_cask_install 1password "/Applications/1Password.app"