#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../scripts/lib.sh"
brew_cask_install podman-desktop "/Applications/Podman Desktop.app"