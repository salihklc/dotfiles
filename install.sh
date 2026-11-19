#!/usr/bin/env bash
# Public dotfiles: brew, nvm, herdr, pi-cli — no company MCP / jarvis payload.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS="${ROOT}/scripts"

PROFILE="dev"
ONLY_LINK=0
SHELL_HOOK=0
SKIP_APPS=0
LIST_PROFILES=0
UPDATE_APPS=0
PROFILE_FRESH=0
PROFILE_STRICT=0

usage() {
  cat <<EOF
Usage: $0 [options] [profile]

Options:
  --profile NAME        Profile from profiles/NAME.txt (default: dev)
  --list-profiles       List available profiles
  --only-link           apply-gitconfig only (no brew)
  --update              upgrade apps from profile
  --skip-apps           gitconfig hook only
  --profile-fresh       re-run all profile app steps
  --profile-strict      stop on first app failure
  --shell-hook          append dotfiles env sources to ~/.zshrc
  -h, --help

Jarvis (company): clone jarvis repo → ./install.sh  (needs this dotfiles checkout)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="$2"; shift 2 ;;
    --jarvis-alias) shift 2 ;;
    --list-profiles) LIST_PROFILES=1; shift ;;
    --only-link) ONLY_LINK=1; shift ;;
    --update) UPDATE_APPS=1; shift ;;
    --skip-apps) SKIP_APPS=1; shift ;;
    --profile-fresh) PROFILE_FRESH=1; shift ;;
    --profile-strict) PROFILE_STRICT=1; shift ;;
    --shell-hook) SHELL_HOOK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Unknown: $1" >&2; usage; exit 1 ;;
    *) PROFILE="$1"; shift ;;
  esac
done

if [[ "$LIST_PROFILES" -eq 1 ]]; then
  ls "${ROOT}/profiles/"*.txt 2>/dev/null | xargs -n1 basename | sed 's/.txt$//'
  exit 0
fi

# shellcheck source=lib.sh
source "${SCRIPTS}/lib.sh"
load_dotfiles_secrets
ensure_dotfiles_config_files

progress_set_total 1
progress_step_begin "check-deps"
"${SCRIPTS}/check-deps.sh"
progress_step_end "installed"

if [[ "$ONLY_LINK" -eq 1 || "$SKIP_APPS" -eq 1 ]]; then
  "${ROOT}/apps/apply-gitconfig.sh"
  [[ "$SHELL_HOOK" -eq 1 ]] && "${SCRIPTS}/install-shell-hook.sh"
  echo "Done (--only-link)."
  exit 0
fi

if [[ -t 0 ]] && command -v sudo >/dev/null; then
  sudo -v 2>/dev/null || true
  (
    while true; do
      sleep 50
      sudo -n true 2>/dev/null || sudo -v 2>/dev/null || true
    done
  ) &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill "${SUDO_KEEPALIVE_PID:-}" 2>/dev/null' EXIT
fi

export DOTFILES_PROFILE_FRESH="$PROFILE_FRESH"
export DOTFILES_PROFILE_STRICT="$PROFILE_STRICT"
PROFILE_PARTIAL=0
"${SCRIPTS}/run-profile.sh" "$PROFILE" || PROFILE_PARTIAL=1

if [[ "$UPDATE_APPS" -eq 1 ]]; then
  "${SCRIPTS}/update-apps.sh" "$PROFILE" 2>/dev/null || true
fi

[[ "$SHELL_HOOK" -eq 1 ]] && "${SCRIPTS}/install-shell-hook.sh"

if [[ "${PROFILE_PARTIAL:-0}" -eq 1 ]]; then
  warn "Profil tamamlanmadı: ./install.sh $PROFILE"
  exit 1
fi

cat <<EOF

dotfiles install complete (profile: ${PROFILE}).

Secrets (manual):
  cp ${ROOT}/secrets/dotfiles-secrets.env.example ~/.config/dotfiles-secrets.env

Jarvis (company GitLab repo):
  cd ~/lab/jarvis && ./install.sh

Repo: ${ROOT}
EOF