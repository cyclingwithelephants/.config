#!/usr/bin/env bash

hostname=shallot

set -eou pipefail

cd $(dirname $(readlink -f $0))
source zsh/.zshenv

# add self to sudoers, we do this first to prevent needing to write password multiple times
echo "$(whoami) ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee' visudo -f "/private/etc/sudoers.d/$(whoami)"

# install applications using brew
if [[ "$(which brew)" == "brew not found" ]]; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew bundle install --file "${HOMEBREW_BREWFILE}"
brew bundle cleanup --file "${HOMEBREW_BREWFILE}" --force

# zshrc will load all config from ~/.config/zsh/* thanks to /etc/.zshenv specifying ZDOTDIR
sudo ln -sf "${HOME}/.config/zsh/.zshenv" /etc/zshenv
chmod +r /etc/zshenv

##
## Apple specific configuration

# https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Setting-the-Mac-hostname-or-computer-name-from-the-terminal.html
sudo scutil --set HostName "${hostname}"
sudo scutil --set LocalHostName "${hostname}"
sudo scutil --set ComputerName "${hostname}"

# this stops the "last login" message in the terminal, slightly increasing its speed
touch ~/.hushlogin

# install packages that are otherwise awkward to install using a Brewfile
for script in ./install_scripts/*; do
	bash "${script}"
done
