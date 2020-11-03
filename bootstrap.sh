#!/usr/bin/env bash

for file in .zshrc .vimrc; do
  if [ ! -L ~/${file} ]; then
    ln -s  ./${file} ~/${file}
  fi
done
