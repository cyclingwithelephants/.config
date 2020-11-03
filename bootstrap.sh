#!/usr/bin/env bash


for file in .zshrc .vimrc; do
  if [ ! -L ~/${file} ]; then
    rm -f ~/${file}
    ln -s  ./${file} ~/${file}
  fi
done
