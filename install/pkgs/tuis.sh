#!/bin/bash

set -Eeuo pipefail

PACMAN_PKGS=(
  "taskwarrior-tui"
  "tabiew"
  "lazygit"
  "television"
  "navi"
  "yazi"
  "imagemagick"
  "poppler"
  "fzf"
  "atuin"
  "rsync"
  "chafa"
  "resvg"
  "ffmpegthumbnailer"
  "libcaca"
  "lynx"
  "mediainfo"
  "odt2txt"
  "perl-image-exiftool"
  "python-pillow"
  "python-chardet"
  "ueberzug"
  "w3m"
  "lazydocker"
  "superfile"
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
    sudo -v || die "Permissao de superusuario necessaria."
  fi
}

main() {
  ensure_sudo
  msg "Sincronizando AUR (yay)..."
  yay -Syu --noconfirm || warn "yay -Syu falhou — seguindo com pacman."

  msg "Instalando pacotes pacman..."
  sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

  msg "Tudo pronto! TUIs instaladas!"
}

main "$@"
