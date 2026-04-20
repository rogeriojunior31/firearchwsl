#!/bin/bash

set -Eeuo pipefail

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
  "harper"
  "figlet"
  "asciinema"
  "docker"
  "docker-buildx"
  "docker-compose"
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
  "emacs"
)

msg() { printf '\e[1;32m[INFO]\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33m[WARN]\e[0m %s\n' "$*"; }
die() {
  printf '\e[1;31m[ERRO]\e[0m %s\n' "$*"
  exit 1
}

need_cmd() { command -v "$1" &>/dev/null; }

ensure_sudo() {
  if ((EUID != 0)); then
    sudo -v || die "Permissão de superusuário necessária."
  fi
}

main() {
  ensure_sudo
  # Sync já feito por repositories.sh (pós-keyring).
  msg "Instalando pacotes pacman…"
  sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

  msg "Tudo pronto! Pacotes essenciais instalados."
}

main "$@"
