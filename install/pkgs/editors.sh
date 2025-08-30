#!/bin/bash

# Install LazyVim
if [[ ! -d "$HOME/.config/nvim" ]]; then
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git
  echo "vim.opt.relativenumber = false" >>~/.config/nvim/lua/config/options.lua
  echo "Lazyvim Instalado."
fi
