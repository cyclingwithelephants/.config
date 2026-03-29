# This code is used so that I can transparently use `brew install XYZ`
# and this script will keep the Brewfile automatically up to date

brewfile_path() {
	if [[ -z "${HOMEBREW_BUNDLE_FILE_GLOBAL:-}" ]]; then
		echo "HOMEBREW_BUNDLE_FILE_GLOBAL is not set." >&2
		return 1
	fi

	echo "${HOMEBREW_BUNDLE_FILE_GLOBAL}"
}

# Function to handle brew install and update the Brewfile
brew_install_with_brewfile() {
	IS_CASK=0
	FORMULA=""
	local brewfile

	brewfile="$(brewfile_path)" || return 1

	# Parse arguments to handle "--cask" regardless of position
	for arg in "$@"; do
		if [[ "$arg" == "--cask" ]]; then
			IS_CASK=1
		else
			FORMULA="$arg"
		fi
	done

	if [[ -z "$FORMULA" ]]; then
		echo "Usage: brew install [--cask] <formula|cask>"
		return 1
	fi

	# Ensure the Brewfile exists
	if [[ ! -f "$brewfile" ]]; then
		mkdir -p "$(dirname "$brewfile")"
		touch "$brewfile"
	fi

	# Ensure the formula gets installed as either a formula or cask correctly
	if [[ $IS_CASK -eq 1 ]]; then
		# Install as cask
		if command brew install --cask "$FORMULA"; then
			add_to_brewfile "$FORMULA" "cask"
		else
			echo "Failed to install \"$FORMULA\"."
			return 1
		fi
	else
		# Install as formula
		if command brew install "$FORMULA"; then
			add_to_brewfile "$FORMULA" "brew"
		else
			echo "Failed to install \"$FORMULA\"."
			return 1
		fi
	fi
}

# Helper function to add entries to the Brewfile
add_to_brewfile() {
	ENTRY_TYPE="$2"
	FORMULA="$1"
	ENTRY="$ENTRY_TYPE \"$FORMULA\""
	local brewfile

	brewfile="$(brewfile_path)" || return 1

	# Check if the entry already exists
	if grep -qE "^$ENTRY$" "$brewfile"; then
		echo "$ENTRY is already in the Brewfile."
	else
		TMPFILE=$(mktemp)
		awk -v entry="$ENTRY" -v type="$ENTRY_TYPE" '
      BEGIN { placed = 0 }
      /^brew "/ && type == "brew" {
        if (!placed && $0 > entry) {
          print entry
          placed = 1
        }
      }
      /^cask "/ && type == "cask" {
        if (!placed && $0 > entry) {
          print entry
          placed = 1
        }
      }
      { print $0 }
      END {
        if (!placed) print entry
      }
    ' "$brewfile" >"$TMPFILE"
		mv "$TMPFILE" "$brewfile"
		echo "Added \"$FORMULA\" to the Brewfile as $ENTRY."
	fi
}

# Function to handle brew uninstall and update the Brewfile
brew_uninstall_with_brewfile() {
	IS_CASK=0
	FORMULA=""
	local brewfile

	brewfile="$(brewfile_path)" || return 1

	# Parse arguments to handle "--cask" regardless of position
	for arg in "$@"; do
		if [[ "$arg" == "--cask" ]]; then
			IS_CASK=1
		else
			FORMULA="$arg"
		fi
	done

	if [[ -z "$FORMULA" ]]; then
		echo "Usage: brew uninstall [--cask] <formula|cask>"
		return 1
	fi

	# Ensure the Brewfile exists
	if [[ ! -f "$brewfile" ]]; then
		echo "No Brewfile found at $brewfile."
		return 1
	fi

	# Uninstall the formula or cask (pass --cask only if required)
	# Don't abort on failure — the package may already be uninstalled,
	# but we still want to clean it from the Brewfile
	if [[ $IS_CASK -eq 1 ]]; then
		command brew uninstall --cask "$FORMULA" 2>/dev/null ||
			echo "Note: \"$FORMULA\" was not installed (already removed?)."
		ENTRY="cask \"$FORMULA\""
	else
		command brew uninstall "$FORMULA" 2>/dev/null ||
			echo "Note: \"$FORMULA\" was not installed (already removed?)."
		ENTRY="brew \"$FORMULA\""
	fi

	# Check if the entry exists in the Brewfile and remove it
	# If --cask wasn't specified, also check for a cask entry (and vice versa),
	# since brew uninstall works without --cask but the Brewfile may list it as a cask
	if grep -qE "^$ENTRY$" "$brewfile"; then
		sed -i.bak "/^$ENTRY$/d" "$brewfile" && rm -f "$brewfile.bak"
		echo "Removed \"$FORMULA\" from the Brewfile."
	elif [[ $IS_CASK -eq 0 ]] && grep -qE "^cask \"$FORMULA\"$" "$brewfile"; then
		sed -i.bak "/^cask \"$FORMULA\"$/d" "$brewfile" && rm -f "$brewfile.bak"
		echo "Removed \"$FORMULA\" from the Brewfile (was listed as cask)."
	elif [[ $IS_CASK -eq 1 ]] && grep -qE "^brew \"$FORMULA\"$" "$brewfile"; then
		sed -i.bak "/^brew \"$FORMULA\"$/d" "$brewfile" && rm -f "$brewfile.bak"
		echo "Removed \"$FORMULA\" from the Brewfile (was listed as brew)."
	else
		echo "\"$FORMULA\" was not found in the Brewfile."
	fi
}
