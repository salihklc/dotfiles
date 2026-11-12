#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../scripts/lib.sh"
CASK=keepingyouawake
if brew list --cask "$CASK" &>/dev/null; then log "$CASK already installed"; exit 0; fi
brew install --cask "$CASK"
