#!/usr/bin/env bash
# ripgrep/bat config paths (fzf/zoxide → dotfiles-zsh-local.zsh).
set -euo pipefail
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${DOTFILES_ROOT}/lib/lib.sh"

MARK_BEGIN="# lab/dotfiles shell-tools"
MARK_END="# end lab/dotfiles shell-tools"
ZSH_SNIPPET="${HOME}/.config/dotfiles-shell-tools.zsh"

mkdir -p "${HOME}/.config"

export RIPGREP_CONFIG_PATH="${DOTFILES_ROOT}/config/ripgreprc"
export BAT_CONFIG_PATH="${DOTFILES_ROOT}/config/batrc"

cat >"$ZSH_SNIPPET" <<EOF
$MARK_BEGIN
export DOTFILES_ROOT="\${DOTFILES_ROOT:-${DOTFILES_ROOT}}"
export RIPGREP_CONFIG_PATH="\${DOTFILES_ROOT}/config/ripgreprc"
export BAT_CONFIG_PATH="\${DOTFILES_ROOT}/config/batrc"
# Fewer surprise brew upgrades during profile installs
export HOMEBREW_NO_AUTO_UPDATE="\${HOMEBREW_NO_AUTO_UPDATE:-1}"
$MARK_END
EOF

log "Wrote ${ZSH_SNIPPET} (ripgrep/bat; fzf/zoxide → dotfiles-zsh-local.zsh)"
log "ripgrep/bat configs → ${DOTFILES_ROOT}/config"