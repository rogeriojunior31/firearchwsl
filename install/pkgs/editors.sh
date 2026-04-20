#!/bin/bash

set -Eeuo pipefail

: "${TARGET_USER:?TARGET_USER não definido — rode via install.sh}"
: "${TARGET_HOME:?TARGET_HOME não definido — rode via install.sh}"

# Install LazyVim
if [[ ! -d "$TARGET_HOME/.config/nvim" ]]; then
  as_user git clone https://github.com/LazyVim/starter "$TARGET_HOME/.config/nvim"
  as_user rm -rf "$TARGET_HOME/.config/nvim/.git"
  as_user bash -c 'echo "vim.opt.relativenumber = false" >>"$HOME/.config/nvim/lua/config/options.lua"'
  echo "Lazyvim Instalado."
fi

# Install Doom Emacs (leva 5-15min — download + compilação de pacotes)
if [[ ! -d "$TARGET_HOME/.emacs.d" ]]; then
  echo "⏳ Doom Emacs: a instalação leva 5-15min (download + compile). Aguarde..."
  as_user git clone --depth 1 https://github.com/doomemacs/doomemacs "$TARGET_HOME/.emacs.d"
  as_user env DOOMLOCALDIR="$TARGET_HOME/.emacs.d/.local" \
    "$TARGET_HOME/.emacs.d/bin/doom" install --no-fonts --no-hooks --yes || \
    warn "Doom install retornou não-zero — revise manualmente com 'doom doctor'."
  echo "Doom Emacs Instalado."
fi
