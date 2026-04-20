#!/bin/bash

set -Eeuo pipefail

msg() { printf '\033[1;32m[+] %s\033[0m\n' "$*"; }
err() { printf '\033[1;31m[!] %s\033[0m\n' "$*" >&2; }

# Instalação do pacote mise como root.
# A ativação no rcfile é feita pelos defaults em default/bashrc e default/config.fish
# (já guardados por `command -v mise`). config/config.sh copia esses defaults
# para o TARGET_USER, então qualquer write aqui seria sobrescrito depois.

msg "Instalando Mise..."
pacman -S --needed --noconfirm mise

msg "Verificando versão do mise..."
mise --version || true

msg "Concluído. Mise instalado."
