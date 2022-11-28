#!/usr/bin/env bash

set -eou pipefail

# add self to sudoers, we do this first to prevent needing to write password multiple times
echo "$(whoami) ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee' visudo -f /private/etc/sudoers.d/adam

# install applications using brew, brew cask and Mac App store
# clean up applications not installed using the brewfile
brew bundle install --file $HOME/.config/brewfile/Brewfile
brew bundle --force cleanup --file $HOME/.config/brewfile/Brewfile

# zshrc will load all config from ~/.config/zsh/* thanks to ~/.zshenv specifying ZDOTDIR
SYSTEM_ZSHENV=/etc/zshenv
sudo ln -sf $HOME/.config/zsh/.zshenv $SYSTEM_ZSHENV
chmod +r $SYSTEM_ZSHENV

sudo chsh -s $(which zsh) adam

# Yabai - only run on personal machine
# https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)
if [[ "$(which yabai)" != ""]]; then
  echo "$(whoami) ALL = (root) NOPASSWD: $(which yabai) --load-sa" | sudo EDITOR='tee' visudo -f /private/etc/sudoers.d/yabai
  sudo yabai --install-sa
  sudo yabai --load-sa
  brew services start yabai
  brew services start skhd
fi


# Apple specific configuration

# Make key repeat fast
# https://apple.stackexchange.com/questions/10467/how-to-increase-keyboard-key-repeat-rate-on-os-x?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
defaults write -g InitialKeyRepeat -int 15 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 2         # normal minimum is 2  (30  ms)
