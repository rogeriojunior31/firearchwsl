#!/bin/bash
# Everyday CLIs, fonts and AUR helpers.
# (Docker lives in config/docker.sh, Emacs in pkgs/editors.sh — both optional.)

PACMAN_PKGS=(
  "jq"
  "yq"
  "stow"
  "fx"
  "fd"
  "ripgrep"
  "7zip"
  "zip"
  "unzip"
  "task"
  "zellij"
  "neovim"
  "glow"
  "gum"
  "harper"
  "figlet"
  "asciinema"
  "dust"
  "less"
  "man"
  "starship"
  "tldr"
  "tree-sitter-cli"
  "zoxide"
  "cargo"
  "python-poetry-core"
  "python-terminaltexteffects"
  "bash-completion"
  "yay"
  "paru"
  "luarocks"
  "ttf-cascadia-mono-nerd"
  "ttf-jetbrains-mono"
  "ttf-hack-nerd"
  "fastfetch"
)

# Sync already done by repositories.sh (post-keyring).
pac_install "$(t tools.install)" "${PACMAN_PKGS[@]}"
