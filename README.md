# dotfiles

Personal macOS configuration, managed with [chezmoi](https://chezmoi.io).

Two things differ from a stock chezmoi setup:

- The source directory is this repo at `~/dotfiles`, not `~/.local/share/chezmoi`.
- `.chezmoiroot` sends chezmoi into `home/`, so `README.md`, `Brewfile` and
  `install.sh` sit above the managed tree rather than needing a `.chezmoiignore`.

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

### Dev containers

`install.sh` does the Linux steps unattended, using whatever directory it was
cloned into as the source. The devcontainer CLI runs it when given this repo as
`--dotfiles-repository`, which is what `dcup` in `dot_zshrc` does:

```sh
dcup [workspace] [flags]   # devcontainer up, with these dotfiles installed
dcsh [workspace]           # bash in that container
```

`dcup` also bind-mounts the host's SSH agent into the container and `dcsh`
points `SSH_AUTH_SOCK` at it. Mounts are set when a container is created, so one
that already exists needs recreating to pick the agent up; extra flags go
straight to `devcontainer up`, so that is `dcup --remove-existing-container`.

## Layout

```
.chezmoiroot                        "home"
install.sh                          chezmoi bootstrap for dev containers
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
