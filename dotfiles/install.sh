#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS="${ROOT}/scripts"

PROFILE="dev"
ONLY_LINK=0
SHELL_HOOK=0
SKIP_APPS=0
LIST_PROFILES=0

usage() {
  cat <<EOF
Usage: $0 [options] [profile]

Options:
  --profile NAME      Profile from profiles/NAME.txt (default: dev)
  --list-profiles     List available profiles
  --only-link         link-configs + install-lab only
  --skip-apps         configs/lab/hooks only (no brew/sdkman/pi)
  --shell-hook        append dotfiles env sources to ~/.zshrc
  -h, --help

Examples:
  $0                    # full dev profile
  $0 jarvis-pi          # Herdr + pi stack only
  $0 --only-link
  $0 --profile dev --shell-hook
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="$2"; shift 2 ;;
    --list-profiles) LIST_PROFILES=1; shift ;;
    --only-link) ONLY_LINK=1; shift ;;
    --skip-apps) SKIP_APPS=1; shift ;;
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

"${SCRIPTS}/check-deps.sh"

if [[ "$ONLY_LINK" -eq 1 ]]; then
  "${ROOT}/apps/link-configs.sh"
  "${SCRIPTS}/install-lab.sh"
  echo "Done (--only-link)."
  exit 0
fi

if [[ "$SKIP_APPS" -eq 0 ]]; then
  "${SCRIPTS}/run-profile.sh" "$PROFILE"
else
  "${ROOT}/apps/link-configs.sh"
  "${SCRIPTS}/install-lab.sh"
fi

[[ "$SHELL_HOOK" -eq 1 ]] && "${SCRIPTS}/install-shell-hook.sh"

cat <<EOF

dotfiles install complete (profile: ${PROFILE}).

Company domain (templates → MCP/GitLab URLs):
  cp ${ROOT}/config/company.env.example ${ROOT}/config/company.env
  # edit COMPANY_DOMAIN=your.company.tld then:
  ${ROOT}/scripts/render-templates.sh && ${ROOT}/apps/link-configs.sh

Secrets (manual, never commit):
  cp ${ROOT}/secrets/dotfiles-secrets.env.example ~/.config/dotfiles-secrets.env
  cp ${ROOT}/.rendered/secrets/netrc.example ~/.netrc && chmod 600 ~/.netrc

Next:
  source ~/.zshrc
  pi auth check --provider mlplatform
  cd <your-repo> && jarvis

Repo: ${ROOT}
EOF
