#!/usr/bin/env bash
# Upgrade apps from profiles/NAME.txt
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

PROFILE="${1:-dev}"
LIST_FILE="${DOTFILES_ROOT}/profiles/${PROFILE}.txt"

run_app_update() {
  local name=$1
  case "$name" in
    brew-ensure)
      command -v brew >/dev/null && brew update >/dev/null 2>&1 || true
      ;;
    formula-*|cask-*)
      local pkg="${name#formula-}"
      pkg="${pkg#cask-}"
      if command -v brew >/dev/null && brew list "$pkg" &>/dev/null 2>&1; then
        brew upgrade "$pkg" 2>/dev/null || true
      fi
      ;;
    vendor-pi-cli)
      command -v npm >/dev/null && npm update -g @earendil-works/pi-coding-agent 2>/dev/null || true
      command -v pi >/dev/null && pi update --extensions 2>/dev/null || true
      ;;
    vendor-herdr)
      command -v herdr >/dev/null && curl -fsSL https://herdr.dev/install.sh | sh || true
      ;;
    *)
      local script="${DOTFILES_ROOT}/apps/${name}.sh"
      [[ -x "$script" ]] && "$script" || true
      ;;
  esac
}

[[ -f "$LIST_FILE" ]] || { warn "No profile: $LIST_FILE"; exit 1; }
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"
  [[ -z "$line" ]] && continue
  run_app_update "$line"
done <"$LIST_FILE"