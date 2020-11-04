#!/usr/bin/env bash


function idempotent_sym_link () {
  file_location=$1 ; shift
  link_location=$1 ; shift
  
  if [ -L ${link_location} ]; then
    # if symlink does not point to file
    if [ "$(readlink ${link_location})" != "${file_location}" ]; then
      rm -f ${link_location}
    fi
  fi
  
  if [ ! -L ${link_location} ]; then
    rm -f ${link_location}
    ln -s  ${file_location} ${link_location}
  fi
}

# zshrc will load all config from ~/.config/zsh/*
idempotent_sym_link ~/.config/dotfiles/zsh/.zshrc ~/.zshrc

idempotent_sym_link ~/.config/dotfiles/.vimrc ~/.vimrc

# alacritty already looks in ~/.config/alacritty/alacritty.yml
