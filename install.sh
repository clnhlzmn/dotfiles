#!/bin/sh
# Symlink everything under home/ into $HOME, mirroring the directory layout.
#
# Anything already at a destination path is moved into a timestamped folder
# under ~/.dotfiles-backup/ rather than being deleted, so a first run on a
# machine that already has real dotfiles is recoverable.

set -eu

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
SRC_ROOT="$REPO_DIR/home"
DEST_ROOT="${HOME:?HOME is not set}"
BACKUP_ROOT="$DEST_ROOT/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0

usage() {
	cat <<'USAGE'
usage: install.sh [-n|--dry-run]

  -n, --dry-run   Show what would change without touching the filesystem.
  -h, --help      Show this message.
USAGE
}

for arg do
	case $arg in
		-n|--dry-run) DRY_RUN=1 ;;
		-h|--help) usage; exit 0 ;;
		*) printf 'install.sh: unknown option: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
	esac
done

[ -d "$SRC_ROOT" ] || { printf 'install.sh: no such directory: %s\n' "$SRC_ROOT" >&2; exit 1; }

[ "$DRY_RUN" -eq 1 ] && printf 'Dry run — nothing will be written.\n\n'

list=$(mktemp)
trap 'rm -f "$list"' EXIT INT TERM
find "$SRC_ROOT" -type f ! -name '.DS_Store' | LC_ALL=C sort > "$list"

n_link=0 n_ok=0 n_backup=0

while IFS= read -r src; do
	rel=${src#"$SRC_ROOT"/}
	dest=$DEST_ROOT/$rel

	# Already pointing where we want it.
	if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
		printf '  ok       ~/%s\n' "$rel"
		n_ok=$((n_ok + 1))
		continue
	fi

	# -L as well as -e so a broken symlink is caught rather than clobbered.
	if [ -e "$dest" ] || [ -L "$dest" ]; then
		backup=$BACKUP_ROOT/$rel
		printf '  backup   ~/%s -> ~/%s\n' "$rel" "${backup#"$DEST_ROOT"/}"
		if [ "$DRY_RUN" -eq 0 ]; then
			mkdir -p "$(dirname "$backup")"
			mv "$dest" "$backup"
		fi
		n_backup=$((n_backup + 1))
	fi

	printf '  link     ~/%s\n' "$rel"
	if [ "$DRY_RUN" -eq 0 ]; then
		mkdir -p "$(dirname "$dest")"
		ln -s "$src" "$dest"
	fi
	n_link=$((n_link + 1))
done < "$list"

printf '\n%d linked, %d already correct, %d backed up' "$n_link" "$n_ok" "$n_backup"
if [ "$n_backup" -gt 0 ] && [ "$DRY_RUN" -eq 0 ]; then
	printf ' to ~/%s' "${BACKUP_ROOT#"$DEST_ROOT"/}"
fi
printf '.\n'

if [ "$DRY_RUN" -eq 0 ]; then
	printf 'Packages are separate: brew bundle --file="%s/Brewfile"\n' "$REPO_DIR"
fi
