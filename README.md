# dotfiles (public)

Portable Mac setup. **Entry:** `./setup.sh`.

## Akış (emre/dotfiles gibi)

```text
setup.sh
  ├─ Phase 1  bootstrap     modules/shell/bootstrap.sh  → ~/.config/*.example
  ├─ Phase 2  check-deps    lib/check-deps.sh
  ├─ Phase 3  profile       profiles/NAME.txt → modules/<topic>/<step>.sh
  ├─ Phase 4  shell         modules/shell/hook.sh       → ~/.zshrc
  └─ Phase 5  credentials    modules/credentials/finalize.sh → jarvis netrc/npmrc
```

Jarvis (şirket): `~/lab/jarvis && ./setup.sh` — MCP, payload, `modules/credentials/*`.

## Dizinler

| Dizin | Rol |
|-------|-----|
| `setup.sh` | Tek giriş, fazlar |
| `lib/` | `lib.sh`, `module.sh`, `run-profile.sh`, `brew-batch.sh` |
| `modules/` | Konu başına script (brew, nvm, sdkman, herdr, pi, shell, git, …) |
| `profiles/*.txt` | Modül id listesi (`brew/install`, `nvm/node`, …) |
| `config/` | brew listeleri, ripgreprc, zsh örnekleri |
| `secrets/dotfiles-secrets.env.example` | Tek secrets şablonu (GENAI, NPM, GitLab, git user) → `~/.config/dotfiles-secrets.env` |

### Modül haritası (dev profili)

| Profil satırı | Script |
|---------------|--------|
| `brew/install` | Homebrew |
| `brew/formulas-dev` | `config/formulas-dev.txt` batch |
| `brew/casks-dev` | `config/casks-dev.txt` batch |
| `nvm/install`, `nvm/node` | nvm + Node |
| `sdkman/install`, `sdkman/packages` | Java/Gradle |
| `herdr/install`, `herdr/integrations` | Herdr |
| `pi/cli`, `pi/mcp-extension` | pi CLI (+ extension) |
| `shell/tools` | rg/bat snippet |
| `git/config` | git user include |
| `credentials/finalize` | (setup sonu otomatik) |

Eski profil adları (`brew-ensure`, `vendor-nvm`, …) `lib/module.sh` ile aynı scriptlere map edilir.

## Yeni Mac

```bash
cd ~/lab/dotfiles
./setup.sh dev
# ~/.config/dotfiles-secrets.env + jarvis-company.env doldur
source ~/.zshrc
cd ~/lab/jarvis && ./setup.sh
```

Profil state: `~/.config/dotfiles-install-state/`