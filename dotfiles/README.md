# dotfiles (`~/lab/dotfiles`)

Portable Mac setup: **Homebrew apps**, **sdkman**, **nvm**, **Herdr + pi**, shell secrets şablonları. Eski `jarvis-pi-dotfiles` buraya taşındı.

## Quick start (yeni Mac)

```bash
cd ~/lab/dotfiles
cp config/company.env.example config/company.env   # COMPANY_DOMAIN=...
cp secrets/dotfiles-secrets.env.example ~/.config/dotfiles-secrets.env
./install.sh --shell-hook           # isteğe bağlı: .zshrc hook
./install.sh                        # profile: dev → render + link configs
cp .rendered/secrets/netrc.example ~/.netrc && chmod 600 ~/.netrc
```

Profiller: `./install.sh --list-profiles` → `dev`, `jarvis-pi`, `minimal`.

**jarvis (multi-agent):** `link-jarvis-cli` → `~/.local/bin/jarvis`. Herdr açıkken proje içinde `jarvis` (git kökü = workspace cwd).

## `install.sh`

| Flag | Açıklama |
|------|-----------|
| `--profile NAME` | `profiles/NAME.txt` sırasıyla `apps/*.sh` |
| `--only-link` | sadece pi/herdr symlink + lab |
| `--skip-apps` | link + lab (brew/sdk yok) |
| `--shell-hook` | `~/.config/dotfiles-secrets.env` + `jarvis-pi.env` → `.zshrc` |

## App scriptleri (`apps/`)

Her satır bir uygulama/kurulum adımı. `profiles/dev.txt` örneği:

| Script | Ne yapar |
|--------|-----------|
| `brew-ensure.sh` | Homebrew varlık kontrolü |
| `formula-*` | git, jq, fzf, podman |
| `cask-*` | iTerm2, VS Code, Cursor, Maccy, KeepingYouAwake, 1Password, JetBrains Toolbox, Podman Desktop |
| `vendor-sdkman.sh` | sdkman kurulumu |
| `sdkman-packages.sh` | `config/sdkman-packages.txt` (java/gradle/maven) |
| `vendor-nvm.sh` / `vendor-nvm-node.sh` | nvm + Node 22 default |
| `vendor-herdr.sh` | Herdr installer |
| `vendor-pi-cli.sh` | global pi |
| `vendor-pi-packages.sh` | mlplatform pi packages |
| `vendor-cursor-agent.sh` | cursor-agent CLI |
| `link-configs.sh` | `home/.pi/*`, herdr config symlink |
| `install-lab.sh` | `~/lab/jarvis-pi-lab` symlink |

JetBrains IDE’ler (IntelliJ Release, GoLand, DataGrip): Toolbox üzerinden manuel — `cask-jetbrains-toolbox.sh` sonrası Toolbox’tan **Release** channel.

## Company domain (`COMPANY_DOMAIN`)

Şablonlar `templates/` altında; `envsubst` ile `.rendered/` üretilir (gitignore).

Öncelik: `~/.config/dotfiles-company.env` → `config/company.env` → `config/company.env.example`.

```bash
export COMPANY_DOMAIN=my.company.com
./scripts/render-templates.sh
./install.sh --only-link
```

## Secrets

Repoda **sadece** `*.example` / `*.tpl`. Gerçek dosyalar:

- `~/.config/dotfiles-secrets.env`
- `~/.netrc` (kaynak: `.rendered/secrets/netrc.example`)
- `~/.npmrc` (kaynak: `.rendered/home/.npmrc.example` + token env)

## Güncelleme (PC A → B)

```bash
# A: home/ ve config/ değiştir, push
cd ~/lab/dotfiles && git pull   # B
./install.sh --only-link
```

## Not: `jarvis-pi-dotfiles`

`~/lab/jarvis-pi-dotfiles` eski kopya; canonical repo **`~/lab/dotfiles`**.
