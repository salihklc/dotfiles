#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

PROFILE="${1:-dev}"
PROFILE_FILE="${DOTFILES_ROOT}/profiles/${PROFILE}.txt"

if [[ ! -f "$PROFILE_FILE" ]]; then
  warn "Unknown profile: $PROFILE (missing $PROFILE_FILE)"
  exit 1
fi

log "Profile: $PROFILE"

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="${line//[[:space:]]/}"
  [[ -z "$line" ]] && continue

  script="${DOTFILES_ROOT}/apps/${line}.sh"
  if [[ -f "$script" && ! -x "$script" ]]; then
    chmod +x "$script"
  fi
  if [[ ! -f "$script" ]]; then
    warn "Skip missing app script: $line"
    continue
  fi

  log "── app: $line"
  "$script" || {
    warn "App failed: $line"
    exit 1
  }
done <"$PROFILE_FILE"

log "Profile $PROFILE complete"
