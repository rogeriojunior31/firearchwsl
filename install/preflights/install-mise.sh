#!/bin/bash
# Installs mise (polyglot version manager) as a system package.
# Shell activation lives in default/bashrc and default/config.fish
# (guarded by `command -v mise`) — config/config.sh copies those defaults.

run "$(t mise.install)" pacman -S --needed --noconfirm mise
msg "mise $(mise --version 2>/dev/null | head -n 1 || true)"
