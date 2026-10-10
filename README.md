# dotfiles

Personal macOS configuration, managed with [chezmoi](https://chezmoi.io).

Two things differ from a stock chezmoi setup:

- The source directory is this repo at `~/dotfiles`, not `~/.local/share/chezmoi`.
- `.chezmoiroot` sends chezmoi into `home/`, so `README.md` and `Brewfile` sit
  above the managed tree rather than needing a `.chezmoiignore`.

## Install

```sh
brew install chezmoi
git clone git@github.com:clnhlzmn/dotfiles.git ~/dotfiles
chezmoi init --source=~/dotfiles   # records sourceDir; later commands need no flag
chezmoi apply
```

`home/.chezmoi.toml.tmpl` derives `sourceDir` from wherever the clone landed, so
`~/dotfiles` is a convention rather than a requirement.

### Linux

Same steps, with the chezmoi binary in place of the Homebrew formula:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
git clone git@github.com:clnhlzmn/dotfiles.git ~/dotfiles
~/.local/bin/chezmoi init --source=~/dotfiles
~/.local/bin/chezmoi apply
```

The Brewfile is macOS-only. `10-brew-bundle.sh` skips itself when `brew` is not
on `PATH`, so packages come from the host's package manager. The zsh files only
take effect where zsh is the login shell.

## Layout

```
.chezmoiroot                        "home"
Brewfile                            formulae, casks, go/uv/npm tools
home/                               source root
  .chezmoi.toml.tmpl
  .chezmoiscripts/
  dot_zshrc dot_zprofile dot_tmux.conf dot_gitconfig
  private_dot_config/git/ignore
  private_dot_claude/settings.json
```

`private_` on those two directories is load-bearing: `~/.config` and `~/.claude`
are mode `700`, and without it chezmoi would widen them to `755`.

## Scripts

`apply` runs both, keyed on a content hash rather than on every run:

- `10-brew-bundle.sh` — `brew bundle --no-upgrade` against the Brewfile.
  Installs what is missing, never upgrades what is already there. Packages are
  not a separate step.
- `20-reload-tmux.sh` — sources `~/.tmux.conf` into a running tmux server.

## `.claude/settings.json`

Claude Code rewrites this file when settings change in the app. chezmoi puts a
plain copy in `$HOME`, so those writes stay local and surface as drift —
`chezmoi re-add` to keep them, `chezmoi apply` to discard. Worth a
`chezmoi status` now and then.
