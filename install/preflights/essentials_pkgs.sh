#!/bin/bash
# Minimal packages the rest of the pipeline depends on.

PACMAN_PKGS=(
  "sudo"
  "base-devel"
  "diffutils"
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

# Global sync already done by install.sh; this only installs.
pac_install "$(t ess.install)" "${PACMAN_PKGS[@]}"
