#!/bin/bash
# TUIs + the yazi preview stack.

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

if ! component_enabled tuis; then
  skip "$(t tuis.skip)"
  return 0
fi

pac_install "$(t tuis.install)" "${PACMAN_PKGS[@]}"
