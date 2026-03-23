#!/usr/bin/env zsh

installed="$(/usr/bin/pgrep oahd > /dev/null 2>&1 && echo "Rosetta installed" || echo "Rosetta not installed")"
if [[ "${installed}" == "Rosetta installed" ]]; then
    echo "already installed: rosetta"
    exit 0
fi

softwareupdate --install-rosetta --agree-to-license
