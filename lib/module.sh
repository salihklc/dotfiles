#!/usr/bin/env bash
# Resolve profile step id → executable module script (legacy ids supported).

dotfiles_module_script() {
  local id=$1
  local mapped path root="${DOTFILES_ROOT}"

  case "$id" in
    brew-ensure) mapped="brew/install" ;;
    formulas-dev) mapped="brew/formulas-dev" ;;
    casks-dev) mapped="brew/casks-dev" ;;
    vendor-nvm) mapped="nvm/install" ;;
    vendor-nvm-node) mapped="nvm/node" ;;
    vendor-sdkman) mapped="sdkman/install" ;;
    sdkman-packages) mapped="sdkman/packages" ;;
    vendor-herdr) mapped="herdr/install" ;;
    vendor-herdr-integrations) mapped="herdr/integrations" ;;
    vendor-pi-cli) mapped="pi/cli" ;;
    install-pi-mcp-extension) mapped="pi/mcp-extension" ;;
    vendor-cursor-agent) mapped="cursor/install" ;;
    vendor-claude-code) mapped="claude/install" ;;
    apply-gitconfig) mapped="git/config" ;;
    link-shell-tools) mapped="shell/tools" ;;
    macos-finder-prefs) mapped="macos/finder" ;;
    formula-*)
      mapped="brew/formulas/${id#formula-}" ;;
    cask-*)
      mapped="brew/casks/${id#cask-}" ;;
    */*)
      mapped="$id" ;;
    *)
      mapped="$id" ;;
  esac

  path="${root}/modules/${mapped}.sh"
  if [[ -f "$path" ]]; then
    echo "$path"
    return 0
  fi
  path="${root}/apps/${id}.sh"
  if [[ -f "$path" ]]; then
    echo "$path"
    return 0
  fi
  return 1
}