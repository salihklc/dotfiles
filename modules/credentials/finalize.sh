#!/usr/bin/env bash
# Merge ~/.netrc / ~/.npmrc jarvis blocks when jarvis repo + secrets + company env exist.
set -euo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${DOTFILES_ROOT}/lib/lib.sh"

find_jarvis_repo() {
  if [[ -n "${JARVIS_REPO_ROOT:-}" && -f "${JARVIS_REPO_ROOT}/modules/credentials/netrc.sh" ]]; then
    echo "${JARVIS_REPO_ROOT}"
    return 0
  fi
  local d="${HOME}/lab/jarvis"
  if [[ -f "${d}/modules/credentials/netrc.sh" ]]; then
    echo "$d"
    return 0
  fi
  return 1
}

JARVIS="$(find_jarvis_repo)" || {
  log "Skip netrc/npmrc — jarvis repo not at ~/lab/jarvis"
  exit 0
}

if [[ ! -f "${HOME}/.config/dotfiles-secrets.env" ]]; then
  warn "Skip netrc/npmrc — missing ~/.config/dotfiles-secrets.env"
  exit 0
fi

if [[ ! -f "${HOME}/.config/jarvis-company.env" ]] && [[ ! -f "${JARVIS}/config/company.env" ]]; then
  warn "Skip netrc/npmrc — set ~/.config/jarvis-company.env (from jarvis/config/company.env.example)"
  exit 0
fi

ensure_brew_in_path 2>/dev/null || true

if ! command -v envsubst >/dev/null; then
  warn "Skip netrc/npmrc — install gettext: brew install gettext"
  exit 0
fi

log "Credentials merge (jarvis marked blocks)"
"${JARVIS}/modules/credentials/netrc.sh" || warn "apply-netrc failed"
# npm needs node on PATH
if [[ -s "${HOME}/.nvm/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.nvm/nvm.sh"
fi
"${JARVIS}/modules/credentials/npmrc.sh" || warn "apply-npmrc failed"