#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"

PROFILE="${1:-dev}"
FRESH="${DOTFILES_PROFILE_FRESH:-0}"
STRICT="${DOTFILES_PROFILE_STRICT:-0}"

PROFILE_FILE="${DOTFILES_ROOT}/profiles/${PROFILE}.txt"
STATE_DIR="${HOME}/.config/dotfiles-install-state"
DONE_FILE="${STATE_DIR}/${PROFILE}.done"
FAIL_FILE="${STATE_DIR}/${PROFILE}.failed"

if [[ ! -f "$PROFILE_FILE" ]]; then
  warn "Unknown profile: $PROFILE (missing $PROFILE_FILE)"
  exit 1
fi

mkdir -p "$STATE_DIR"

if [[ "$FRESH" == "1" ]]; then
  rm -f "$DONE_FILE" "$FAIL_FILE"
  log "Profile state cleared: $PROFILE"
fi

profile_step_done() {
  local step=$1
  grep -Fxq "$step" "$DONE_FILE" 2>/dev/null
}

mark_step_done() {
  local step=$1
  grep -Fxq "$step" "$DONE_FILE" 2>/dev/null || echo "$step" >>"$DONE_FILE"
  if [[ -f "$FAIL_FILE" ]]; then
    grep -Fxv "$step" "$FAIL_FILE" >"${FAIL_FILE}.tmp" 2>/dev/null || true
    mv "${FAIL_FILE}.tmp" "$FAIL_FILE" 2>/dev/null || rm -f "$FAIL_FILE"
  fi
}

mark_step_failed() {
  local step=$1
  grep -Fxq "$step" "$FAIL_FILE" 2>/dev/null || echo "$step" >>"$FAIL_FILE"
}

count_profile_steps() {
  local line n=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line//[[:space:]]/}"
    [[ -z "$line" ]] && continue
    n=$((n + 1))
  done <"$PROFILE_FILE"
  echo "$n"
}

TOTAL_STEPS="$(count_profile_steps)"
progress_set_total "$TOTAL_STEPS"
log "Profile: $PROFILE — ${TOTAL_STEPS} steps (resume: ${STATE_DIR})"

load_dotfiles_secrets

failed=0
skipped=0
ran=0

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="${line//[[:space:]]/}"
  [[ -z "$line" ]] && continue

  if profile_step_done "$line"; then
    progress_step_begin "$line"
    progress_step_end "skipped (already installed)"
    skipped=$((skipped + 1))
    continue
  fi

  script="${DOTFILES_ROOT}/apps/${line}.sh"
  if [[ -f "$script" && ! -x "$script" ]]; then
    chmod +x "$script"
  fi
  if [[ ! -f "$script" ]]; then
    progress_step_begin "$line"
    progress_step_end "missing script"
    warn "Skip missing app script: $line"
    continue
  fi

  progress_step_begin "$line"
  ran=$((ran + 1))
  if "$script"; then
    mark_step_done "$line"
    progress_step_end "installed"
  else
    mark_step_failed "$line"
    progress_step_end "FAILED"
    failed=$((failed + 1))
    if [[ "$STRICT" == "1" ]]; then
      exit 1
    fi
  fi
done <"$PROFILE_FILE"

if [[ "$failed" -gt 0 ]]; then
  warn "Profile $PROFILE: $failed failed, $skipped skipped, $ran run — fix and re-run ./install.sh"
  warn "Failed steps: $(tr '\n' ' ' <"$FAIL_FILE" 2>/dev/null || true)"
  warn "Fresh start: DOTFILES_PROFILE_FRESH=1 ./install.sh $PROFILE"
  exit 1
fi

log "Profile $PROFILE complete ($skipped skipped, $ran executed)"