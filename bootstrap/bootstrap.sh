#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
CONFIG_DIR="${SCRIPT_DIR}/config"
hostname=""

function setup() {
    if [[ "$(uname)" != "Darwin" ]]; then
        echo "Error: this script only supports macOS" >&2
        exit 1
    fi

    # we assume execution from the ~/.config directory
    cd "${SCRIPT_DIR}/.."

    source zsh/.zshenv
}

function resolve_machine_name() {
    if [[ $# -ge 1 && -n "$1" ]]; then
        echo "$1"
        return 0
    fi

    local detected_hostname
    detected_hostname="$(hostname)"

    if [[ -z "${detected_hostname}" ]]; then
        echo "Error: failed to detect hostname" >&2
        exit 1
    fi

    echo "${detected_hostname}"
}

function load_machine_config() {
    local machine_name="$1"
    local config_path="${CONFIG_DIR}/${machine_name}.sh"

    if [[ ! -f "${config_path}" ]]; then
        echo "Error: no machine config found for '${machine_name}' at ${config_path}" >&2
        exit 1
    fi

    source "${config_path}"

    if [[ -z "${hostname}" ]]; then
        echo "Error: machine config '${config_path}' must set hostname" >&2
        exit 1
    fi
}

function configure_sudo_nopasswd() {
    echo "$(whoami) ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee' visudo -f "/private/etc/sudoers.d/$(whoami)"
}

function configure_hostname() {
    # https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Setting-the-Mac-hostname-or-computer-name-from-the-terminal.html
    sudo scutil --set HostName "${hostname}"
    sudo scutil --set LocalHostName "${hostname}"
    sudo scutil --set ComputerName "${hostname}"
}

function configure_key_repeat() {
    # Fastest repeat rate and shortest delay available in System Settings UI
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
}

function configure_dock() {
    # remove all items from the dock
    defaults write com.apple.dock persistent-apps -array
    defaults write com.apple.dock persistent-others -array
    defaults write com.apple.dock show-recents -bool false

    # set the dock to autohide
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.5  # animation speed in seconds

    # Don't rearrange Spaces based on recent use (very annoying default)
    defaults write com.apple.dock mru-spaces -bool false

    # add the Downloads folder to the dock
    defaults write com.apple.dock persistent-others -array-add '
    <dict>
        <key>tile-data</key>
        <dict>
            <key>file-data</key>
            <dict>
                <key>_CFURLString</key>
                <string>/Users/'"$USER"'/Downloads</string>
                <key>_CFURLStringType</key>
                <integer>0</integer>
            </dict>
            <key>displayas</key>
            <integer>1</integer>
            <key>showas</key>
            <integer>2</integer>
        </dict>
        <key>tile-type</key>
        <string>directory-tile</string>
    </dict>'

    killall Dock 2>/dev/null || true
}

function configure_finder() {
    # Don't show all file extensions (i.e. <app-name>.app is <app-name>)
    defaults write NSGlobalDomain AppleShowAllExtensions -bool false

    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Show path bar at bottom
    defaults write com.apple.finder ShowPathbar -bool true

    # Show status bar at bottom
    defaults write com.apple.finder ShowStatusBar -bool true

    # Default to list view
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Search current folder by default (instead of whole Mac)
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Set the new window target to "Home" (PfHm = home directory)
    defaults write com.apple.finder NewWindowTarget -string "PfHm"

    # Set the actual path for the home directory
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

    killall Finder 2>/dev/null || true
}

function configure_screenshots() {
    # Change screenshot save location
    defaults write com.apple.screencapture location ~/Pictures/Screenshots

    # Remove shadow from window screenshots
    defaults write com.apple.screencapture disable-shadow -bool true

    # Save as jpg instead of png
    defaults write com.apple.screencapture type jpg
}

function configure_trackpad() {
    # Enable tap-to-click (no need to physically press)
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
}

function configure_touch_id() {
    # Enable sudo Touch ID
    if ! grep -q "pam_tid.so" /etc/pam.d/sudo; then
        sudo sed -i '' '2s/^/auth       sufficient     pam_tid.so\n/' /etc/pam.d/sudo
    fi
}

function configure_window_size() {
    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
}

function configure_claude() {
    # Claude Code hardcodes ~/.claude as its config directory.
    # Symlink it into XDG_CONFIG_HOME so config lives alongside everything else.
    local xdg_claude="${XDG_CONFIG_HOME}/claude"
    local home_claude="${HOME}/.claude"

    mkdir -p "${xdg_claude}"

    if [[ -L "${home_claude}" ]]; then
        return 0
    fi

    if [[ -d "${home_claude}" ]]; then
        echo "Error: ${home_claude} is a real directory, not a symlink." >&2
        echo "Run: mv ${home_claude} ${home_claude}.bak && ln -s ${xdg_claude} ${home_claude}" >&2
        echo "Then manually merge ${home_claude}.bak into ${xdg_claude}" >&2
        return 1
    fi

    ln -s "${xdg_claude}" "${home_claude}"
}

function configure_no_autoupdate() {
    # done to disable automatic updates by bitwarden
    # we have to set here for mac compatibility, it's also set in zshenv for linux
    # WARN: this might have unintended consequences for other applications
    # but bitwarden doesn't offer an alternative method for this
    launchctl setenv ELECTRON_NO_UPDATER 1
}

function configure_hushlogin() {
    # this stops the "last login" message in the terminal
    sudo touch /etc/hushlogin
}

function install_packages() {
    local brewfile_path

    # install applications using brew
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    eval "$(/opt/homebrew/bin/brew shellenv)"
    # zshrc will load all config from ~/.config/zsh/* thanks to /etc/.zshenv specifying ZDOTDIR
    sudo ln -sf "${HOME}/.config/zsh/.zshenv" /etc/zshenv
    brewfile_path="./homebrew/Brewfile.${hostname}"
    export HOMEBREW_BUNDLE_FILE_GLOBAL="${PWD}/homebrew/Brewfile.${hostname}"

    if [[ ! -f "${brewfile_path}" ]]; then
        echo "Error: ${brewfile_path} not found" >&2
        return 1
    fi

    echo "brew install may look like it's hanging. It might take a few hours to install packages."
    brew bundle \
        --global \
        --verbose \
        --cleanup

    # install packages that are otherwise awkward to install using a Brewfile
    for script in ./install_scripts/*; do
        bash "${script}"
    done
}

function main() {
    local machine_name

    setup
    machine_name="$(resolve_machine_name "${1:-}")"
    load_machine_config "${machine_name}"
    configure_sudo_nopasswd
    configure_hostname
    configure_dock
    configure_finder
    configure_hushlogin
    configure_key_repeat
    configure_screenshots
    configure_touch_id
    configure_trackpad
    configure_window_size
    configure_claude
    install_packages
}

main "$@"
