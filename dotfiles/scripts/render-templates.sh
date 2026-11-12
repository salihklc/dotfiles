#!/usr/bin/env bash
# Expand templates/* with envsubst (COMPANY_DOMAIN and other vars).
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

if ! command -v envsubst >/dev/null; then
  warn "envsubst not found (gettext); install: brew install gettext"
  exit 1
fi

export COMPANY_DOMAIN="${COMPANY_DOMAIN:-company.com}"

# Defaults from example
# shellcheck disable=SC1091
if [[ -f "${DOTFILES_ROOT}/config/company.env.example" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${DOTFILES_ROOT}/config/company.env.example"
  set +a
fi

if [[ -f "${DOTFILES_ROOT}/config/company.env" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${DOTFILES_ROOT}/config/company.env"
  set +a
fi

if [[ -f "${HOME}/.config/dotfiles-company.env" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${HOME}/.config/dotfiles-company.env"
  set +a
fi

export COMPANY_DOMAIN="${COMPANY_DOMAIN:-company.com}"
RENDER_ROOT="${DOTFILES_ROOT}/.rendered"

render_one() {
  local tpl=$1
  local out=$2
  mkdir -p "$(dirname "$out")"
  envsubst '${COMPANY_DOMAIN}' <"$tpl" >"$out"
  log "Rendered $(basename "$out") (COMPANY_DOMAIN=$COMPANY_DOMAIN)"
}

log "Rendering templates → .rendered/"

render_one \
  "${DOTFILES_ROOT}/templates/home/.pi/mcp.json.tpl" \
  "${RENDER_ROOT}/home/.pi/mcp.json"

render_one \
  "${DOTFILES_ROOT}/templates/home/.npmrc.example.tpl" \
  "${RENDER_ROOT}/home/.npmrc.example"

render_one \
  "${DOTFILES_ROOT}/templates/secrets/netrc.example.tpl" \
  "${RENDER_ROOT}/secrets/netrc.example"
