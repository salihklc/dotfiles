#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

RENDER="${DOTFILES_ROOT}/.rendered"

"${DOTFILES_ROOT}/scripts/render-templates.sh"

# pi (static + rendered)
symlink_config ".pi/agent/settings.json"
symlink_config ".pi/mcp.json" "${RENDER}/home"

if [[ -f "${RENDER}/home/.pi/mcp.json" ]]; then
  mkdir -p "${HOME}/.pi"
  backup_if_file "${HOME}/.pi/mcp.json"
  ln -sfn "${RENDER}/home/.pi/mcp.json" "${HOME}/.pi/mcp.json"
  log "Linked ${HOME}/.pi/mcp.json"
fi

# herdr
symlink_config ".config/herdr/config.toml"
mkdir -p "${HOME}/.config/herdr"

log "Configs linked (COMPANY_DOMAIN in templates — see config/company.env)"
