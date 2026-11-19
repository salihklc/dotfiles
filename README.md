# dotfiles (public)

Portable Mac setup: Homebrew profiles, nvm, sdkman, Herdr, pi CLI, optional git user include.

**No company MCP, npm scopes, or jarvis payload** — use the separate `jarvis` repo.

## Quick start

```bash
cd ~/lab/dotfiles
cp secrets/dotfiles-secrets.env.example ~/.config/dotfiles-secrets.env

./install.sh dev --shell-hook
source ~/.zshrc
```

## Jarvis

After dotfiles:

```bash
cd ~/lab/jarvis && ./install.sh
```

## Profiles

`./install.sh --list-profiles` → `dev`, `jarvis-pi`, `minimal`

State: `~/.config/dotfiles-install-state/`