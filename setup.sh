#!/usr/bin/env bash
# dotfiles setup — emre-style phases, modular under modules/
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
LIB="${ROOT}/lib"

PROFILE="dev"
ONLY_LINK=0
NO_SHELL_HOOK=0
SKIP_APPS=0
LIST_PROFILES=0
UPDATE_APPS=0
PROFILE_FRESH=0
PROFILE_STRICT=0

usage() {
  cat <<EOF
Usage: $0 [options] [profile]

Phases (default full run):
  1. bootstrap   ~/.config examples
  2. check-deps  curl, jq, node hint
  3. profile     modules/* from profiles/NAME.txt
  4. shell       ~/.zshrc hook
  5. credentials jarvis netrc/npmrc blocks (if ~/lab/jarvis)

Options:
  --profile NAME   profiles/NAME.txt (default: dev)
  --list-profiles
  --only-link      git/config + shell hook only
  --skip-apps      same as --only-link without profile
  --no-shell-hook
  --profile-fresh  re-run all profile steps
  --update         upgrade pass
  -h, --help

Jarvis (company): ~/lab/jarvis && ./setup.sh
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
    --no-shell-hook) NO_SHELL_HOOK=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Unknown: $1" >&2; usage; exit 1 ;;
    *) PROFILE="$1"; shift ;;
  esac
done

if [[ "$LIST_PROFILES" -eq 1 ]]; then
  ls "${ROOT}/profiles/"*.txt 2>/dev/null | xargs -n1 basename | sed 's/.txt$//'
  exit 0
fi

# shellcheck source=lib/lib.sh
source "${LIB}/lib.sh"

log "Phase 1 — bootstrap"
ensure_brew_in_path 2>/dev/null || true
load_dotfiles_secrets
ensure_dotfiles_config_files

log "Phase 2 — check-deps"
progress_set_total 1
progress_step_begin "check-deps"
"${LIB}/check-deps.sh"
progress_step_end "installed"

if [[ "$ONLY_LINK" -eq 1 || "$SKIP_APPS" -eq 1 ]]; then
  "${ROOT}/modules/git/config.sh"
  [[ "$NO_SHELL_HOOK" -eq 0 ]] && "${ROOT}/modules/shell/hook.sh"
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

log "Phase 3 — profile ($PROFILE)"
export DOTFILES_PROFILE_FRESH="$PROFILE_FRESH"
export DOTFILES_PROFILE_STRICT="$PROFILE_STRICT"
PROFILE_PARTIAL=0
"${LIB}/run-profile.sh" "$PROFILE" || PROFILE_PARTIAL=1

if [[ "$UPDATE_APPS" -eq 1 ]]; then
  "${LIB}/update-apps.sh" "$PROFILE" 2>/dev/null || true
fi

log "Phase 4 — shell"
if [[ "$NO_SHELL_HOOK" -eq 0 ]]; then
  "${ROOT}/modules/shell/hook.sh"
else
  warn "Skipped shell hook (--no-shell-hook)"
fi

log "Phase 5 — credentials"
"${ROOT}/modules/credentials/finalize.sh" || true

if [[ "${PROFILE_PARTIAL:-0}" -eq 1 ]]; then
  warn "Profil tamamlanmadı: ./setup.sh $PROFILE"
  exit 1
fi

cat <<EOF

dotfiles setup complete (profile: ${PROFILE}).
  source ~/.zshrc

Jarvis: cd ~/lab/jarvis && ./setup.sh
EOF