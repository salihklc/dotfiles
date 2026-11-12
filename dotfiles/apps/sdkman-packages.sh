#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../scripts/lib.sh"

INIT="${HOME}/.sdkman/bin/sdkman-init.sh"
PKG_FILE="${DOTFILES_ROOT}/config/sdkman-packages.txt"

if [[ ! -s "$INIT" ]]; then
  warn "sdkman missing — run vendor-sdkman.sh first"
  exit 1
fi

# shellcheck source=/dev/null
set +u
source "$INIT"
set +e
export SDKMAN_NONINTERACTIVE=true

if [[ ! -f "$PKG_FILE" ]]; then
  warn "Missing $PKG_FILE"
  exit 1
fi

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  line="${line%%#*}"
  line="${line//[[:space:]]+/ }"
  line="${line#"${line%%[![:space:]]*}"}"
  [[ -z "$line" ]] && continue

  read -r candidate version role <<<"$line"
  if [[ -z "$candidate" || -z "$version" ]]; then
    warn "Invalid line: $line"
    continue
  fi

  log "sdkman: install $candidate $version"
  if ! sdk install "$candidate" "$version"; then
    warn "sdk install failed (offline/VPN?): $candidate $version — fix and re-run"
    continue
  fi

  if [[ "${role:-}" == "default" ]]; then
    sdk default "$candidate" "$version"
    log "sdkman: default $candidate -> $version"
  fi
done <"$PKG_FILE"

set -e
log "sdkman packages done"
