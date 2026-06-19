# Transparent `brew install/uninstall` wrapper for the nix-darwin world.
#
# Source of truth is ~/.config/homebrew/Brewfile.${hostname}. nix-darwin's
# homebrew module (cleanup="zap") makes that file authoritative: anything
# not declared gets uninstalled on the next switch.
#
# So `brew install foo`:
#   1. inserts `brew "foo"` into the Brewfile in sorted order
#   2. runs `sudo darwin-rebuild switch` — that's what actually installs
#   3. commits + pushes the Brewfile change to ~/.config
#
# `brew uninstall foo` is the same with the line removed; the zap on next
# switch removes the package itself. We never call `command brew install`
# directly — that path is reserved for ad-hoc inspection commands only.

brewfile_path() {
	if [[ -z "${HOMEBREW_BUNDLE_FILE_GLOBAL:-}" ]]; then
		echo "HOMEBREW_BUNDLE_FILE_GLOBAL is not set." >&2
		return 1
	fi
	echo "${HOMEBREW_BUNDLE_FILE_GLOBAL}"
}

brew_install_with_brewfile() {
	local is_cask=0 formula="" brewfile
	brewfile="$(brewfile_path)" || return 1

	for arg in "$@"; do
		if [[ "$arg" == "--cask" ]]; then
			is_cask=1
		else
			formula="$arg"
		fi
	done

	if [[ -z "$formula" ]]; then
		echo "Usage: brew install [--cask] <formula|cask>" >&2
		return 1
	fi

	if [[ ! -f "$brewfile" ]]; then
		mkdir -p "$(dirname "$brewfile")"
		touch "$brewfile"
	fi

	local entry_type="brew"
	[[ $is_cask -eq 1 ]] && entry_type="cask"

	add_to_brewfile "$formula" "$entry_type" \
		&& _darwin_switch_and_commit "install ${entry_type} ${formula}"
}

brew_uninstall_with_brewfile() {
	local is_cask=0 formula="" brewfile
	brewfile="$(brewfile_path)" || return 1

	for arg in "$@"; do
		if [[ "$arg" == "--cask" ]]; then
			is_cask=1
		else
			formula="$arg"
		fi
	done

	if [[ -z "$formula" ]]; then
		echo "Usage: brew uninstall [--cask] <formula|cask>" >&2
		return 1
	fi

	if [[ ! -f "$brewfile" ]]; then
		echo "No Brewfile found at $brewfile." >&2
		return 1
	fi

	local entry_type="brew"
	[[ $is_cask -eq 1 ]] && entry_type="cask"

	remove_from_brewfile "$formula" "$entry_type" \
		&& _darwin_switch_and_commit "uninstall ${entry_type} ${formula}"
}

# Helper: insert `brew "name"` or `cask "name"` into the Brewfile in sorted
# order. Awk walks lines of the same type and drops the new entry at the
# first line that sorts after it. End-of-file fallback if it sorts last.
add_to_brewfile() {
	local formula="$1" entry_type="$2"
	local entry="${entry_type} \"${formula}\""
	local brewfile tmpfile
	brewfile="$(brewfile_path)" || return 1

	if grep -qE "^${entry}$" "$brewfile"; then
		echo "${entry} already declared."
		return 1
	fi

	tmpfile=$(mktemp)
	awk -v entry="$entry" -v type="$entry_type" '
		BEGIN { placed = 0 }
		/^brew "/ && type == "brew" {
			if (!placed && $0 > entry) { print entry; placed = 1 }
		}
		/^cask "/ && type == "cask" {
			if (!placed && $0 > entry) { print entry; placed = 1 }
		}
		{ print $0 }
		END { if (!placed) print entry }
	' "$brewfile" >"$tmpfile"
	mv "$tmpfile" "$brewfile"
	echo "Added ${entry} to Brewfile."
}

# Helper: remove a line from the Brewfile. Tolerates the cask/brew swap
# the user can make from the CLI (`brew uninstall foo` works whether foo
# is a formula or a cask), so check both line shapes before giving up.
remove_from_brewfile() {
	local formula="$1" entry_type="$2"
	local entry="${entry_type} \"${formula}\""
	local brewfile
	brewfile="$(brewfile_path)" || return 1

	if grep -qE "^${entry}$" "$brewfile"; then
		sed -i.bak "/^${entry}\$/d" "$brewfile" && rm -f "${brewfile}.bak"
		echo "Removed ${entry} from Brewfile."
		return 0
	fi

	local alt_type
	[[ "$entry_type" == "brew" ]] && alt_type="cask" || alt_type="brew"
	local alt_entry="${alt_type} \"${formula}\""

	if grep -qE "^${alt_entry}$" "$brewfile"; then
		sed -i.bak "/^${alt_entry}\$/d" "$brewfile" && rm -f "${brewfile}.bak"
		echo "Removed ${alt_entry} from Brewfile (was declared as ${alt_type})."
		return 0
	fi

	echo "${formula} not found in Brewfile."
	return 1
}

# Run the rebuild, then commit + push the Brewfile delta. Hard-fails the
# whole command if anything along the way fails — including push, which is
# how we'll later wire alerting (task #9). Rolls back the local Brewfile
# edit on rebuild failure so a broken switch doesn't leave a phantom line.
_darwin_switch_and_commit() {
	local message="$1" brewfile
	brewfile="$(brewfile_path)" || return 1

	# Absolute path: sudo's PATH won't include /run/current-system/sw/bin
	# unless secure_path is overridden, and we don't want to require that.
	if ! sudo /run/current-system/sw/bin/darwin-rebuild switch --flake "${HOME}/.config/darwin#${HOST}"; then
		echo "darwin-rebuild failed; rolling back ${brewfile}" >&2
		git -C "${HOME}/.config" checkout -- "$brewfile"
		return 1
	fi

	git -C "${HOME}/.config" add "$brewfile" || return 1
	git -C "${HOME}/.config" commit -m "homebrew: ${message}" || return 1
	git -C "${HOME}/.config" push || {
		echo "git push failed; commit is local. Push manually when network returns." >&2
		return 1
	}
}
