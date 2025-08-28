#!/bin/bash

# Exit immediately if a non-zero status
set -eE

FIREARCH_INSTALL=./install
FIREARCH_SYSTEM=./system
FIREARCH_CONFIG=./config

# Preparation
source $FIREARCH_SYSTEM/create_your_user.sh
source $FIREARCH_SYSTEM/configure_locale.sh
source $FIREARCH_SYSTEM/wsl_config.sh
source $FIREARCH_INSTALL/preflight/essentials_pkgs.sh
source $FIREARCH_SYSTEM/configure_git_user.sh
source $FIREARCH_INSTALL/preflight/repositories.sh
source $FIREARCH_INSTALL/preflight/install-mise.sh

# Packaging
source $FIREARCH_INSTALL/pkgs/good-tools.sh
source $FIREARCH_INSTALL/pkgs/tuis.sh
source $FIREARCH_SYSTEM/pkgs/install_langs.sh

# Config
source $FIREARCH_CONFIG/config.sh
source $FIREARCH_CONFIG/docker.sh

## Final phase
clear
tte -i ./logo.txt --frame-rate 920 laseretch
echo
echo "Tudo pronto dog! agora reinicie sua wsl com o comando ´wsl --terminante archlinux´ e estara tudo configurado!" | tte --frame-rate 640 wipe

sleep 5
reboot
