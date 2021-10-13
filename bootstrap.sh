#!/usr/bin/env bash



user=adam
home="/home/${user}"
# zshrc will load all config from ~/.config/zsh/* thanks to ~/.zshenv specifying ZDOTDIR
ln -sf $home/.config/zsh/.zshenv /etc/zsh/zshenv
chmod +r /etc/zsh/zshenv

# Add user to passwordless sudo'ers


chsh --shell /bin/zsh adam
localectl set-locale LANG=en_GB.UTF-8
