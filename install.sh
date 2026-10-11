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
	installer=$(curl -fsLS get.chezmoi.io)
	sh -c "$installer" -- -b "$bin"
	chezmoi="$bin/chezmoi"
fi

printf 'chezmoi init --source=%s --apply\n' "$src"
"$chezmoi" init --source="$src" --apply

# Neovim, which the Brewfile provides on macOS. The upstream tarball needs
# neither root nor a package manager, so it does not matter what the image is
# based on, as long as it is glibc: these builds do not run on musl (Alpine).
if [ "$(uname -s)" = Linux ] && ! command -v nvim >/dev/null 2>&1 && [ ! -x "$bin/nvim" ]; then
	case $(uname -m) in
		x86_64) arch=x86_64 ;;
		aarch64 | arm64) arch=arm64 ;;
		*) arch= ;;
	esac

	if [ -z "$arch" ]; then
		printf 'no neovim build for %s — skipping\n' "$(uname -m)" >&2
	else
		opt="$HOME/.local/opt"
		printf 'installing neovim into %s\n' "$opt/nvim-linux-$arch"
		mkdir -p "$opt" "$bin"
		curl -fsLS "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$arch.tar.gz" |
			tar -xz -C "$opt"
		ln -sf "$opt/nvim-linux-$arch/bin/nvim" "$bin/nvim"
		"$bin/nvim" --version | sed 1q
	fi
fi
