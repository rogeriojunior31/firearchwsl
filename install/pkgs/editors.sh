#!/bin/bash
# Editors: LazyVim (~/.config/nvim) and Doom Emacs (~/.emacs.d). Both optional.

: "${TARGET_USER:?TARGET_USER not set — run through install.sh}"
: "${TARGET_HOME:?TARGET_HOME not set — run through install.sh}"

## LazyVim
install_lazyvim() {
  as_user git clone --depth 1 https://github.com/LazyVim/starter "$TARGET_HOME/.config/nvim" &&
    as_user rm -rf "$TARGET_HOME/.config/nvim/.git" &&
    as_user bash -c 'echo "vim.opt.relativenumber = false" >>"$HOME/.config/nvim/lua/config/options.lua"'
}

if ! component_enabled lazyvim; then
  skip "$(t ed.lazy_skip)"
elif [[ -d "$TARGET_HOME/.config/nvim" ]]; then
  ok "$(t ed.lazy_exists)"
else
  as_user mkdir -p "$TARGET_HOME/.config"
  run "$(t ed.lazy_clone)" install_lazyvim || warn "$(t ed.lazy_fail)"
fi

## Doom Emacs (downloads and compiles packages: 5 to 15 min)
# `doom install` is idempotent, so an interrupted run is simply repeated; the
# marker file is what tells a re-run that it finished.
DOOM_MARKER="$TARGET_HOME/.emacs.d/.local/.firearchwsl-installed"
install_doom() {
  as_user env DOOMLOCALDIR="$TARGET_HOME/.emacs.d/.local" \
    "$TARGET_HOME/.emacs.d/bin/doom" --force install &&
    as_user touch "$DOOM_MARKER"
}

if ! component_enabled doom; then
  skip "$(t ed.doom_skip)"
else
  run "$(t ed.emacs)" pacman -S --needed --noconfirm emacs
  if [[ -e "$DOOM_MARKER" ]]; then
    ok "$(t ed.doom_exists)"
  else
    if [[ ! -d "$TARGET_HOME/.emacs.d" ]]; then
      run "$(t ed.doom_clone)" \
        as_user git clone --depth 1 https://github.com/doomemacs/doomemacs "$TARGET_HOME/.emacs.d"
    fi
    msg "$(t ed.doom_note)"
    run "doom install" install_doom || warn "$(t ed.doom_fail)"
  fi
fi
