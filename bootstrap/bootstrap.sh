#!/usr/bin/env zsh
set -euo pipefail

# Bootstrap a Mac from scratch (or re-converge an existing one).
#
# Everything declarative lives in nix-darwin (~/.config/darwin/). This
# script exists only to break the chicken-and-egg cycle: nix-darwin
# can't install itself, and nix-homebrew can't install Homebrew. Once
# those two are present, control transfers to `darwin-rebuild switch`
# and never comes back.
#
# If you find yourself reaching for a `defaults write`, `scutil`, sudo
# config, or symlink in here — stop. Add it to ~/.config/darwin/${host}.nix
# instead. The one exception is Logi Options+: it ships as a proprietary
# .pkg installer with no nix/brew presence, so its installer script stays
# in ./install_scripts/.

SCRIPT_DIR="${0:A:h}"
CONFIG_DIR="${SCRIPT_DIR}/config"
hostname=""

function setup() {
    if [[ "$(uname)" != "Darwin" ]]; then
        echo "Error: this script only supports macOS" >&2
        exit 1
    fi

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

    if [[ ! -f "${PWD}/darwin/${hostname}.nix" ]]; then
        echo "Error: ~/.config/darwin/${hostname}.nix not found." >&2
        echo "Add a nix-darwin module for this host before bootstrapping." >&2
        exit 1
    fi
}

# Chicken-egg #1: nix-darwin needs nix to exist before it can install.
# Justified imperative — there is no nix expression for "install nix".
function install_nix() {
    if command -v nix &>/dev/null; then
        return 0
    fi
    curl --proto '=https' --tlsv1.2 -sSf -L \
        https://install.determinate.systems/nix \
        | sh -s -- install --no-confirm
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
}

# Chicken-egg #2: nix-homebrew manages the package set declaratively but
# does not install Homebrew itself. Justified imperative.
function install_homebrew() {
    if command -v brew &>/dev/null; then
        return 0
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

# Hand over to nix-darwin. Subsequent rebuilds use `darwin-rebuild switch`
# directly — this `nix run` form is only needed before the switch wrapper
# is on PATH.
function apply_nix_darwin() {
    sudo nix run nix-darwin/master#darwin-rebuild -- \
        switch --flake "${PWD}/darwin#${hostname}"
}

# Logi Options+ ships as a proprietary pkg with no nix or brew presence.
# Each script in here is responsible for its own idempotency.
function run_install_scripts() {
    for script in ./install_scripts/*; do
        bash "${script}"
    done
}

function main() {
    local machine_name

    setup
    machine_name="$(resolve_machine_name "${1:-}")"
    load_machine_config "${machine_name}"

    install_nix
    install_homebrew
    apply_nix_darwin   # owns everything else: hostname, defaults, sudo,
                       # pam, brew packages, /etc/zshenv, ~/.claude symlink
    run_install_scripts
}

main "$@"
