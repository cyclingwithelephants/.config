#!/usr/bin/env bash

set -eou pipefail

# add self to sudoers, we do this first to prevent needing to write password multiple times
echo "$(whoami) ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee' visudo -f /private/etc/sudoers.d/adam

# install applications using brew, brew cask and Mac App store
BREWFILE="${HOME}/.config/brewfile/Brewfile"
if [[ "$(which brew)" == "brew not found" ]]; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew bundle install --file ${BREWFILE}
# clean up applications not installed using the brewfile
brew bundle --force cleanup --file ${BREWFILE}

# zshrc will load all config from ~/.config/zsh/* thanks to ~/.zshenv specifying ZDOTDIR
SYSTEM_ZSHENV=/etc/zshenv
sudo ln -sf $HOME/.config/zsh/.zshenv $SYSTEM_ZSHENV
chmod +r $SYSTEM_ZSHENV

##
## Apple specific configuration

# https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Setting-the-Mac-hostname-or-computer-name-from-the-terminal.html
hostname=shallot
sudo scutil --set HostName      "${hostname}"
sudo scutil --set LocalHostName "${hostname}"
sudo scutil --set ComputerName  "${hostname}"


## Yabai - only run on personal machine
## https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)
#if [[ "$(which yabai)" != ""]]; then
#  echo "$(whoami) ALL = (root) NOPASSWD: $(which yabai) --load-sa" | sudo EDITOR='tee' visudo -f /private/etc/sudoers.d/yabai
#  sudo yabai --install-sa
#  sudo yabai --load-sa
#  brew services start yabai
#  brew services start skhd
#fi
