# This code is used so that I can transparently use `brew install XYZ`
# and this script will keep the Brewfile automatically up to date

# Function to handle brew install and update the Brewfile
brew_install_with_brewfile() {
  IS_CASK=0
  FORMULA=""

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
  if [[ ! -f "$BREWFILE" ]]; then
    mkdir -p "$(dirname "$BREWFILE")"
    touch "$BREWFILE"
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

  # Check if the entry already exists
  if grep -qE "^$ENTRY$" "$BREWFILE"; then
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
    ' "$BREWFILE" > "$TMPFILE"
    mv "$TMPFILE" "$BREWFILE"
    echo "Added \"$FORMULA\" to the Brewfile as $ENTRY."
  fi
}

# Function to handle brew uninstall and update the Brewfile
brew_uninstall_with_brewfile() {
  IS_CASK=0
  FORMULA=""

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
  if [[ ! -f "$BREWFILE" ]]; then
    echo "No Brewfile found at $BREWFILE."
    return 1
  fi

  # Uninstall the formula or cask (pass --cask only if required)
  if [[ $IS_CASK -eq 1 ]]; then
    if command brew uninstall --cask "$FORMULA"; then
      ENTRY="cask \"$FORMULA\""
    else
      echo "Failed to uninstall \"$FORMULA\"."
      return 1
    fi
  else
    if command brew uninstall "$FORMULA"; then
      ENTRY="brew \"$FORMULA\""
    else
      echo "Failed to uninstall \"$FORMULA\"."
      return 1
    fi
  fi

  # Check if the entry exists in the Brewfile and remove it
  if grep -qE "^$ENTRY$" "$BREWFILE"; then
    sed -i.bak "/^$ENTRY$/d" "$BREWFILE" && rm -f "$BREWFILE.bak"
    echo "Removed \"$FORMULA\" from the Brewfile."
  else
    echo "\"$FORMULA\" was not found in the Brewfile."
  fi
}
