#!/bin/bash

set -Eeuo pipefail

PACMAN_PKGS=(
  "sudo"
  "base-devel"
  "git"
  "fish"
  "btop"
  "curl"
  "wget"
  "just"
  "make"
  "eza"
  "bat"
  "openssh"
  "vim"
)

##  Functions
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
  msg "Atualizando pacman/paru…"
  ensure_sudo
  sudo pacman -Syu --noconfirm

  msg "Instalando pacotes pacman…"
  sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

  msg "Pacotes essenciais instalados."
}

main "$@"
