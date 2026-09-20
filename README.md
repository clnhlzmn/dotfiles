# dotfiles

Personal macOS configuration. Everything under `home/` mirrors `$HOME`, and
`install.sh` symlinks it into place.

## Install

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run   # see what it would do
./install.sh
```

Existing files are never deleted — anything in the way is moved to
`~/.dotfiles-backup/<timestamp>/` first, keeping its relative path. Re-running
is safe: links that already point here are left alone.

Packages are a separate step:

```sh
brew bundle --file=~/dotfiles/Brewfile
```

## Layout

```
home/                    mirrors $HOME
  .zshrc                 PATH, aliases
  .zprofile              brew shellenv, OrbStack init
  .tmux.conf             mouse, scrollback
  .gitconfig             identity, editor
  .config/git/ignore     global gitignore
  .claude/settings.json  Claude Code settings
Brewfile                 formulae, casks, and go/uv/npm tools
install.sh               the symlinker
```

## Adding a file

Move it into `home/` at the path it has relative to `$HOME`, then re-run
`install.sh` — it picks up anything new without needing to be edited.

```sh
mv ~/.vimrc ~/dotfiles/home/.vimrc
./install.sh
```

## Deliberately not tracked

- `~/.ssh/config` — contains a real host, port and username.
- `~/.config/rclone/rclone.conf` and `~/.config/immich/auth.yml` — credentials.
- `~/.local/bin/` — two entries are symlinks into tool-managed installs (uv,
  Claude Code), so they belong to those tools rather than here.
- VS Code settings and extensions.

## Note on `.claude/settings.json`

Claude Code writes to this file when settings change in the app. If it ever
replaces the file instead of writing through the symlink, the link turns back
into a regular file — `./install.sh --dry-run` will show it as needing a
relink, and the edited version lands in the backup folder. Check
`git -C ~/dotfiles status` after changing settings in the app.
