#!/bin/bash

# Exit immediately if a non-zero status
set -eE

# Raiz absoluta do repo — serve de base para subscripts que copiam payloads
FIREARCH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export FIREARCH_ROOT

# Paths
FIREARCH_INSTALL="$FIREARCH_ROOT/install"
FIREARCH_SYSTEM="$FIREARCH_ROOT/system"
FIREARCH_CONFIG="$FIREARCH_ROOT/config"

# initial package sync
pacman -Syu --noconfirm

# Preparation
source "$FIREARCH_INSTALL/preflights/trap-errors.sh"
source "$FIREARCH_SYSTEM/create_your_user.sh"
source "$FIREARCH_INSTALL/preflights/lib.sh"
ensure_target_user
source "$FIREARCH_SYSTEM/configure_locale.sh"
source "$FIREARCH_SYSTEM/wsl_config.sh"
source "$FIREARCH_INSTALL/preflights/essentials_pkgs.sh"
source "$FIREARCH_SYSTEM/configure_git_user.sh"
source "$FIREARCH_INSTALL/preflights/repositories.sh"
source "$FIREARCH_INSTALL/preflights/install-mise.sh"

# Packaging
source "$FIREARCH_INSTALL/pkgs/good-tools.sh"
source "$FIREARCH_INSTALL/pkgs/tuis.sh"
source "$FIREARCH_INSTALL/pkgs/install_langs.sh"
source "$FIREARCH_INSTALL/pkgs/editors.sh"
# Config
source "$FIREARCH_CONFIG/config.sh"
source "$FIREARCH_CONFIG/docker.sh"

## Final phase
clear
tte -i "$FIREARCH_ROOT/logo.txt" --frame-rate 920 laseretch
echo
echo "Tudo pronto dog! agora reinicie sua wsl com o comando ´wsl --terminante archlinux´ e estara tudo configurado!" | tte --frame-rate 640 wipe

sleep 5
exit
