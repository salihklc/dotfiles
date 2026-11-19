# Personal shell. Copied once → ~/.config/dotfiles-zsh-local.zsh

export PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:${PATH}"

export NVM_DIR="${HOME}/.nvm"
[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"
[[ -s "${NVM_DIR}/bash_completion" ]] && source "${NVM_DIR}/bash_completion"

alias nvmdefault22='nvm alias default 22'
alias nvmdefault20='nvm alias default 20'

command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"
command -v fzf >/dev/null && source <(fzf --zsh)

# Optional IDE CLI on PATH:
# export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:${PATH}"