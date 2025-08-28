#!/bin/bash

# Exit immediately if a non-zero status
set -eE

FIREARCH_INSTALL=./install
FIREARCH_SYSTEM=./system
FIREARCH_CONFIG=./config

# Preparation
source $FIREARCH_SYSTEM/create_your_user.sh
source $FIREARCH_SYSTEM/configure_locale.sh
source $FIREARCH_INSTALL/preflight/essentials_pkgs.sh
source $FIREARCH_SYSTEM/configure_git_user.sh
source $FIREARCH_INSTALL/preflight/repositories.sh
source $FIREARCH_INSTALL/preflight/install-mise.sh

# Packaging
source $FIREARCH_INSTALL/pkgs/good-tools.sh
source $FIREARCH_INSTALL/pkgs/tuis.sh

# Config
source $FIREARCH_CONFIG/config.sh
source $FIREARCH_CONFIG/docker.sh

## Final phase
clear

sleep 5
reboot
