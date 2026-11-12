#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

# pi
symlink_config ".pi/agent/settings.json"
symlink_config ".pi/mcp.json"

# Optional: symlink repo mcp to ~/.pi/mcp.json (pi default location)
if [[ -f "${DOTFILES_ROOT}/home/.pi/mcp.json" ]]; then
  mkdir -p "${HOME}/.pi"
  backup_if_file "${HOME}/.pi/mcp.json"
  ln -sfn "${DOTFILES_ROOT}/home/.pi/mcp.json" "${HOME}/.pi/mcp.json"
  log "Linked ${HOME}/.pi/mcp.json"
fi

# herdr
symlink_config ".config/herdr/config.toml"
mkdir -p "${HOME}/.config/herdr"

log "Configs linked"
