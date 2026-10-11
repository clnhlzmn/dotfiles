#!/bin/sh
# Entry point for tools that clone this repo and expect it to set itself up.
# `devcontainer up --dotfiles-repository` (dcup in home/dot_zshrc) runs the
# install.sh it finds at the root. Same steps as the README's Linux install,
# with the source taken from wherever this clone landed.

set -eu

src=$(cd "$(dirname "$0")" && pwd)
bin="$HOME/.local/bin"

if command -v chezmoi >/dev/null 2>&1; then
	chezmoi=chezmoi
elif [ -x "$bin/chezmoi" ]; then
	chezmoi="$bin/chezmoi"
else
	if command -v curl >/dev/null 2>&1; then
		installer=$(curl -fsLS get.chezmoi.io)
	else
		installer=$(wget -qO- get.chezmoi.io)
	fi
	sh -c "$installer" -- -b "$bin"
	chezmoi="$bin/chezmoi"
fi

printf 'chezmoi init --source=%s --apply\n' "$src"
"$chezmoi" init --source="$src" --apply
